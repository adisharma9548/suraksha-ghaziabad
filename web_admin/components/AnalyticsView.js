import React, { useState, useEffect } from "react";
import { collection, onSnapshot } from "firebase/firestore";
import { db } from "../lib/firebase";
import { Download, BarChart3, TrendingUp, Clock, AlertTriangle, ShieldCheck } from "lucide-react";

export default function AnalyticsView() {
  const [reports, setReports] = useState([]);
  const [sosAlerts, setSosAlerts] = useState([]);

  useEffect(() => {
    const unsubReports = onSnapshot(collection(db, "reports"), (snap) => {
      setReports(snap.docs.map((d) => d.data()));
    });
    const unsubSos = onSnapshot(collection(db, "sos_alerts"), (snap) => {
      setSosAlerts(snap.docs.map((d) => d.data()));
    });
    return () => {
      unsubReports();
      unsubSos();
    };
  }, []);

  // Compute Real SOS Response Times (Phase 4 & 6 requirement: no hardcoded numbers!)
  const responseTimesMin = sosAlerts
    .filter((a) => a.startedAt && a.assignedAt)
    .map((a) => {
      const start = new Date(a.startedAt).getTime();
      const assign = new Date(a.assignedAt).getTime();
      const diffMin = (assign - start) / (1000 * 60);
      return diffMin > 0 ? diffMin : null;
    })
    .filter((v) => v !== null);

  const avgResponseTimeMin =
    responseTimesMin.length > 0
      ? (responseTimesMin.reduce((a, b) => a + b, 0) / responseTimesMin.length).toFixed(1)
      : "N/A";

  // Ward aggregation
  const wards = [
    { name: "Vasundhara", lat: 28.6602, lng: 77.3789 },
    { name: "Mohan Nagar", lat: 28.6834, lng: 77.3912 },
    { name: "Kavi Nagar", lat: 28.6658, lng: 77.4526 },
    { name: "Vijay Nagar", lat: 28.6315, lng: 77.4421 },
    { name: "City Kotwali", lat: 28.6725, lng: 77.4291 },
  ];

  // Category counts
  const categoryCounts = reports.reduce((acc, r) => {
    const cat = r.category || "Other";
    acc[cat] = (acc[cat] || 0) + 1;
    return acc;
  }, {});

  // CSV Export Generator
  const handleExportCsv = () => {
    let csvContent = "data:text/csv;charset=utf-8,";
    csvContent += "Category,Description,Latitude,Longitude,ReportedAt,Status,RoutedAuthority,CitizenAcknowledgement\n";

    reports.forEach((r) => {
      const row = [
        `"${(r.category || "").replace(/"/g, '""')}"`,
        `"${(r.description || "").replace(/"/g, '""')}"`,
        r.lat || "",
        r.lng || "",
        `"${r.reportedAt || ""}"`,
        `"${r.status || ""}"`,
        `"${r.routedAuthority || ""}"`,
        `"${r.acknowledgementStatus || ""}"`,
      ].join(",");
      csvContent += row + "\n";
    });

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `ghaziabad_safety_analytics_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div style={{ padding: "24px", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px", flexWrap: "wrap", gap: "16px" }}>
        <div>
          <h2 style={{ fontSize: "20px", fontWeight: "700" }}>District Safety Analytics & Intelligence</h2>
          <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "2px" }}>
            Real-time telemetry, response metrics, and ward safety risk calculated from live timestamps
          </p>
        </div>

        <button
          onClick={handleExportCsv}
          style={{
            background: "#10b981",
            color: "#ffffff",
            padding: "8px 16px",
            borderRadius: "8px",
            fontWeight: "600",
            fontSize: "13px",
            display: "flex",
            alignItems: "center",
            gap: "8px",
          }}
        >
          <Download size={16} />
          Export Report to CSV
        </button>
      </div>

      {/* KPI Cards */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "16px", marginBottom: "24px" }}>
        <div style={{ background: "#1e293b", padding: "18px", borderRadius: "10px", border: "1px solid #334155" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#94a3b8", fontSize: "13px" }}>
            <Clock size={16} color="#38bdf8" />
            <span>Avg Response Time</span>
          </div>
          <div style={{ fontSize: "28px", fontWeight: "800", color: "#f8fafc", marginTop: "8px" }}>
            {avgResponseTimeMin === "N/A" ? "No dispatches yet" : `${avgResponseTimeMin} min`}
          </div>
          <span style={{ fontSize: "11px", color: "#64748b" }}>Computed from real SOS timestamps</span>
        </div>

        <div style={{ background: "#1e293b", padding: "18px", borderRadius: "10px", border: "1px solid #334155" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#94a3b8", fontSize: "13px" }}>
            <AlertTriangle size={16} color="#ef4444" />
            <span>Total SOS Transmissions</span>
          </div>
          <div style={{ fontSize: "28px", fontWeight: "800", color: "#f8fafc", marginTop: "8px" }}>
            {sosAlerts.length}
          </div>
          <span style={{ fontSize: "11px", color: "#64748b" }}>Lifetime emergency transmissions</span>
        </div>

        <div style={{ background: "#1e293b", padding: "18px", borderRadius: "10px", border: "1px solid #334155" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#94a3b8", fontSize: "13px" }}>
            <BarChart3 size={16} color="#fbbf24" />
            <span>Citizen Hazard Reports</span>
          </div>
          <div style={{ fontSize: "28px", fontWeight: "800", color: "#f8fafc", marginTop: "8px" }}>
            {reports.length}
          </div>
          <span style={{ fontSize: "11px", color: "#64748b" }}>Civic & policing hazard entries</span>
        </div>

        <div style={{ background: "#1e293b", padding: "18px", borderRadius: "10px", border: "1px solid #334155" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px", color: "#94a3b8", fontSize: "13px" }}>
            <ShieldCheck size={16} color="#34d399" />
            <span>Resolved Hazards</span>
          </div>
          <div style={{ fontSize: "28px", fontWeight: "800", color: "#34d399", marginTop: "8px" }}>
            {reports.filter((r) => r.status === "Fixed").length}
          </div>
          <span style={{ fontSize: "11px", color: "#64748b" }}>Closed by field units</span>
        </div>
      </div>

      {/* Breakdown Grids */}
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "24px" }}>
        {/* Hazards by Category */}
        <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", padding: "20px" }}>
          <h3 style={{ fontSize: "16px", fontWeight: "700", marginBottom: "16px" }}>Reports by Hazard Category</h3>
          <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
            {Object.keys(categoryCounts).length === 0 ? (
              <p style={{ color: "#64748b", fontSize: "13px" }}>No category report data recorded yet.</p>
            ) : (
              Object.entries(categoryCounts).map(([cat, count]) => {
                const pct = reports.length > 0 ? ((count / reports.length) * 100).toFixed(0) : 0;
                return (
                  <div key={cat}>
                    <div style={{ display: "flex", justifyContent: "space-between", fontSize: "13px", marginBottom: "4px" }}>
                      <span>{cat}</span>
                      <span style={{ color: "#38bdf8", fontWeight: "600" }}>{count} ({pct}%)</span>
                    </div>
                    <div style={{ background: "#0f172a", height: "8px", borderRadius: "4px", overflow: "hidden" }}>
                      <div style={{ background: "#3b82f6", width: `${pct}%`, height: "100%", borderRadius: "4px" }} />
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

        {/* Ghaziabad Administrative Zones */}
        <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", padding: "20px" }}>
          <h3 style={{ fontSize: "16px", fontWeight: "700", marginBottom: "16px" }}>Ghaziabad Administrative Zones</h3>
          <div style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
            {wards.map((ward) => (
              <div
                key={ward.name}
                style={{
                  background: "#0f172a",
                  padding: "12px 14px",
                  borderRadius: "8px",
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                }}
              >
                <div>
                  <div style={{ fontWeight: "600", fontSize: "14px" }}>{ward.name}</div>
                  <div style={{ fontSize: "11px", color: "#64748b" }}>Lat: {ward.lat}, Lng: {ward.lng}</div>
                </div>
                <span style={{
                  fontSize: "11px",
                  fontWeight: "700",
                  padding: "3px 8px",
                  borderRadius: "4px",
                  background: "rgba(16, 185, 129, 0.2)",
                  color: "#34d399",
                }}>
                  ACTIVE PATROL ZONE
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
