import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_state.dart';
import '../../../data/models/auth_status.dart';
import '../../../core/common_widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.firebaseUser;
    final profile = state.userProfile;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            Text(profile?.name ?? user.displayName ?? 'No Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email ?? 'No Email', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            if (profile != null)
              Chip(
                label: Text(profile.role.name.toUpperCase()),
                backgroundColor: Colors.blue[50],
              ),
            const Spacer(),
            AppButton(
              text: 'Logout',
              color: Colors.red,
              isLoading: state.status == AuthStatus.loading,
              onPressed: () async {
                if (state.status == AuthStatus.loading) return;
                await state.logout();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
