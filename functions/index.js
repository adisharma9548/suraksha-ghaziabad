const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Server-side audit logger writing immutable records to 'audit_logs'.
 */
async function recordAuditLog(action, entityId, userId, details = {}) {
  try {
    await admin.firestore().collection("audit_logs").add({
      action,
      entityId,
      userId: userId || "system",
      details,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    console.error(`[recordAuditLog] Failed to record audit log for ${action}:`, err);
  }
}

/**
 * Simple sliding window rate-limiter using Firestore collection 'rate_limits'.
 * @param {string} key Unique key (e.g., ip or phoneNumber)
 * @param {number} maxRequests Maximum requests allowed in window
 * @param {number} windowSeconds Window duration in seconds
 * @returns {Promise<boolean>} True if allowed, false if rate limited
 */
async function checkRateLimit(key, maxRequests = 3, windowSeconds = 600) {
  const db = admin.firestore();
  const rateLimitRef = db.collection("rate_limits").doc(key);
  const now = Date.now();
  const windowStart = now - windowSeconds * 1000;

  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(rateLimitRef);
    if (!doc.exists) {
      transaction.set(rateLimitRef, { timestamps: [now] });
      return true;
    }

    const data = doc.data();
    const timestamps = (data.timestamps || []).filter((ts) => ts > windowStart);

    if (timestamps.length >= maxRequests) {
      return false;
    }

    timestamps.push(now);
    transaction.set(rateLimitRef, { timestamps });
    return true;
  });
}

/**
 * Triggered whenever a new SOS emergency alert is written to Firestore.
 * 1. Pushes high-priority FCM notification to the 'officers_ghaziabad' topic.
 * 2. Writes an immutable server-side audit log entry.
 */
exports.onSosCreated = functions.firestore
  .document("sos_alerts/{alertId}")
  .onCreate(async (snap, context) => {
    const alertId = context.params.alertId;
    const alertData = snap.data();

    const userName = alertData.userName || "Citizen in Distress";
    const locations = alertData.locations || [];
    const latestLoc = locations.length > 0 ? locations[locations.length - 1] : { lat: 28.6692, lng: 77.4538 };

    // 1. Compose FCM Emergency Broadcast to Officers
    const message = {
      topic: "officers_ghaziabad",
      notification: {
        title: "🚨 CRITICAL SOS ALERT - GHAZIABAD",
        body: `${userName} has triggered a high-priority emergency SOS!`,
      },
      data: {
        alertId: alertId,
        userName: userName,
        userPhone: alertData.userPhone || "",
        lat: String(latestLoc.lat),
        lng: String(latestLoc.lng),
        startedAt: alertData.startedAt || new Date().toISOString(),
        type: "emergency_sos",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "suraksha_sos_channel",
          sound: "default",
          priority: "max",
          visibility: "public",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            critical: true,
          },
        },
      },
    };

    try {
      const fcmResponse = await admin.messaging().send(message);
      console.log(`[onSosCreated] FCM broadcast sent for alert ${alertId}:`, fcmResponse);
    } catch (fcmErr) {
      console.error(`[onSosCreated] Failed to broadcast FCM for alert ${alertId}:`, fcmErr);
    }

    // 2. Server-side Audit Log
    await recordAuditLog("SOS_TRIGGERED", alertId, alertData.userId, {
      userName,
      lat: latestLoc.lat,
      lng: latestLoc.lng,
    });
  });

/**
 * Triggered on SOS status updates: logs patrol unit assignment, duress, or resolution.
 */
exports.onSosUpdated = functions.firestore
  .document("sos_alerts/{alertId}")
  .onUpdate(async (change, context) => {
    const alertId = context.params.alertId;
    const before = change.before.data();
    const after = change.after.data();

    // Check for Duress Trigger
    if (!before.isDuress && (after.isDuress === true || after.status === "duress_active")) {
      console.warn(`[onSosUpdated] ⚠️ SILENT DURESS ALERT triggered for SOS ${alertId}`);
      await recordAuditLog("SOS_DURESS_TRIGGERED", alertId, after.userId, {
        note: "Citizen entered decoy duress PIN under coercion. Maintain silent response.",
      });

      // Send silent officer push
      try {
        await admin.messaging().send({
          topic: "officers_ghaziabad",
          notification: {
            title: "⚠️ SILENT DURESS ALERT - COERCION DETECTED",
            body: `Distress user ${after.userName || "Citizen"} entered duress PIN. Do NOT call citizen. Immediate dispatch required.`,
          },
          data: {
            alertId: alertId,
            type: "duress_alert",
          },
        });
      } catch (err) {
        console.error(`[onSosUpdated] Failed to send duress FCM:`, err);
      }
    }

    // Patrol Unit Assignment
    if (before.assignedUnitId !== after.assignedUnitId && after.assignedUnitId) {
      await recordAuditLog("SOS_PATROL_ASSIGNED", alertId, after.assignedBy || "officer", {
        assignedUnitId: after.assignedUnitId,
      });
    }

    // Resolution
    if (before.status !== "resolved" && after.status === "resolved") {
      await recordAuditLog("SOS_RESOLVED", alertId, after.resolvedBy || "officer", {
        resolvedAt: after.resolvedAt || new Date().toISOString(),
      });
    }
  });

/**
 * Report routing: routes civic hazards to Nagar Nigam Ghaziabad and safety threats to UP Police.
 */
exports.onReportCreated = functions.firestore
  .document("reports/{reportId}")
  .onCreate(async (snap, context) => {
    const reportId = context.params.reportId;
    const report = snap.data();
    const category = (report.category || "").toLowerCase();

    // Determine target authority
    let targetAuthority = "UP_POLICE";
    if (category.includes("streetlight") || category.includes("road") || category.includes("civic")) {
      targetAuthority = "NAGAR_NIGAM_GHAZIABAD";
    }

    try {
      await snap.ref.update({
        routedAuthority: targetAuthority,
        routedAt: admin.firestore.FieldValue.serverTimestamp(),
        acknowledgementStatus: "Delivered to Control Room",
      });
      console.log(`[onReportCreated] Report ${reportId} routed to ${targetAuthority}`);

      await recordAuditLog("REPORT_ROUTED", reportId, report.userId || "anonymous", {
        category: report.category,
        routedAuthority: targetAuthority,
      });
    } catch (err) {
      console.error(`[onReportCreated] Failed to update report routing for ${reportId}:`, err);
    }
  });

/**
 * Cloud Function to securely send SMS OTP via SMS Horizon Gateway.
 * Protected by App Check in production and server-side rate-limiting.
 */
exports.sendSmsOtp = functions.https.onCall(async (data, context) => {
  // App Check verification (optional in debug, mandatory in production)
  if (process.env.NODE_ENV === "production" && !context.app) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The function must be called from an App Check verified application."
    );
  }

  const { phoneNumber } = data;
  if (!phoneNumber || !/^\+?[1-9]\d{9,14}$/.test(phoneNumber.replace(/\s+/g, ""))) {
    throw new functions.https.HttpsError("invalid-argument", "Valid phone number required.");
  }

  const cleanPhone = phoneNumber.replace(/[\s+-]/g, "").slice(-10);

  // Rate limit: max 3 OTP requests per phone number in 10 minutes
  const allowed = await checkRateLimit(`otp_${cleanPhone}`, 3, 600);
  if (!allowed) {
    throw new functions.https.HttpsError(
      "resource-exhausted",
      "Too many OTP requests. Please wait a few minutes before trying again."
    );
  }

  // Generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  // Store hashed OTP in Firestore with 10-minute expiry
  const crypto = require("crypto");
  const hashedOtp = crypto.createHash("sha256").update(otp).digest("hex");
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);

  await admin.firestore().collection("otp_requests").doc(cleanPhone).set({
    hashedOtp,
    expiresAt,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    attempts: 0,
  });

  // Call SMS Horizon API
  const apiKey = process.env.SMS_HORIZON_API_KEY || "jS1cmecLDAp1qcNxbknqrwyNzMZZm7";
  const user = process.env.SMS_HORIZON_USER || "adisharma";
  const senderId = process.env.SMS_HORIZON_SENDER_ID || "HORIZN";
  const tid = "1607100000000323238";
  const message = `OTP for your new user account registration is: ${otp}\n\n- SmsHorizon`;

  try {
    const params = new URLSearchParams({
      user: user,
      senderid: senderId,
      number: cleanPhone,
      message: message,
      type: "txt",
      tid: tid,
      prettyprint: "1",
    });

    const response = await fetch("https://smshorizon.com/api/v2/sendsms", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: params.toString(),
    });

    const respText = await response.text();
    console.log(`[sendSmsOtp] SMS Horizon response for ${cleanPhone}:`, respText);

    return { success: true, message: "OTP sent successfully." };
  } catch (err) {
    console.error(`[sendSmsOtp] SMS Horizon request failed:`, err);
    throw new functions.https.HttpsError("internal", "Failed to dispatch SMS OTP. Please try again.");
  }
});

/**
 * Cloud Function to verify SMS OTP and return a custom Firebase Auth token.
 */
exports.verifySmsOtp = functions.https.onCall(async (data, context) => {
  const { phoneNumber, otp } = data;
  if (!phoneNumber || !otp) {
    throw new functions.https.HttpsError("invalid-argument", "Phone number and OTP are required.");
  }

  const cleanPhone = phoneNumber.replace(/[\s+-]/g, "").slice(-10);
  const otpDocRef = admin.firestore().collection("otp_requests").doc(cleanPhone);
  const doc = await otpDocRef.get();

  if (!doc.exists) {
    throw new functions.https.HttpsError("not-found", "No OTP request found for this number.");
  }

  const dataRecord = doc.data();
  if (dataRecord.expiresAt.toDate() < new Date()) {
    throw new functions.https.HttpsError("deadline-exceeded", "OTP has expired. Please request a new one.");
  }

  if ((dataRecord.attempts || 0) >= 5) {
    throw new functions.https.HttpsError("permission-denied", "Too many invalid attempts. Request a new OTP.");
  }

  const crypto = require("crypto");
  const hashedInput = crypto.createHash("sha256").update(otp.trim()).digest("hex");

  if (hashedInput !== dataRecord.hashedOtp) {
    await otpDocRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
    throw new functions.https.HttpsError("invalid-argument", "Invalid OTP entered.");
  }

  // Delete used OTP
  await otpDocRef.delete();

  // Create or retrieve Firebase Auth user for phone number
  const fullPhone = `+91${cleanPhone}`;
  let userRecord;
  try {
    userRecord = await admin.auth().getUserByPhoneNumber(fullPhone);
  } catch (err) {
    if (err.code === "auth/user-not-found") {
      userRecord = await admin.auth().createUser({ phoneNumber: fullPhone });
    } else {
      throw err;
    }
  }

  // Generate Custom Auth Token for the client
  const customToken = await admin.auth().createCustomToken(userRecord.uid);
  return { success: true, customToken, uid: userRecord.uid };
});

/**
 * Admin function to set officer custom claims securely server-side.
 */
exports.setOfficerRole = functions.https.onCall(async (data, context) => {
  // Only existing admins can assign officer roles
  if (!context.auth || context.auth.token.role !== "admin") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only administrative supervisors can assign officer roles."
    );
  }

  const { targetUid } = data;
  if (!targetUid) {
    throw new functions.https.HttpsError("invalid-argument", "targetUid is required.");
  }

  await admin.auth().setCustomUserClaims(targetUid, { role: "officer" });
  await admin.firestore().collection("users").doc(targetUid).update({
    role: "officer",
    roleAssignedAt: admin.firestore.FieldValue.serverTimestamp(),
    assignedBy: context.auth.uid,
  });

  return { success: true, message: `Officer role assigned to ${targetUid}` };
});
