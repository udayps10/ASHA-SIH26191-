/// Input submitted by a normal user to the protected matching API.
///
/// [photoReference] deliberately represents a future upload/reference, not
/// an image transport or storage implementation.
class MatchRequest {
  MatchRequest({
    required this.name,
    required this.age,
    this.photoReference,
    this.lastKnownLocation,
    this.additionalDetails,
  });

  final String name;
  final int age;
  final String? photoReference;
  final String? lastKnownLocation;
  final String? additionalDetails;

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('name is required');
    if (age < 0 || age > 130) errors.add('age must be between 0 and 130');
    return errors;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name.trim(), 'age': age};
    if (photoReference != null && photoReference!.trim().isNotEmpty) {
      json['photo'] = photoReference;
    }
    if (lastKnownLocation != null && lastKnownLocation!.trim().isNotEmpty) {
      json['lastKnownLocation'] = lastKnownLocation!.trim();
    }
    if (additionalDetails != null && additionalDetails!.trim().isNotEmpty) {
      json['additionalDetails'] = additionalDetails!.trim();
    }
    return json;
  }
}
