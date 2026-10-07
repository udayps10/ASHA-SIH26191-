import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/app_user.dart';
import '../data/models/auth_status.dart';
import '../features/auth/data/auth_service.dart';
import '../data/repositories/user_repository.dart';
import '../data/sync/sync_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();
  final SyncService syncService = SyncService.instance;

  AppUser? _userProfile;
  AuthStatus _status = AuthStatus.loading;

  AppState() {
    _init();
    syncService.addListener(_onSyncChanged);
  }

  void _onSyncChanged() => notifyListeners();

  AuthStatus get status => _status;
  AppUser? get userProfile => _userProfile;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _authService.isLoggedIn;
  String? get token => _authService.token;
  String? get uid => _authService.uid;

  // Compatibility getter for screens that reference firebaseUser
  dynamic get firebaseUser => _authService.isLoggedIn ? _FirebaseUserProxy(_authService) : null;

  Future<void> _init() async {
    final autoLoggedIn = await _authService.tryAutoLogin();
    if (autoLoggedIn && _authService.token != null) {
      _userProfile = AppUser(
        id: _authService.uid ?? '',
        name: _authService.name ?? '',
        email: _authService.email ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.name == (_authService.role ?? 'user'),
          orElse: () => UserRole.user,
        ),
        approved: _authService.approved ?? true,
      );
      _updateStatus();
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _updateStatus() {
    if (!_authService.isLoggedIn) {
      _status = AuthStatus.unauthenticated;
      return;
    }

    if (_userProfile == null) {
      _status = AuthStatus.profileError;
      return;
    }

    if (_userProfile!.role == UserRole.official) {
      _status = _userProfile!.approved
          ? AuthStatus.authenticatedOfficial
          : AuthStatus.authenticatedOfficialPending;
    } else {
      _status = AuthStatus.authenticatedVerified;
    }
  }

  Future<String?> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final error = await _authService.signIn(email: email, password: password);

    if (error == null && _authService.isLoggedIn) {
      _userProfile = AppUser(
        id: _authService.uid ?? '',
        name: _authService.name ?? '',
        email: _authService.email ?? '',
        role: UserRole.values.firstWhere(
          (e) => e.name == (_authService.role ?? 'user'),
          orElse: () => UserRole.user,
        ),
        approved: _authService.approved ?? true,
      );
    }

    _updateStatus();
    notifyListeners();
    return error;
  }

  Future<String?> register(String email, String password, String name, {String? phone, String role = 'user'}) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final error = await _authService.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );

    if (error == null && _authService.isLoggedIn) {
      _userProfile = AppUser(
        id: _authService.uid ?? '',
        name: name,
        email: email,
        phone: phone,
        role: UserRole.values.firstWhere(
          (e) => e.name == role,
          orElse: () => UserRole.user,
        ),
        approved: _authService.approved ?? true,
      );
    }

    _updateStatus();
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await syncService.stopSession();
    await _authService.signOut();
    _userProfile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<String?> resetPassword(String email) async {
    return 'Password reset is managed through the website.';
  }

  Future<String?> resendVerificationEmail() async {
    return null;
  }

  Future<void> refreshEmailVerification() async {
    // No email verification needed with MySQL auth
  }
}

class _FirebaseUserProxy {
  final AuthService _auth;
  _FirebaseUserProxy(this._auth);

  String? get uid => _auth.uid;
  String? get email => _auth.email;
  String? get displayName => _auth.name;
  bool get emailVerified => true; // Always verified with MySQL auth
}
