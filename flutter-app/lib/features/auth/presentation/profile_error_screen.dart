import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../core/common_widgets/app_button.dart';

class ProfileErrorScreen extends StatelessWidget {
  const ProfileErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Error')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Profile Not Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We could not find your user profile. This may happen if your account was not fully set up.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Try Again / Refresh',
              onPressed: () => context.read<AppState>().refreshEmailVerification(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<AppState>().logout(),
              child: const Text('Back to Login', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
