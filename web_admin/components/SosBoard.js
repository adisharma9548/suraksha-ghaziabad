import React, { useState, useEffect } from "react";
import { collection, query, orderBy, onSnapshot, doc, updateDoc, serverTimestamp } from "firebase/firestore";
import { db } from "../lib/firebase";
import { siren } from "../lib/sound";
import SosMap from "./SosMap";
import { AlertTriangle, ShieldAlert, CheckCircle, Navigation, Phone, Clock, User, Radio } from "lucide-react";

export default function SosBoard({ soundEnabled }) {
  const [alerts, setAlerts] = useState([]);
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [patrolUnits, setPatrolUnits] = useState([]);
  const [selectedUnit, setSelectedUnit] = useState("");
  const [isUpdating, setIsUpdating] = useState(false);
  const [prevAlertCount, setPrevAlertCount] = useState(0);

  // 1. Listen for SOS alerts
  useEffect(() => {
    const q = query(collection(db, "sos_alerts"), orderBy("startedAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setAlerts(list);

      // Check for new alerts or duress
      if (list.length > prevAlertCount && soundEnabled) {
        const newest = list[0];
        if (newest && (newest.isDuress || newest.status === "duress_active")) {
          siren?.playDuressAlarm();
        } else {
          siren?.playSosAlarm();
        }
      }
      setPrevAlertCount(list.length);

      // Default select newest if none selected
      if (!selectedAlert && list.length > 0) {
        setSelectedAlert(list[0]);
      } else if (selectedAlert) {
        const updated = list.find((a) => a.id === selectedAlert.id);
        if (updated) setSelectedAlert(updated);
      }
    }, (err) => {
      console.warn("Firestore sos_alerts stream notice:", err.message);
    });

    return () => unsubscribe();
  }, [prevAlertCount, soundEnabled, selectedAlert]);

  // 2. Fetch Patrol Units
  useEffect(() => {
    const unsubscribe = onSnapshot(collection(db, "patrol_units"), (snapshot) => {
      const units = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setPatrolUnits(units);
    }, (err) => {
      console.warn("Firestore patrol_units stream notice:", err.message);
    });
    return () => unsubscribe();
  }, []);

  // Action: Assign Unit
  const handleAssignUnit = async (alertId, unitId) => {
    if (!unitId) return;
    setIsUpdating(true);
    try {
      await updateDoc(doc(db, "sos_alerts", alertId), {
        status: "assigned",
        assignedUnitId: unitId,
        assignedAt: new Date().toISOString(),
      });
    } catch (err) {
      alert("Failed to assign unit: " + err.message);
    } finally {
      setIsUpdating(false);
    }
  };

  // Action: Mark Resolved
  const handleResolveAlert = async (alertId) => {
    if (!confirm("Are you sure you want to mark this emergency resolved?")) return;
    setIsUpdating(true);
    try {
      await updateDoc(doc(db, "sos_alerts", alertId), {
        status: "resolved",
        resolvedAt: new Date().toISOString(),
      });
    } catch (err) {
      alert("Failed to resolve alert: " + err.message);
    } finally {
      setIsUpdating(false);
    }
  };

  const activeAlerts = alerts.filter((a) => a.status !== "resolved");
  const resolvedAlerts = alerts.filter((a) => a.status === "resolved");

  return (
    <div style={{ display: "grid", gridTemplateColumns: "380px 1fr", gap: "20px", height: "calc(100vh - 80px)", padding: "20px" }}>
      {/* Left Column: Live Alerts Feed */}
      <div style={{
        background: "#1e293b",
        borderRadius: "12px",
        border: "1px solid #334155",
        display: "flex",
        flexDirection: "column",
        overflow: "hidden",
      }}>
        {/* Header */}
        <div style={{ padding: "16px", borderBottom: "1px solid #334155", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <Radio size={18} color="#ef4444" />
            <h2 style={{ fontSize: "16px", fontWeight: "700" }}>Active Emergency Feed</h2>
          </div>
          <span style={{
            background: activeAlerts.length > 0 ? "#ef4444" : "#10b981",
            color: "#ffffff",
            fontSize: "12px",
            fontWeight: "700",
            padding: "2px 8px",
            borderRadius: "9999px",
          }}>
            {activeAlerts.length} Active
          </span>
        </div>

        {/* Alerts List */}
        <div style={{ flex: 1, overflowY: "auto", padding: "12px", display: "flex", flexDirection: "column", gap: "10px" }}>
          {alerts.length === 0 ? (
            <div style={{ textAlign: "center", padding: "40px 16px", color: "#64748b" }}>
              <ShieldAlert size={36} style={{ margin: "0 auto 12px", opacity: 0.5 }} />
              <p style={{ fontSize: "14px", fontWeight: "600" }}>No emergency alerts in system</p>
              <p style={{ fontSize: "12px", marginTop: "4px" }}>Active SOS distress transmissions will appear here live with audio siren alerts.</p>
            </div>
          ) : (
            alerts.map((alert) => {
              const isDuress = alert.isDuress || alert.status === "duress_active";
              const isSelected = selectedAlert && selectedAlert.id === alert.id;
              const isResolved = alert.status === "resolved";

              return (
                <div
                  key={alert.id}
                  onClick={() => setSelectedAlert(alert)}
                  style={{
                    background: isSelected ? "#334155" : "#0f172a",
                    border: isDuress ? "2px solid #ef4444" : isSelected ? "1px solid #3b82f6" : "1px solid #1e293b",
                    borderRadius: "8px",
                    padding: "12px",
                    cursor: "pointer",
                    transition: "all 0.15s ease",
                  }}
                >
                  {isDuress && (
                    <div style={{
                      background: "rgba(239, 68, 68, 0.2)",
                      color: "#f87171",
                      padding: "4px 8px",
                      borderRadius: "4px",
                      fontSize: "11px",
                      fontWeight: "700",
                      marginBottom: "8px",
                      display: "flex",
                      alignItems: "center",
                      gap: "6px",
                    }}>
                      <AlertTriangle size={14} />
                      SILENT DURESS - COERCION DETECTED
                    </div>
                  )}

                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                    <div>
                      <h3 style={{ fontSize: "14px", fontWeight: "700", color: "#f8fafc" }}>
                        {alert.userName || "Distress Caller"}
                      </h3>
                      <p style={{ fontSize: "12px", color: "#94a3b8", display: "flex", alignItems: "center", gap: "4px", marginTop: "2px" }}>
                        <Clock size={12} />
                        {alert.startedAt ? new Date(alert.startedAt).toLocaleTimeString() : "Just now"}
                      </p>
                    </div>

                    <span className={`status-badge status-${alert.status}`}>
                      {alert.status}
                    </span>
                  </div>

                  <div style={{ marginTop: "8px", fontSize: "12px", color: "#cbd5e1", display: "flex", justifyContent: "space-between" }}>
                    <span>{alert.userPhone || "Phone hidden"}</span>
                    <span>{(alert.locations || []).length} GPS pings</span>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Right Column: Selected Alert Operations & Map */}
      <div style={{ display: "flex", flexDirection: "column", gap: "16px", height: "100%", overflowY: "auto" }}>
        {selectedAlert ? (
          <>
            {/* Duress Banner Warning */}
            {(selectedAlert.isDuress || selectedAlert.status === "duress_active") && (
              <div className="duress-banner">
                <AlertTriangle size={24} />
                <div>
                  <div style={{ fontSize: "15px", fontWeight: "800" }}>
                    CRITICAL WARNING: CITIZEN ENTERED DECOY DURESS PIN UNDER COERCION
                  </div>
                  <div style={{ fontSize: "13px", fontWeight: "500", marginTop: "2px" }}>
                    The victim's screen appears cleared to deceive the attacker. DO NOT CALL THE CITIZEN. Dispatch immediate stealth intervention to the GPS coordinates below.
                  </div>
                </div>
              </div>
            )}

            {/* Operational Action Bar */}
            <div style={{
              background: "#1e293b",
              borderRadius: "12px",
              padding: "16px",
              border: "1px solid #334155",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "12px",
            }}>
              <div>
                <h2 style={{ fontSize: "18px", fontWeight: "700", display: "flex", alignItems: "center", gap: "8px" }}>
                  <User size={20} color="#38bdf8" />
                  {selectedAlert.userName || "Distress Caller"}
                  <span className={`status-badge status-${selectedAlert.status}`} style={{ marginLeft: "8px" }}>
                    {selectedAlert.status}
                  </span>
                </h2>
                <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "4px" }}>
                  Alert ID: {selectedAlert.id} | Initiated: {selectedAlert.startedAt ? new Date(selectedAlert.startedAt).toLocaleString() : "Unknown"}
                </p>
              </div>

              {/* Action Buttons */}
              <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
                {selectedAlert.status !== "resolved" && (
                  <>
                    {/* Unit Assignment */}
                    <div style={{ display: "flex", gap: "6px" }}>
                      <select
                        value={selectedUnit}
                        onChange={(e) => setSelectedUnit(e.target.value)}
                        style={{
                          background: "#0f172a",
                          color: "#f8fafc",
                          border: "1px solid #475569",
                          borderRadius: "6px",
                          padding: "8px 12px",
                          fontSize: "13px",
                        }}
                      >
                        <option value="">-- Assign Patrol Unit --</option>
                        {patrolUnits.map((u) => (
                          <option key={u.id} value={u.id}>
                            {u.callSign || u.name} ({u.status || "available"})
                          </option>
                        ))}
                        <option value="PCR-01 Raj Nagar">PCR-01 Raj Nagar</option>
                        <option value="Cheetah-04 Indirapuram">Cheetah-04 Indirapuram</option>
                        <option value="Dial-112 Mobile-09 Vasundhara">Dial-112 Mobile-09 Vasundhara</option>
                      </select>

                      <button
                        onClick={() => handleAssignUnit(selectedAlert.id, selectedUnit)}
                        disabled={!selectedUnit || isUpdating}
                        style={{
                          background: "#3b82f6",
                          color: "#ffffff",
                          padding: "8px 14px",
                          borderRadius: "6px",
                          fontWeight: "600",
                          fontSize: "13px",
                          opacity: !selectedUnit ? 0.5 : 1,
                        }}
                      >
                        Assign Unit
                      </button>
                    </div>

                    <button
                      onClick={() => handleResolveAlert(selectedAlert.id)}
                      disabled={isUpdating}
                      style={{
                        background: "#10b981",
                        color: "#ffffff",
                        padding: "8px 16px",
                        borderRadius: "6px",
                        fontWeight: "600",
                        fontSize: "13px",
                        display: "flex",
                        alignItems: "center",
                        gap: "6px",
                      }}
                    >
                      <CheckCircle size={16} />
                      Mark Resolved
                    </button>
                  </>
                )}

                {selectedAlert.userPhone && !selectedAlert.isDuress && (
                  <a
                    href={`tel:${selectedAlert.userPhone}`}
                    style={{
                      background: "#334155",
                      color: "#38bdf8",
                      padding: "8px 12px",
                      borderRadius: "6px",
                      fontWeight: "600",
                      fontSize: "13px",
                      display: "flex",
                      alignItems: "center",
                      gap: "6px",
                    }}
                  >
                    <Phone size={16} />
                    Call Citizen
                  </a>
                )}
              </div>
            </div>

            {/* Map Box */}
            <div style={{ flex: 1, minHeight: "450px", background: "#1e293b", borderRadius: "12px", border: "1px solid #334155", overflow: "hidden" }}>
              <SosMap selectedAlert={selectedAlert} alerts={alerts} />
            </div>
          </>
        ) : (
          <div style={{ textAlign: "center", padding: "100px 20px", color: "#64748b" }}>
            <p>Select an emergency alert from the left panel to inspect live telemetry and coordinate response.</p>
          </div>
        )}
      </div>
    </div>
  );
}
