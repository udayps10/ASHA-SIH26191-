enum SafetyZone { safe, green, yellow, orange, red, unknown }

class SafetyFactor {
  final String factorName;
  final double contributionScore;
  final bool isNegative;

  const SafetyFactor({
    required this.factorName,
    required this.contributionScore,
    this.isNegative = false,
  });

  Map<String, dynamic> toJson() => {
    'factorName': factorName,
    'contributionScore': contributionScore,
    'isNegative': isNegative,
  };
}

class SafetyResult {
  final SafetyZone zone;
  final double? distanceFromDisasterKm;
  final double? radiusKm;
  final double? percentageOfRadius;
  final int? riskScore;
  final List<SafetyFactor>? factors;

  const SafetyResult({
    required this.zone,
    this.distanceFromDisasterKm,
    this.radiusKm,
    this.percentageOfRadius,
    this.riskScore,
    this.factors,
  });
}
