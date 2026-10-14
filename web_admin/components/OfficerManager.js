import React, { useState, useEffect } from "react";
import { collection, query, where, onSnapshot } from "firebase/firestore";
import { httpsCallable } from "firebase/functions";
import { db, functions } from "../lib/firebase";
import { ShieldCheck, UserPlus, KeyRound, AlertCircle, CheckCircle } from "lucide-react";

export default function OfficerManager({ currentUser }) {
  const [officers, setOfficers] = useState([]);
  const [targetUid, setTargetUid] = useState("");
  const [targetRole, setTargetRole] = useState("officer");
  const [isAssigning, setIsAssigning] = useState(false);
  const [feedback, setFeedback] = useState(null);

  useEffect(() => {
    // Listen to users with role officer or admin
    const q = query(collection(db, "users"), where("role", "in", ["officer", "admin"]));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setOfficers(list);
    }, (err) => {
      console.warn("Firestore users officer query notice:", err.message);
    });
    return () => unsubscribe();
  }, []);

  const handleAssignRole = async (e) => {
    e.preventDefault();
    if (!targetUid.trim()) return;

    setIsAssigning(true);
    setFeedback(null);

    try {
      // Put authority checks in Cloud Functions, not UI!
      const setRoleFn = httpsCallable(functions, "setOfficerRole");
      const res = await setRoleFn({ targetUid: targetUid.trim(), role: targetRole });

      setFeedback({
        type: "success",
        message: `Successfully granted ${targetRole} role to UID: ${targetUid}`,
      });
      setTargetUid("");
    } catch (err) {
      setFeedback({
        type: "error",
        message: `Failed to set role: ${err.message}. (Requires admin custom claims on caller token)`,
      });
    } finally {
      setIsAssigning(false);
    }
  };

  return (
    <div style={{ padding: "24px", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ marginBottom: "24px" }}>
        <h2 style={{ fontSize: "20px", fontWeight: "700" }}>Officer & Administrator Role Management</h2>
        <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "2px" }}>
          Manage police supervisor access control. Roles are enforced strictly server-side via Firebase Auth Custom Claims.
        </p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 380px", gap: "24px" }}>
        {/* Left: Officer Roster */}
        <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", overflow: "hidden" }}>
          <div style={{ padding: "16px", borderBottom: "1px solid #334155", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <h3 style={{ fontSize: "15px", fontWeight: "700" }}>Active Verified Police Supervisors</h3>
            <span style={{ fontSize: "12px", color: "#38bdf8", fontWeight: "600" }}>{officers.length} Active Officers</span>
          </div>

          <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", fontSize: "13px" }}>
            <thead>
              <tr style={{ background: "#0f172a", borderBottom: "1px solid #334155", color: "#94a3b8" }}>
                <th style={{ padding: "12px 16px" }}>Officer Name</th>
                <th style={{ padding: "12px 16px" }}>Role Claim</th>
                <th style={{ padding: "12px 16px" }}>Phone / UID</th>
                <th style={{ padding: "12px 16px" }}>Status</th>
              </tr>
            </thead>
            <tbody>
              {officers.length === 0 ? (
                <tr>
                  <td colSpan={4} style={{ padding: "40px", textAlign: "center", color: "#64748b" }}>
                    No officers registered yet. Assign an officer claim using the form on the right.
                  </td>
                </tr>
              ) : (
                officers.map((officer) => (
                  <tr key={officer.id} style={{ borderBottom: "1px solid #334155" }}>
                    <td style={{ padding: "12px 16px", fontWeight: "600", color: "#f8fafc" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                        <ShieldCheck size={16} color="#38bdf8" />
                        {officer.name || "Police Officer"}
                      </div>
                    </td>
                    <td style={{ padding: "12px 16px" }}>
                      <span style={{
                        padding: "2px 8px",
                        borderRadius: "4px",
                        fontSize: "11px",
                        fontWeight: "700",
                        background: officer.role === "admin" ? "rgba(239, 68, 68, 0.2)" : "rgba(16, 185, 129, 0.2)",
                        color: officer.role === "admin" ? "#f87171" : "#34d399",
                        border: `1px solid ${officer.role === "admin" ? "#ef4444" : "#10b981"}`,
                      }}>
                        {officer.role.toUpperCase()}
                      </span>
                    </td>
                    <td style={{ padding: "12px 16px", color: "#94a3b8", fontFamily: "monospace" }}>
                      {officer.phone || officer.id.substring(0, 16) + "..."}
                    </td>
                    <td style={{ padding: "12px 16px" }}>
                      <span style={{ color: "#34d399", fontSize: "12px", display: "flex", alignItems: "center", gap: "4px" }}>
                        <CheckCircle size={13} />
                        Active On Duty
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Right: Grant Custom Claim Form */}
        <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", padding: "20px" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "16px" }}>
            <KeyRound size={18} color="#fbbf24" />
            <h3 style={{ fontSize: "16px", fontWeight: "700" }}>Assign Officer Claim</h3>
          </div>

          <p style={{ fontSize: "12px", color: "#94a3b8", lineHeight: "1.5", marginBottom: "16px" }}>
            Executes Cloud Function <code>setOfficerRole</code> with Firebase Admin SDK to mint immutable custom claims.
          </p>

          {feedback && (
            <div style={{
              padding: "10px 12px",
              borderRadius: "6px",
              fontSize: "12px",
              marginBottom: "16px",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              background: feedback.type === "success" ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)",
              color: feedback.type === "success" ? "#34d399" : "#f87171",
              border: `1px solid ${feedback.type === "success" ? "#10b981" : "#ef4444"}`,
            }}>
              {feedback.type === "success" ? <CheckCircle size={14} /> : <AlertCircle size={14} />}
              <span>{feedback.message}</span>
            </div>
          )}

          <form onSubmit={handleAssignRole} style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
            <div>
              <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "6px" }}>
                Target User Firebase UID
              </label>
              <input
                type="text"
                required
                placeholder="e.g. 7qZbK92mN4Xp..."
                value={targetUid}
                onChange={(e) => setTargetUid(e.target.value)}
                style={{
                  width: "100%",
                  background: "#0f172a",
                  border: "1px solid #475569",
                  borderRadius: "6px",
                  padding: "8px 10px",
                  color: "#f8fafc",
                  fontSize: "12px",
                  fontFamily: "monospace",
                }}
              />
            </div>

            <div>
              <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "6px" }}>
                Role Level
              </label>
              <select
                value={targetRole}
                onChange={(e) => setTargetRole(e.target.value)}
                style={{
                  width: "100%",
                  background: "#0f172a",
                  border: "1px solid #475569",
                  borderRadius: "6px",
                  padding: "8px 10px",
                  color: "#f8fafc",
                  fontSize: "13px",
                }}
              >
                <option value="officer">Police Officer / Dispatcher</option>
                <option value="admin">District Administrator</option>
              </select>
            </div>

            <button
              type="submit"
              disabled={isAssigning}
              style={{
                background: "#3b82f6",
                color: "#ffffff",
                padding: "10px",
                borderRadius: "6px",
                fontWeight: "600",
                fontSize: "13px",
                marginTop: "8px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "8px",
              }}
            >
              <UserPlus size={16} />
              {isAssigning ? "Minting Claims..." : "Assign Role Server-Side"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
