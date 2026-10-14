import React, { useState, useEffect } from "react";
import { collection, query, orderBy, onSnapshot, doc, updateDoc } from "firebase/firestore";
import { db } from "../lib/firebase";
import { CheckCircle2, Clock, MapPin, Building2, Shield, Filter, AlertCircle } from "lucide-react";

export default function ReportsQueue() {
  const [reports, setReports] = useState([]);
  const [filterAuthority, setFilterAuthority] = useState("ALL");
  const [filterStatus, setFilterStatus] = useState("ALL");
  const [actionNotes, setActionNotes] = useState({});
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    const q = query(collection(db, "reports"), orderBy("reportedAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setReports(list);
    }, (err) => {
      console.warn("Firestore reports stream notice:", err.message);
    });

    return () => unsubscribe();
  }, []);

  const handleUpdateStatus = async (reportId, newStatus, currentAck) => {
    setIsSaving(true);
    const note = actionNotes[reportId] || "";
    let updatedAck = currentAck;

    if (newStatus === "In progress") {
      updatedAck = "Action Taken / Team Dispatched";
    } else if (newStatus === "Fixed") {
      updatedAck = "Resolved on Ground";
    }

    try {
      await updateDoc(doc(db, "reports", reportId), {
        status: newStatus,
        acknowledgementStatus: updatedAck,
        ...(note ? { actionNote: note } : {}),
        updatedAt: new Date().toISOString(),
      });
      alert(`Report ${reportId} marked as ${newStatus}.`);
    } catch (err) {
      alert("Failed to update status: " + err.message);
    } finally {
      setIsSaving(false);
    }
  };

  const filteredReports = reports.filter((r) => {
    const authMatch =
      filterAuthority === "ALL" ||
      (filterAuthority === "NAGAR_NIGAM" && (r.routedAuthority === "NAGAR_NIGAM_GHAZIABAD" || r.category?.toLowerCase().includes("streetlight") || r.category?.toLowerCase().includes("road"))) ||
      (filterAuthority === "POLICE" && (r.routedAuthority === "UP_POLICE" || !r.routedAuthority || r.category?.toLowerCase().includes("harass") || r.category?.toLowerCase().includes("crowd")));

    const statusMatch = filterStatus === "ALL" || r.status === filterStatus;

    return authMatch && statusMatch;
  });

  return (
    <div style={{ padding: "24px", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header and Filters */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px", flexWrap: "wrap", gap: "16px" }}>
        <div>
          <h2 style={{ fontSize: "20px", fontWeight: "700" }}>Citizen Safety Reports Moderation Queue</h2>
          <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "2px" }}>
            Route and action civic infrastructure hazards (Nagar Nigam) vs criminal threats (UP Police)
          </p>
        </div>

        {/* Filter Controls */}
        <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
          <div style={{ display: "flex", background: "#1e293b", padding: "4px", borderRadius: "8px", border: "1px solid #334155" }}>
            {[
              { id: "ALL", label: "All Authorities" },
              { id: "NAGAR_NIGAM", label: "🏛️ Nagar Nigam" },
              { id: "POLICE", label: "👮 UP Police" },
            ].map((tab) => (
              <button
                key={tab.id}
                onClick={() => setFilterAuthority(tab.id)}
                style={{
                  padding: "6px 12px",
                  borderRadius: "6px",
                  fontSize: "12px",
                  fontWeight: "600",
                  background: filterAuthority === tab.id ? "#3b82f6" : "transparent",
                  color: filterAuthority === tab.id ? "#ffffff" : "#94a3b8",
                }}
              >
                {tab.label}
              </button>
            ))}
          </div>

          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            style={{
              background: "#1e293b",
              color: "#f8fafc",
              border: "1px solid #334155",
              borderRadius: "8px",
              padding: "8px 12px",
              fontSize: "13px",
            }}
          >
            <option value="ALL">All Statuses</option>
            <option value="Open">Open</option>
            <option value="In progress">In Progress</option>
            <option value="Fixed">Fixed / Resolved</option>
          </select>
        </div>
      </div>

      {/* Reports Grid */}
      <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
        {filteredReports.length === 0 ? (
          <div style={{ textAlign: "center", padding: "60px 20px", background: "#1e293b", borderRadius: "12px", border: "1px solid #334155", color: "#64748b" }}>
            <AlertCircle size={36} style={{ margin: "0 auto 12px", opacity: 0.5 }} />
            <p style={{ fontSize: "15px", fontWeight: "600" }}>No reports match the selected filters</p>
            <p style={{ fontSize: "13px", marginTop: "4px" }}>Incoming citizen reports from the mobile app will be routed here automatically.</p>
          </div>
        ) : (
          filteredReports.map((report) => {
            const isNagarNigam = report.routedAuthority === "NAGAR_NIGAM_GHAZIABAD" || report.category?.toLowerCase().includes("streetlight") || report.category?.toLowerCase().includes("road");

            return (
              <div
                key={report.id}
                style={{
                  background: "#1e293b",
                  border: "1px solid #334155",
                  borderRadius: "10px",
                  padding: "18px",
                  display: "grid",
                  gridTemplateColumns: "1fr 280px",
                  gap: "20px",
                }}
              >
                {/* Details */}
                <div>
                  <div style={{ display: "flex", alignItems: "center", gap: "10px", marginBottom: "8px" }}>
                    <span style={{
                      background: isNagarNigam ? "rgba(245, 158, 11, 0.2)" : "rgba(59, 130, 246, 0.2)",
                      color: isNagarNigam ? "#fbbf24" : "#60a5fa",
                      border: `1px solid ${isNagarNigam ? "#f59e0b" : "#3b82f6"}`,
                      fontSize: "11px",
                      fontWeight: "700",
                      padding: "2px 8px",
                      borderRadius: "4px",
                      display: "flex",
                      alignItems: "center",
                      gap: "4px",
                    }}>
                      {isNagarNigam ? <Building2 size={12} /> : <Shield size={12} />}
                      {isNagarNigam ? "NAGAR NIGAM GHAZIABAD" : "UP POLICE SAFETY QUEUE"}
                    </span>

                    <span className={`status-badge status-${(report.status || "open").toLowerCase().replace(" ", "")}`}>
                      {report.status || "Open"}
                    </span>

                    <span style={{ fontSize: "12px", color: "#94a3b8", display: "flex", alignItems: "center", gap: "4px" }}>
                      <Clock size={12} />
                      {report.reportedAt ? new Date(report.reportedAt).toLocaleString() : "Unknown"}
                    </span>
                  </div>

                  <h3 style={{ fontSize: "16px", fontWeight: "700", color: "#f8fafc", marginBottom: "6px" }}>
                    {report.category}
                  </h3>

                  <p style={{ fontSize: "14px", color: "#cbd5e1", lineHeight: "1.5", marginBottom: "12px" }}>
                    {report.description}
                  </p>

                  <div style={{ display: "flex", alignItems: "center", gap: "16px", fontSize: "12px", color: "#94a3b8" }}>
                    <span style={{ display: "flex", alignItems: "center", gap: "4px" }}>
                      <MapPin size={13} color="#38bdf8" />
                      Ghaziabad Coordinates: {report.lat?.toFixed(4)}, {report.lng?.toFixed(4)}
                    </span>
                    <span>
                      Citizen Status: <strong style={{ color: "#34d399" }}>{report.acknowledgementStatus || "Delivered to Control Room"}</strong>
                    </span>
                  </div>

                  {report.actionNote && (
                    <div style={{ marginTop: "10px", padding: "8px 12px", background: "#0f172a", borderRadius: "6px", fontSize: "12px", color: "#93c5fd", borderLeft: "3px solid #3b82f6" }}>
                      <strong>Authority Action Log:</strong> {report.actionNote}
                    </div>
                  )}
                </div>

                {/* Moderation Controls */}
                <div style={{ borderLeft: "1px solid #334155", paddingLeft: "20px", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
                  <div>
                    <label style={{ fontSize: "12px", color: "#94a3b8", fontWeight: "600", display: "block", marginBottom: "6px" }}>
                      Action Note / Work Order:
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. Work Order #NN-104 assigned"
                      value={actionNotes[report.id] || ""}
                      onChange={(e) => setActionNotes({ ...actionNotes, [report.id]: e.target.value })}
                      style={{
                        width: "100%",
                        background: "#0f172a",
                        border: "1px solid #475569",
                        borderRadius: "6px",
                        padding: "8px 10px",
                        color: "#f8fafc",
                        fontSize: "12px",
                        marginBottom: "10px",
                      }}
                    />
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    <button
                      onClick={() => handleUpdateStatus(report.id, "In progress", report.acknowledgementStatus)}
                      disabled={isSaving || report.status === "In progress"}
                      style={{
                        background: "#f59e0b",
                        color: "#0f172a",
                        fontWeight: "700",
                        fontSize: "12px",
                        padding: "8px",
                        borderRadius: "6px",
                        opacity: report.status === "In progress" ? 0.5 : 1,
                      }}
                    >
                      Dispatch / Mark In Progress
                    </button>

                    <button
                      onClick={() => handleUpdateStatus(report.id, "Fixed", report.acknowledgementStatus)}
                      disabled={isSaving || report.status === "Fixed"}
                      style={{
                        background: "#10b981",
                        color: "#ffffff",
                        fontWeight: "700",
                        fontSize: "12px",
                        padding: "8px",
                        borderRadius: "6px",
                        opacity: report.status === "Fixed" ? 0.5 : 1,
                      }}
                    >
                      Resolve / Mark Fixed
                    </button>
                  </div>
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
}
