import React, { useState, useEffect } from "react";
import { collection, onSnapshot, doc, setDoc, deleteDoc } from "firebase/firestore";
import { db } from "../lib/firebase";
import { Plus, Trash2, Search, CheckCircle, MapPin, Phone, Building } from "lucide-react";

export default function DirectoryManager() {
  const [places, setPlaces] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("ALL");
  const [showAddModal, setShowAddModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // New Place Form State
  const [formData, setFormData] = useState({
    name: "",
    category: "police",
    phone: "",
    address: "",
    lat: "28.6692",
    lng: "77.4538",
    source: "UP Police Official Directory 2026",
  });

  useEffect(() => {
    const unsubscribe = onSnapshot(collection(db, "help_places"), (snapshot) => {
      const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
      setPlaces(list);
    }, (err) => {
      console.warn("Firestore help_places stream notice:", err.message);
    });
    return () => unsubscribe();
  }, []);

  const handleAddPlace = async (e) => {
    e.preventDefault();
    if (!formData.name || !formData.phone) {
      alert("Name and phone are required.");
      return;
    }

    setIsSubmitting(true);
    try {
      const id = "place_" + Date.now();
      await setDoc(doc(db, "help_places", id), {
        id,
        name: formData.name,
        category: formData.category,
        phone: formData.phone,
        address: formData.address,
        lat: parseFloat(formData.lat) || 28.6692,
        lng: parseFloat(formData.lng) || 77.4538,
        source: formData.source || "UP Police Official Directory 2026",
        verifiedAt: new Date().toISOString(),
      });
      setShowAddModal(false);
      setFormData({
        name: "",
        category: "police",
        phone: "",
        address: "",
        lat: "28.6692",
        lng: "77.4538",
        source: "UP Police Official Directory 2026",
      });
      alert("Emergency help place added successfully.");
    } catch (err) {
      alert("Failed to add place: " + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id, name) => {
    if (!confirm(`Are you sure you want to remove "${name}" from verified help places?`)) return;
    try {
      await deleteDoc(doc(db, "help_places", id));
    } catch (err) {
      alert("Failed to delete place: " + err.message);
    }
  };

  const filteredPlaces = places.filter((p) => {
    const matchesSearch =
      (p.name || "").toLowerCase().includes(searchTerm.toLowerCase()) ||
      (p.address || "").toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = categoryFilter === "ALL" || p.category === categoryFilter;
    return matchesSearch && matchesCategory;
  });

  return (
    <div style={{ padding: "24px", maxWidth: "1280px", margin: "0 auto" }}>
      {/* Header */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px", flexWrap: "wrap", gap: "16px" }}>
        <div>
          <h2 style={{ fontSize: "20px", fontWeight: "700" }}>Verified Emergency Help Directory</h2>
          <p style={{ fontSize: "13px", color: "#94a3b8", marginTop: "2px" }}>
            Manage official police stations, women help desks, and emergency medical trauma centers with audit verification
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          style={{
            background: "#3b82f6",
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
          <Plus size={16} />
          Add Verified Place
        </button>
      </div>

      {/* Filter Bar */}
      <div style={{ display: "flex", gap: "12px", marginBottom: "20px" }}>
        <div style={{ position: "relative", flex: 1 }}>
          <Search size={16} style={{ position: "absolute", left: "12px", top: "12px", color: "#94a3b8" }} />
          <input
            type="text"
            placeholder="Search by station name or locality..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              width: "100%",
              background: "#1e293b",
              border: "1px solid #334155",
              borderRadius: "8px",
              padding: "10px 12px 10px 38px",
              color: "#f8fafc",
              fontSize: "13px",
            }}
          />
        </div>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          style={{
            background: "#1e293b",
            color: "#f8fafc",
            border: "1px solid #334155",
            borderRadius: "8px",
            padding: "10px 14px",
            fontSize: "13px",
          }}
        >
          <option value="ALL">All Categories</option>
          <option value="police">Police Stations</option>
          <option value="women_help_desk">Women Help Desks</option>
          <option value="hospital">Hospitals</option>
          <option value="shelter">Shelters</option>
        </select>
      </div>

      {/* Table */}
      <div style={{ background: "#1e293b", borderRadius: "10px", border: "1px solid #334155", overflow: "hidden" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", fontSize: "13px" }}>
          <thead>
            <tr style={{ background: "#0f172a", borderBottom: "1px solid #334155", color: "#94a3b8" }}>
              <th style={{ padding: "12px 16px" }}>Facility Name</th>
              <th style={{ padding: "12px 16px" }}>Category</th>
              <th style={{ padding: "12px 16px" }}>Helpline / Phone</th>
              <th style={{ padding: "12px 16px" }}>Address / Zone</th>
              <th style={{ padding: "12px 16px" }}>Verification Source</th>
              <th style={{ padding: "12px 16px", textAlign: "right" }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredPlaces.length === 0 ? (
              <tr>
                <td colSpan={6} style={{ padding: "40px", textAlign: "center", color: "#64748b" }}>
                  No verified directory entries found. Use "Add Verified Place" to insert official entries.
                </td>
              </tr>
            ) : (
              filteredPlaces.map((p) => (
                <tr key={p.id} style={{ borderBottom: "1px solid #334155" }}>
                  <td style={{ padding: "12px 16px", fontWeight: "600", color: "#f8fafc" }}>
                    {p.name}
                  </td>
                  <td style={{ padding: "12px 16px" }}>
                    <span style={{
                      padding: "2px 8px",
                      borderRadius: "4px",
                      fontSize: "11px",
                      fontWeight: "700",
                      background: p.category === "women_help_desk" ? "rgba(236, 72, 153, 0.2)" : "rgba(59, 130, 246, 0.2)",
                      color: p.category === "women_help_desk" ? "#f472b6" : "#60a5fa",
                    }}>
                      {(p.category || "police").replace("_", " ").toUpperCase()}
                    </span>
                  </td>
                  <td style={{ padding: "12px 16px", color: "#38bdf8" }}>
                    <a href={`tel:${p.phone}`} style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                      <Phone size={13} />
                      {p.phone}
                    </a>
                  </td>
                  <td style={{ padding: "12px 16px", color: "#cbd5e1" }}>
                    {p.address}
                  </td>
                  <td style={{ padding: "12px 16px" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: "6px", color: "#34d399", fontSize: "12px" }}>
                      <CheckCircle size={14} />
                      <span>{p.source || "Official Govt Source"}</span>
                    </div>
                    {p.verifiedAt && (
                      <div style={{ fontSize: "11px", color: "#64748b", marginTop: "2px" }}>
                        Verified: {new Date(p.verifiedAt).toLocaleDateString()}
                      </div>
                    )}
                  </td>
                  <td style={{ padding: "12px 16px", textAlign: "right" }}>
                    <button
                      onClick={() => handleDelete(p.id, p.name)}
                      title="Delete entry"
                      style={{
                        background: "transparent",
                        color: "#ef4444",
                        padding: "4px 8px",
                        borderRadius: "4px",
                      }}
                    >
                      <Trash2 size={16} />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Add Modal */}
      {showAddModal && (
        <div style={{
          position: "fixed",
          inset: 0,
          background: "rgba(0,0,0,0.7)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 2000,
          padding: "20px",
        }}>
          <div style={{
            background: "#1e293b",
            borderRadius: "12px",
            border: "1px solid #334155",
            width: "100%",
            maxWidth: "500px",
            padding: "24px",
          }}>
            <h3 style={{ fontSize: "18px", fontWeight: "700", marginBottom: "16px" }}>
              Add Verified Emergency Help Place
            </h3>

            <form onSubmit={handleAddPlace} style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
              <div>
                <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Facility Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Mahila Thana Kavi Nagar"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                />
              </div>

              <div>
                <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Category</label>
                <select
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                >
                  <option value="police">Police Station</option>
                  <option value="women_help_desk">Women Help Desk</option>
                  <option value="hospital">Hospital / Emergency Ward</option>
                  <option value="shelter">Women Shelter / Support Home</option>
                </select>
              </div>

              <div>
                <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Official Helpline Phone</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. 0120-2820100"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                />
              </div>

              <div>
                <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Official Address / Locality</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Sector 23, Sanjay Nagar, Ghaziabad"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                />
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "10px" }}>
                <div>
                  <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Latitude</label>
                  <input
                    type="number"
                    step="0.0001"
                    value={formData.lat}
                    onChange={(e) => setFormData({ ...formData, lat: e.target.value })}
                    style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                  />
                </div>
                <div>
                  <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Longitude</label>
                  <input
                    type="number"
                    step="0.0001"
                    value={formData.lng}
                    onChange={(e) => setFormData({ ...formData, lng: e.target.value })}
                    style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: "12px", color: "#94a3b8", display: "block", marginBottom: "4px" }}>Verification Source</label>
                <input
                  type="text"
                  value={formData.source}
                  onChange={(e) => setFormData({ ...formData, source: e.target.value })}
                  style={{ width: "100%", background: "#0f172a", border: "1px solid #475569", borderRadius: "6px", padding: "8px 10px", color: "#f8fafc" }}
                />
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px", marginTop: "12px" }}>
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  style={{ background: "#334155", color: "#cbd5e1", padding: "8px 14px", borderRadius: "6px" }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  style={{ background: "#3b82f6", color: "#ffffff", padding: "8px 16px", borderRadius: "6px", fontWeight: "600" }}
                >
                  Save & Verify
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
