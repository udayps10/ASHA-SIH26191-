import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/app_state.dart';
import '../../../data/models/auth_status.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minimumDisplayTime = Duration(milliseconds: 900);
  late final DateTime _startedAt;
  Timer? _minimumTimer;
  AppState? _appState;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _appState = context.read<AppState>();
      _appState!.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    });
  }

  @override
  void dispose() {
    _minimumTimer?.cancel();
    _appState?.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    final state = context.read<AppState>();
    if (state.status == AuthStatus.loading) return;

    final remaining =
        _minimumDisplayTime - DateTime.now().difference(_startedAt);
    if (remaining > Duration.zero) {
      _minimumTimer?.cancel();
      _minimumTimer = Timer(remaining, _onAuthStateChanged);
      return;
    }

    final route = switch (state.status) {
      AuthStatus.authenticatedOfficial => '/official_dashboard',
      AuthStatus.authenticatedVerified => '/user_home',
      AuthStatus.authenticatedUnverified => '/verify_email',
      AuthStatus.authenticatedOfficialPending => '/pending_approval',
      AuthStatus.profileError => '/profile_error',
      _ => '/welcome',
    };
    if (ModalRoute.of(context)?.settings.name == '/') {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha(90)),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 68,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Together, we find the way home.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
