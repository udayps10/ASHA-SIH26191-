import 'dart:async';

import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start local storage independently
  unawaited(
    LocalDatabase.instance.initialize().catchError((error, stackTrace) {
      debugPrint('Local database initialization failed: $error');
    }),
  );

  runApp(const DisasterConnectApp());
}
