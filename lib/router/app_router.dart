import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/language_select_screen.dart';
import '../features/onboarding/screens/consent_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/officer_login_screen.dart';
import '../features/auth/screens/profile_setup_screen.dart';
import '../features/home_sos/screens/home_shell_screen.dart';
import '../features/home_sos/screens/sos_active_screen.dart';
import '../features/officer/screens/officer_shell_screen.dart';
import '../features/officer/screens/officer_sos_detail_screen.dart';
import '../features/fake_call/screens/fake_call_screen.dart';
import '../features/fake_call/screens/incoming_call_screen.dart';
import '../features/profile/screens/edit_contacts_screen.dart';
import '../features/profile/screens/privacy_policy_screen.dart';
import '../features/trips/screens/active_trip_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectScreen(),
    ),
    GoRoute(
      path: '/consent',
      builder: (context, state) => const ConsentScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/officer-login',
      builder: (context, state) => const OfficerLoginScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/citizen',
      builder: (context, state) {
        final tabIndex = state.extra as int? ?? 0;
        return HomeShellScreen(initialTab: tabIndex);
      },
    ),
    GoRoute(
      path: '/sos-active',
      builder: (context, state) => const SosActiveScreen(),
    ),
    GoRoute(
      path: '/officer',
      builder: (context, state) => const OfficerShellScreen(),
    ),
    GoRoute(
      path: '/officer/sos-detail/:id',
      builder: (context, state) {
        final alertId = state.pathParameters['id'] ?? '';
        return OfficerSosDetailScreen(alertId: alertId);
      },
    ),
    GoRoute(
      path: '/fake-call',
      builder: (context, state) => const FakeCallScreen(),
    ),
    GoRoute(
      path: '/incoming-call',
      builder: (context, state) {
        final caller = state.extra as String? ?? 'Papa';
        return IncomingCallScreen(callerName: caller);
      },
    ),
    GoRoute(
      path: '/edit-contacts',
      builder: (context, state) => const EditContactsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/active-trip',
      builder: (context, state) => const ActiveTripScreen(),
    ),
  ],
);
