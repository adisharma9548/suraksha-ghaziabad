import React, { useState, useEffect } from "react";
import { collection, query, orderBy, onSnapshot, limit } from "firebase/firestore";
import { db } from "../lib/firebase";
import { ShieldAlert, Clock, User, FileText, CheckCircle } from "lucide-react";

export default function AuditLogViewer() {
  const [logs, setLogs] = useState([]);

  useEffect(() => {
    const q = query(collection(db, "audit_logs"), orderBy("timestamp", "desc"), limit(100));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setLogs(list);
    }, (err) => {
      console.warn("Firestore audit_logs stream notice:", err.message);
    });
    return () => unsubscribe();
  }, []);

  const getActionColor = (action) => {
    switch (action) {
      case "SOS_TRIGGERED":
        return "#ef4444";
      case "SOS_DURESS_TRIGGERED":
        return "#dc2626";
      case "SOS_PATROL_ASSIGNED":
        return "#f59e0b";
      case "SOS_RESOLVED":
        return "#10b981";
      case "REPORT_ROUTED":
        return "#3b82f6";
      default:
        return "#94a3b8";
    }
  };

  return (
    <div style={{ padding: "24px", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ marginBottom: "24px" }}>
        <h2 style={{ fontSize: "20px", fontWeight: "700" }}>Immutable Server-Side Audit Trail</h2>
        <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "2px" }}>
          Read-only forensic log recorded exclusively by Cloud Functions and Firebase Admin SDK. Direct client writes are forbidden by security rules.
        </p>
      </div>

      {/* Table */}
      <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", overflow: "hidden" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", fontSize: "13px" }}>
          <thead>
            <tr style={{ background: "#0f172a", borderBottom: "1px solid #334155", color: "#94a3b8" }}>
              <th style={{ padding: "12px 16px" }}>Timestamp</th>
              <th style={{ padding: "12px 16px" }}>Security Action</th>
              <th style={{ padding: "12px 16px" }}>Entity ID</th>
              <th style={{ padding: "12px 16px" }}>Initiator / Operator</th>
              <th style={{ padding: "12px 16px" }}>Forensic Metadata</th>
            </tr>
          </thead>
          <tbody>
            {logs.length === 0 ? (
              <tr>
                <td colSpan={5} style={{ padding: "40px", textAlign: "center", color: "#64748b" }}>
                  No audit entries recorded yet. As SOS alerts and report routing events occur, immutable logs will appear here.
                </td>
              </tr>
            ) : (
              logs.map((log) => {
                const actionColor = getActionColor(log.action);
                return (
                  <tr key={log.id} style={{ borderBottom: "1px solid #334155" }}>
                    <td style={{ padding: "12px 16px", color: "#94a3b8", whiteSpace: "nowrap" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                        <Clock size={13} />
                        {log.timestamp ? new Date(log.timestamp.toDate?.() || log.timestamp).toLocaleString() : "Just now"}
                      </div>
                    </td>
                    <td style={{ padding: "12px 16px" }}>
                      <span style={{
                        padding: "3px 8px",
                        borderRadius: "4px",
                        fontSize: "11px",
                        fontWeight: "700",
                        background: `${actionColor}20`,
                        color: actionColor,
                        border: `1px solid ${actionColor}`,
                      }}>
                        {log.action}
                      </span>
                    </td>
                    <td style={{ padding: "12px 16px", fontFamily: "monospace", color: "#cbd5e1" }}>
                      {log.entityId}
                    </td>
                    <td style={{ padding: "12px 16px", color: "#38bdf8" }}>
                      {log.userId || "CloudFunction"}
                    </td>
                    <td style={{ padding: "12px 16px", color: "#94a3b8", fontSize: "12px" }}>
                      {log.details ? JSON.stringify(log.details) : log.note || "System event verified"}
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
