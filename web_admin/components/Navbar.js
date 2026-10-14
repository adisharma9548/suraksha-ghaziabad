import React from "react";
import { Shield, Radio, Volume2, VolumeX, LogOut, UserCheck } from "lucide-react";

export default function Navbar({ activeTab, setActiveTab, user, onSignOut, soundEnabled, setSoundEnabled, activeSosCount }) {
  return (
    <header style={{
      background: "#1e293b",
      borderBottom: "1px solid #334155",
      padding: "12px 24px",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      position: "sticky",
      top: 0,
      zIndex: 1000,
      boxShadow: "0 4px 6px -1px rgba(0, 0, 0, 0.3)"
    }}>
      {/* Brand & Live status */}
      <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
        <div style={{
          background: "linear-gradient(135deg, #b91c1c, #dc2626)",
          padding: "10px",
          borderRadius: "8px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center"
        }}>
          <Shield size={24} color="#ffffff" />
        </div>
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
            <h1 style={{ fontSize: "18px", fontWeight: "700", color: "#ffffff", letterSpacing: "0.5px" }}>
              SURAKSHA GHAZIABAD
            </h1>
            <span style={{
              fontSize: "10px",
              padding: "2px 8px",
              borderRadius: "4px",
              background: "#0284c7",
              color: "#ffffff",
              fontWeight: "700"
            }}>
              CONTROL ROOM
            </span>
          </div>
          <p style={{ fontSize: "12px", color: "#94a3b8" }}>
            UP Police 112 Complementary District Safety Operations Center
          </p>
        </div>
      </div>

      {/* Tabs */}
      <nav style={{ display: "flex", gap: "6px" }}>
        {[
          { id: "sos", label: "🚨 Live SOS", badge: activeSosCount > 0 ? activeSosCount : null },
          { id: "reports", label: "📋 Reports Queue" },
          { id: "directory", label: "📍 Directory" },
          { id: "officers", label: "👮 Officers" },
          { id: "analytics", label: "📊 Analytics" },
          { id: "audit", label: "📜 Audit Logs" },
        ].map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              style={{
                padding: "8px 14px",
                borderRadius: "6px",
                fontSize: "13px",
                fontWeight: "600",
                background: isActive ? "#3b82f6" : "transparent",
                color: isActive ? "#ffffff" : "#94a3b8",
                display: "flex",
                alignItems: "center",
                gap: "6px",
                transition: "all 0.15s ease",
              }}
            >
              {tab.label}
              {tab.badge && (
                <span style={{
                  background: "#ef4444",
                  color: "#ffffff",
                  fontSize: "11px",
                  fontWeight: "700",
                  padding: "1px 6px",
                  borderRadius: "9999px",
                }}>
                  {tab.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Controls & Officer Profile */}
      <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
        <button
          onClick={() => setSoundEnabled(!soundEnabled)}
          title={soundEnabled ? "Mute Siren Alerts" : "Enable Siren Alerts"}
          style={{
            background: soundEnabled ? "rgba(239, 68, 68, 0.2)" : "rgba(100, 116, 139, 0.2)",
            border: `1px solid ${soundEnabled ? "#ef4444" : "#64748b"}`,
            color: soundEnabled ? "#f87171" : "#94a3b8",
            padding: "8px 12px",
            borderRadius: "6px",
            display: "flex",
            alignItems: "center",
            gap: "6px",
            fontSize: "12px",
            fontWeight: "600",
          }}
        >
          {soundEnabled ? <Volume2 size={16} /> : <VolumeX size={16} />}
          <span>{soundEnabled ? "Siren ON" : "Muted"}</span>
        </button>

        {user && (
          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <div style={{ textAlign: "right" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "6px", justifyContent: "flex-end" }}>
                <UserCheck size={14} color="#10b981" />
                <span style={{ fontSize: "13px", fontWeight: "600", color: "#f1f5f9" }}>
                  {user.displayName || user.email || "Control Officer"}
                </span>
              </div>
              <span style={{ fontSize: "11px", color: "#38bdf8", fontWeight: "700" }}>
                {user.role ? user.role.toUpperCase() : "OFFICER"} (2FA VERIFIED)
              </span>
            </div>
            <button
              onClick={onSignOut}
              title="Sign Out"
              style={{
                background: "#334155",
                color: "#f87171",
                padding: "8px",
                borderRadius: "6px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <LogOut size={16} />
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
