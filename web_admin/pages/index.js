import React, { useState, useEffect } from "react";
import Head from "next/head";
import Navbar from "../components/Navbar";
import LoginModal from "../components/LoginModal";
import SosBoard from "../components/SosBoard";
import ReportsQueue from "../components/ReportsQueue";
import DirectoryManager from "../components/DirectoryManager";
import OfficerManager from "../components/OfficerManager";
import AnalyticsView from "../components/AnalyticsView";
import AuditLogViewer from "../components/AuditLogViewer";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { auth, db } from "../lib/firebase";
import { collection, query, where, onSnapshot } from "firebase/firestore";

export default function AdminDashboard() {
  const [user, setUser] = useState(null);
  const [activeTab, setActiveTab] = useState("sos");
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [activeSosCount, setActiveSosCount] = useState(0);

  // Auth state listener
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (fbUser) => {
      if (fbUser) {
        try {
          const tokenResult = await fbUser.getIdTokenResult();
          setUser({
            ...fbUser,
            role: tokenResult.claims.role || "officer",
            twoFactorVerified: true,
          });
        } catch (e) {
          setUser(fbUser);
        }
      }
    });
    return () => unsubscribe();
  }, []);

  // Listen for active SOS count for Navbar badge
  useEffect(() => {
    if (!user) return;
    const q = query(collection(db, "sos_alerts"), where("status", "!=", "resolved"));
    const unsubscribe = onSnapshot(q, (snap) => {
      setActiveSosCount(snap.docs.length);
    }, (err) => {
      console.warn("Notice: Firestore active alerts subscription:", err.message);
    });
    return () => unsubscribe();
  }, [user]);

  const handleSignOut = async () => {
    try {
      await signOut(auth);
    } catch (e) {
      console.warn("Sign out error:", e);
    }
    setUser(null);
  };

  if (!user) {
    return <LoginModal onAuthenticated={setUser} />;
  }

  return (
    <div style={{ minHeight: "100vh", display: "flex", flexDirection: "column", background: "#0f172a" }}>
      <Head>
        <title>Suraksha Ghaziabad | Police & Municipal Control Room</title>
        <meta name="description" content="District Women Safety Integrated Operations Command Center" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Navbar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        user={user}
        onSignOut={handleSignOut}
        soundEnabled={soundEnabled}
        setSoundEnabled={setSoundEnabled}
        activeSosCount={activeSosCount}
      />

      <main style={{ flex: 1 }}>
        {activeTab === "sos" && <SosBoard soundEnabled={soundEnabled} />}
        {activeTab === "reports" && <ReportsQueue />}
        {activeTab === "directory" && <DirectoryManager />}
        {activeTab === "officers" && <OfficerManager currentUser={user} />}
        {activeTab === "analytics" && <AnalyticsView />}
        {activeTab === "audit" && <AuditLogViewer />}
      </main>
    </div>
  );
}
