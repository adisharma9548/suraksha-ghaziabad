import React, { useEffect, useRef } from "react";

export default function SosMap({ selectedAlert, alerts }) {
  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const markersRef = useRef([]);

  useEffect(() => {
    if (typeof window === "undefined" || !mapContainerRef.current) return;

    // Dynamically load leaflet
    import("leaflet").then((L) => {
      // Fix leaflet marker icon path
      delete L.Icon.Default.prototype._getIconUrl;
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png",
        iconUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png",
        shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
      });

      if (!mapInstanceRef.current) {
        const defaultCenter = [28.6692, 77.4538]; // Ghaziabad Center
        const map = L.map(mapContainerRef.current).setView(defaultCenter, 13);

        L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          maxZoom: 19,
        }).addTo(map);

        mapInstanceRef.current = map;
      }

      const map = mapInstanceRef.current;

      // Clear existing markers
      markersRef.current.forEach((m) => map.removeLayer(m));
      markersRef.current = [];

      // Render alerts
      alerts.forEach((alert) => {
        const locations = alert.locations || [];
        const loc = locations.length > 0 ? locations[locations.length - 1] : { lat: 28.6692, lng: 77.4538 };

        const isDuress = alert.isDuress || alert.status === "duress_active";
        const isSelected = selectedAlert && selectedAlert.id === alert.id;

        const color = isDuress ? "#dc2626" : alert.status === "resolved" ? "#10b981" : "#f59e0b";

        const circleMarker = L.circleMarker([loc.lat, loc.lng], {
          radius: isSelected ? 12 : 8,
          fillColor: color,
          color: "#ffffff",
          weight: 2,
          opacity: 1,
          fillOpacity: 0.85,
        }).addTo(map);

        circleMarker.bindPopup(`
          <div style="font-family: sans-serif; min-width: 180px;">
            <strong style="color: ${color};">${isDuress ? "⚠️ SILENT DURESS ALERT" : "🚨 SOS DISTRESS"}</strong><br/>
            <strong>Citizen:</strong> ${alert.userName || "Distress Caller"}<br/>
            <strong>Phone:</strong> ${alert.userPhone || "Not provided"}<br/>
            <strong>Status:</strong> ${alert.status}<br/>
            <strong>Coordinates:</strong> ${loc.lat.toFixed(4)}, ${loc.lng.toFixed(4)}
          </div>
        `);

        markersRef.current.push(circleMarker);

        // If breadcrumbs exist, render polyline
        if (locations.length > 1) {
          const latLngs = locations.map((p) => [p.lat, p.lng]);
          const polyline = L.polyline(latLngs, {
            color: isDuress ? "#ef4444" : "#3b82f6",
            weight: 3,
            dashArray: "5, 5",
          }).addTo(map);
          markersRef.current.push(polyline);
        }
      });

      // Pan to selected alert
      if (selectedAlert) {
        const locs = selectedAlert.locations || [];
        if (locs.length > 0) {
          const target = locs[locs.length - 1];
          map.setView([target.lat, target.lng], 15, { animate: true });
        }
      }
    });
  }, [alerts, selectedAlert]);

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", borderRadius: "8px", overflow: "hidden" }}>
      {/* Leaflet CSS CDN injection */}
      <link
        rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"
      />
      <div ref={mapContainerRef} style={{ width: "100%", height: "100%", minHeight: "420px" }} />
    </div>
  );
}
