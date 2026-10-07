enum UserRole { user, official }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final bool approved;
  final String? organization;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.approved = true,
    this.organization,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'approved': approved,
      'organization': organization,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['uid'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      approved: map['approved'] ?? false,
      organization: map['organization'],
    );
  }

  factory AppUser.fromAuthResponse(Map<String, dynamic> data) {
    return AppUser(
      id: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      approved: data['approved'] ?? false,
    );
  }
}
