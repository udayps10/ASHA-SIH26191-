import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../data/models/auth_status.dart';
import '../../../core/common_widgets/app_button.dart';
import '../../../core/common_widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSuccess = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isSuccess ? _buildSuccess() : _buildForm(state),
      ),
    );
  }

  Widget _buildForm(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address and we will send you a link to reset your password.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        AppTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const Spacer(),
        AppButton(
          text: 'Send Reset Email',
          isLoading: state.status == AuthStatus.loading,
          onPressed: () async {
            if (state.status == AuthStatus.loading) return;
            setState(() => _error = null);
            final error = await state.resetPassword(_emailController.text.trim());
            if (error == null) {
              setState(() => _isSuccess = true);
            } else {
              setState(() => _error = error);
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Check your email',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'If an account exists for that email, we have sent a password reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: 'Back to Login',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
