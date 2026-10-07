import 'features/official/presentation/relocation_planning_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/models/app_user.dart';
import 'data/models/normal_record.dart';
import 'data/models/disaster_record.dart';
import 'data/models/critical_record.dart';
import 'data/models/camp.dart';
import 'data/models/auth_status.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/verify_email_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/pending_approval_screen.dart';
import 'features/auth/presentation/profile_error_screen.dart';
import 'features/user/presentation/home_screen.dart';
import 'features/official/presentation/dashboard_screen.dart';

// Import placeholders to ensure they exist or will exist
import 'features/user/presentation/search_form_screen.dart';
import 'features/user/presentation/results_screen.dart';
import 'features/user/presentation/critical_results_screen.dart';
import 'features/official/presentation/add_record_screen.dart';
import 'features/official/presentation/manage_camps_screen.dart';
import 'features/official/presentation/add_camp_screen.dart';
import 'features/official/presentation/camp_details_screen.dart';
import 'features/official/presentation/normal_records_list_screen.dart';
import 'features/official/presentation/normal_record_details_screen.dart';
import 'features/official/presentation/critical_records_list_screen.dart';
import 'features/official/presentation/critical_record_details_screen.dart';
import 'features/official/presentation/add_critical_record_screen.dart';
import 'features/official/presentation/search_records_screen.dart';
import 'features/official/presentation/recent_records_screen.dart';
import 'features/official/presentation/pending_sync_screen.dart';
import 'features/official/presentation/sos_requests_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/emergency/presentation/emergency_alerts_screen.dart';
import 'features/emergency/presentation/emergency_alert_detail_screen.dart';
import 'features/emergency/data/models/emergency_alert.dart';
import 'features/emergency/data/models/disaster_zone.dart';
import 'features/emergency/presentation/safety_map_screen.dart';
import 'features/emergency/presentation/sos_screen.dart';
import 'features/emergency/presentation/emergency_center_screen.dart';

class DisasterConnectApp extends StatefulWidget {
  const DisasterConnectApp({super.key});

  @override
  State<DisasterConnectApp> createState() => _DisasterConnectAppState();
}

class _DisasterConnectAppState extends State<DisasterConnectApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, state, child) {
          return MaterialApp(
            title: AppStrings.appName,
            navigatorKey: _navigatorKey,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login_normal': (context) =>
                  const LoginScreen(role: UserRole.user),
              '/login_official': (context) =>
                  const LoginScreen(role: UserRole.official),
              '/register': (context) => const RegisterScreen(),
              '/verify_email': (context) => const VerifyEmailScreen(),
              '/forgot_password': (context) => const ForgotPasswordScreen(),
              '/pending_approval': (context) => const PendingApprovalScreen(),
              '/profile_error': (context) => const ProfileErrorScreen(),
              '/user_home': (context) => const UserHomeScreen(),
              '/official_dashboard': (context) =>
                  const OfficialDashboardScreen(),
              '/search_form': (context) => const SearchFormScreen(),
              '/results': (context) => const ResultsScreen(),
              '/critical_results': (context) => const CriticalResultsScreen(),
              '/add_normal': (context) =>
                  const AddRecordScreen(type: RecordType.normal),
              '/add_critical': (context) => const AddCriticalRecordScreen(),
              '/critical_records_list': (context) =>
                  const CriticalRecordsListScreen(),
              '/critical_record_details': (context) {
                final record =
                    ModalRoute.of(context)!.settings.arguments
                        as CriticalRecord;
                return CriticalRecordDetailsScreen(record: record);
              },
              '/official_search': (context) => const SearchRecordsScreen(),
              '/recent_records': (context) => const RecentRecordsScreen(),
              '/normal_records_list': (context) =>
                  const NormalRecordsListScreen(),
              '/normal_record_details': (context) {
                final record =
                    ModalRoute.of(context)!.settings.arguments as NormalRecord;
                return NormalRecordDetailsScreen(record: record);
              },
              '/pending_sync': (context) => const PendingSyncScreen(),
              '/sos_requests': (context) => const SosRequestsScreen(),
              '/relocation_planning': (context) =>
                  const RelocationPlanningScreen(),
              '/manage_camps': (context) => const ManageCampsScreen(),
              '/add_camp': (context) => const AddCampScreen(),
              '/edit_camp': (context) {
                final camp = ModalRoute.of(context)!.settings.arguments as Camp;
                return AddCampScreen(camp: camp);
              },
              '/camp_details': (context) {
                final camp = ModalRoute.of(context)!.settings.arguments as Camp;
                return CampDetailsScreen(camp: camp);
              },
              '/profile': (context) => const ProfileScreen(),
              '/emergency_alerts': (context) => const EmergencyAlertsScreen(),
              '/emergency_alert_detail': (context) =>
                  EmergencyAlertDetailScreen(
                    alert:
                        ModalRoute.of(context)!.settings.arguments
                            as EmergencyAlert,
                  ),
              '/safety_map': (context) => SafetyMapScreen(
                initialDisaster:
                    ModalRoute.of(context)?.settings.arguments as DisasterZone?,
              ),
              '/sos': (context) => const SosScreen(),
              '/emergency_center': (context) => const EmergencyCenterScreen(),
            },
            // Logic to redirect based on auth state
            builder: (context, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final navigator = _navigatorKey.currentState;
                if (navigator == null) return;

                // Get the current route name using navigator state
                String? currentRoute;
                navigator.popUntil((route) {
                  currentRoute = route.settings.name;
                  return true;
                });

                if (state.status == AuthStatus.loading) {
                  // Stay or go to splash if loading
                  if (currentRoute != '/' && currentRoute != '/splash') {
                    // Optionally show a global loading overlay or stay put
                  }
                  return;
                }

                if (state.status == AuthStatus.unauthenticated) {
                  // If not on welcome/login/register/forgot, go to welcome
                  final publicRoutes = [
                    '/welcome',
                    '/login_normal',
                    '/login_official',
                    '/register',
                    '/forgot_password',
                    '/',
                  ];
                  if (!publicRoutes.contains(currentRoute)) {
                    navigator.pushNamedAndRemoveUntil(
                      '/welcome',
                      (route) => false,
                    );
                  }
                  return;
                }

                if (state.status == AuthStatus.authenticatedUnverified) {
                  if (currentRoute != '/verify_email') {
                    navigator.pushNamedAndRemoveUntil(
                      '/verify_email',
                      (route) => false,
                    );
                  }
                  return;
                }

                if (state.status == AuthStatus.authenticatedOfficialPending) {
                  if (currentRoute != '/pending_approval') {
                    navigator.pushNamedAndRemoveUntil(
                      '/pending_approval',
                      (route) => false,
                    );
                  }
                  return;
                }

                if (state.status == AuthStatus.profileError) {
                  if (currentRoute != '/profile_error') {
                    navigator.pushNamedAndRemoveUntil(
                      '/profile_error',
                      (route) => false,
                    );
                  }
                  return;
                }

                // If authenticated and verified, redirect away from auth screens
                final authRoutes = [
                  '/welcome',
                  '/login_normal',
                  '/login_official',
                  '/register',
                  '/forgot_password',
                  '/',
                  '/verify_email',
                  '/pending_approval',
                  '/profile_error',
                ];
                if (authRoutes.contains(currentRoute)) {
                  if (state.status == AuthStatus.authenticatedVerified) {
                    navigator.pushNamedAndRemoveUntil(
                      '/user_home',
                      (route) => false,
                    );
                  } else if (state.status == AuthStatus.authenticatedOfficial) {
                    navigator.pushNamedAndRemoveUntil(
                      '/official_dashboard',
                      (route) => false,
                    );
                  }
                }
              });
              return child!;
            },
          );
        },
      ),
    );
  }
}
