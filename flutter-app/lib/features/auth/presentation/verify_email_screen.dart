import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../data/models/auth_status.dart';
import '../../../core/common_widgets/app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Please verify your email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'A verification link has been sent to:',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              '${state.firebaseUser?.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please check your inbox and click the link to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: "I've Verified My Email",
              isLoading: state.status == AuthStatus.loading,
              onPressed: () async {
                if (state.status == AuthStatus.loading) return;
                await state.refreshEmailVerification();
                if (!mounted) return;
                if (state.status == AuthStatus.authenticatedUnverified) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your email is not verified yet. Please verify it and try again.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Resend Verification Email',
              isLoading: _isResending,
              color: Colors.blueGrey,
              onPressed: () async {
                if (_isResending) return;
                setState(() => _isResending = true);
                final error = await state.resendVerificationEmail();
                if (!mounted) return;
                setState(() => _isResending = false);
                if (context.mounted) {
                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verification email sent successfully.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                if (state.status == AuthStatus.loading) return;
                await state.logout();
                // app.dart guard handles navigation
              },
              child: const Text('Back to Login', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
