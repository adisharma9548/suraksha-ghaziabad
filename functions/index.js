const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

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
    try {
      await admin.firestore().collection("audit_logs").add({
        action: "SOS_TRIGGERED",
        entityId: alertId,
        userId: alertData.userId || "unknown",
        userName: userName,
        lat: latestLoc.lat,
        lng: latestLoc.lng,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        ipAddress: "mobile_client",
      });
    } catch (auditErr) {
      console.error(`[onSosCreated] Failed to write audit log for alert ${alertId}:`, auditErr);
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
    } catch (err) {
      console.error(`[onReportCreated] Failed to update report routing for ${reportId}:`, err);
    }
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
