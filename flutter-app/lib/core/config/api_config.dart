class ApiConfig {
  ApiConfig._();

  /// Development backend address used by the Android emulator.
  static const androidEmulatorBaseUrl = 'http://10.0.2.2:8080';

  /// Development backend address used by a physical Android phone on the
  /// same LAN as the development PC.
  static const physicalAndroidBaseUrl = 'http://192.168.1.33:8080';
  /// Override with --dart-define=API_BASE_URL=... for a physical
  /// device or a future HTTPS production deployment.
  /// 
  /// TEMPORARY: Defaulting to physical IP for urgent debug.
  static const matchingBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: physicalAndroidBaseUrl,
  );
}
