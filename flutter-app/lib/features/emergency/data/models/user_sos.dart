enum UserSosStatus { pending, submitted, failed }

class UserSos {
  final String id;
  final String? userId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? message;
  final DateTime createdAt;
  final UserSosStatus status;

  const UserSos({
    required this.id,
    this.userId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.message,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };
}
