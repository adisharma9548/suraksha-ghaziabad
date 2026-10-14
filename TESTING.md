# 🧪 Manual Verification & Testing Guide

This document details the step-by-step manual testing procedures for evaluating **Suraksha Ghaziabad** during the **Ghaziabad Seva First Innovation Challenge 2026**.

---

## 📋 Test Suite Index
- **Test 1**: Onboarding, Language Selection & Consent
- **Test 2**: Citizen Login & Profile Setup
- **Test 3**: SOS Flow (Trigger, 5s Countdown & False Alarm Cancellation with PIN)
- **Test 4**: End-to-End SOS Dispatch Lifecycle (Citizen ➔ Control Room ➔ Nearest Patrol Unit ➔ Resolved)
- **Test 5**: District Safety Heatmap & Citizen Hazard Spot Reporting
- **Test 6**: Safe Trip Sharing & "Are you OK?" 60s Auto-Check
- **Test 7**: Discreet Fake Call Simulation
- **Test 8**: Officer Control Room (Feed, Patrol Fleet & Analytics)
- **Test 9**: Data Privacy & "Delete My Data"

---

## Test 1: Onboarding, Language Selection & Consent
1. Launch the app (`flutter run`).
2. Verify the animated splash screen displays the circular shield + location pin emblem, app title, and tagline *"Aapki Suraksha, Hamari Zimmedari"*.
3. Tap on **"हिंदी (Hindi)"** on the Language Selection screen. Verify the interface instantly transforms into Hindi.
4. Select **"English"** and tap **"Continue"**.
5. On the **Safety Permissions & Consent** screen:
   - Verify plain-language explanations for Location, Microphone, SMS, and Notifications.
   - Confirm the explicit privacy statement: *"Location is shared ONLY during an active SOS or live trip, never continuously."*
   - Check the consent box and tap **"Accept & Continue"**.

---

## Test 2: Citizen Login & Profile Setup
1. Enter any 10-digit phone number (default: `9876543210`).
2. Tap **"Send OTP"**.
3. Verify the OTP field auto-fills with demo OTP `123456`.
4. Tap **"Verify & Login"**.
5. On the Profile Setup screen:
   - Enter your name (e.g. `Aditi Sharma`).
   - Enter and confirm a 4-digit Emergency PIN: `1234`.
   - Verify default emergency contacts (Maa, Bhaiya) are pre-populated.
   - Tap **"Save"**. You will enter the Citizen Home screen.

---

## Test 3: SOS Flow & PIN Cancellation
1. On the Citizen Home screen, observe the large circular red **SOS button** pulsing smoothly.
2. Observe the status banner reads: **"STATUS: SAFE & PROTECTED"**.
3. **Short Tap**: Tap the button once. Verify a confirmation modal appears warning of emergency dispatch.
4. Tap **"Cancel"** to dismiss.
5. **Hold 2 Seconds**: Press and hold the SOS button.
   - Notice the circular hold progress ring fills with haptic feedback ticks.
   - At 2 seconds, the screen navigates to the **SOS Active** screen.
6. On the SOS Active screen:
   - Notice the 5-second countdown banner (`Seconds left to cancel: 5s`).
   - Notice the indicators show **"Live GPS location is being streamed"** and **"Ambient audio recording active"**.
7. Tap **"Cancel Alert (PIN Required)"**.
8. In the dialog, enter the incorrect PIN `9999` and tap **"Confirm Cancel"**. Verify the error *"Incorrect Emergency PIN"* is shown.
9. Enter the correct PIN `1234` and tap **"Confirm Cancel"**.
10. Verify the alert cancels immediately, recording and location stop, and you return safely to the Home screen.

---

## Test 4: End-to-End SOS Emergency Dispatch Lifecycle
1. Trigger the SOS button again (Hold 2 seconds).
2. Allow the 5-second cancel countdown to reach 0.
3. Verify Step 1 shows completed: *"Alert Sent - GPS coordinates and emergency SMS dispatched"*.
4. **Single-Device Pitch Demo**:
   - Scroll to the **"Pitch Demo Control"** box.
   - Tap **"Simulate Police Response (Demo)"**.
   - Watch Step 2 turn green: *"Police Control Room Notified"*.
   - Tap **"Simulate Police Response (Demo)"** again.
   - Watch Step 3 highlight green: *"Help is on the way: Cheetah-12 (Indirapuram PCR)"* with officer contact number.
   - Tap **"Simulate Police Response (Demo)"** a third time.
   - Watch Step 4 turn green: *"Situation Resolved"*.
   - Notice location sharing and audio recording stop automatically.
   - Tap **"Back to Home"**.

---

## Test 5: District Safety Heatmap & Spot Reporting
1. Tap the **"Safety Map"** tab in the bottom navigation.
2. Verify the OpenStreetMap raster tiles load centered on Ghaziabad without any paid API key.
3. Observe the dynamic canvas heatmap layer rendering red and amber gradient heat blobs across Ghaziabad neighborhoods (Raj Nagar, Vaishali, Indirapuram, Crossings Republik, etc.).
4. Tap the **"Heatmap ON / Pins Only"** toggle button. Verify you can toggle between radial heat overlay and pinpoint markers.
5. Filter by category (e.g. tap **"Harassment"** or **"Broken streetlight"**). Verify markers filter immediately.
6. Tap any pin marker. A bottom sheet will open with:
   - Incident category, status badge (Open / In progress / Fixed), location description, and MCD/Police action notes.
   - Tap **"Directions"** to verify Google Maps route navigation intent.
7. Switch to the **"Report Spot"** tab:
   - Select locality: `Raj Nagar (RDC Concrete Market)`.
   - Select category: `Broken streetlight`.
   - Select Time: `Night`.
   - Set severity slider to Level 4.
   - Enter description: `Three streetlights non-functional near coaching corner.`
   - Ensure **"Submit Anonymously"** is checked.
   - Tap **"Submit"**.
   - Verify toast confirmation appears and the spot is immediately plotted onto the heatmap.

---

## Test 6: Live Trip Sharing & "Are you OK?" Auto-Check
1. Tap the **"Trip Safe"** tab in the bottom navigation.
2. Select a destination preset: `Vaishali Metro Station (Gate 2)`.
3. Verify your trusted emergency contacts are listed.
4. Tap **"Start Protected Trip"**.
5. On the active trip screen, verify the start position, destination pin, and connecting route polyline are visible.
6. Tap **"Simulate Stop Check"** (or wait for the demo timer):
   - A modal dialog appears: *"Are you OK? Your vehicle appears stationary or off-route."*
   - Observe the 60-second emergency countdown timer ticking down.
7. Tap **"I AM SAFE"**. Verify the dialog dismisses and trip continues normally.
8. Tap **"I Reached Safely"**. Verify trip completes and returns to home.

---

## Test 7: Discreet Fake Call Simulation
1. On the Home screen, tap the **"Fake Call"** quick tile.
2. Select Caller Name: `Papa`.
3. Select delay: `5s`.
4. Tap **"Trigger Call in 5s"**.
5. Wait 5 seconds.
6. Verify the fullscreen authentic Android incoming call screen appears with haptic ring vibrations.
7. Tap the green **"Answer"** button.
8. Notice the in-call timer begins (`00:01`, `00:02`...) and the scripted audio prompt appears: *"Haan beta, kahan ho? Main bas 2 minute mein car leke pahunch raha hoon. Wait karna."*
9. Tap the red **"End Call"** button to safely return.

---

## Test 8: Officer Mode & Analytics
1. Go to **Profile > Demo & Innovation Challenge Mode > Police Officer Command Portal** (or log in via the Officer Login link with `OFFICER01` / `1234`).
2. **Live SOS Feed Tab**:
   - View real-time distress alerts sorted newest first with status badges (`PENDING DISPATCH`, `DISPATCHED`).
   - Tap any alert to open the **SOS Detail** screen.
   - On the detail screen, inspect the live moving location breadcrumbs, citizen contact, audio evidence player, and tap **"Assign Unit"**.
   - Select the nearest unit (e.g. `Pink Panther-01`) and tap **"DISPATCH"**.
3. **Patrols Tab**:
   - Inspect available patrol vans (Cheetah-12, Pink Panther-01, Hawk-02).
   - Toggle availability switches on/off.
4. **Reports Review Tab**:
   - Tap any citizen report.
   - Change status from `Open` to `Fixed`, write an action note (e.g. *"Streetlight replaced by MCD electrical team"*), and tap **"Update & Notify"**.
5. **Analytics Tab**:
   - Review Top KPI metrics (Total Reports, 3.4 min Avg Response Time, Resolution Rate).
   - Review the Reports by Category percentage bars.
   - Review the Reports by Time of Day distribution (Night vs Evening).
   - Review the Top 10 High-Risk Unsafe Zones in Ghaziabad.

---

## Test 9: Data Privacy & "Delete My Data"
1. Switch back to Citizen App via the top bar switch.
2. Navigate to **Profile > Delete My Data**.
3. Tap **"DELETE FOREVER"** on the confirmation dialog.
4. Verify all local storage and credentials are deleted, and the app resets to the initial onboarding screen.
