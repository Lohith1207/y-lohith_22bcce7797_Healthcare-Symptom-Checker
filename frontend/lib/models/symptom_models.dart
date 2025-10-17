class SymptomRequest {
  final String? userId;
  final String symptoms;
  final int? age;
  final String? sex;
  final String? otherInfo;

  const SymptomRequest({
    this.userId,
    required this.symptoms,
    this.age,
    this.sex,
    this.otherInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symptoms': symptoms,
      'age': age,
      'sex': sex,
      'other_info': otherInfo,
    };
  }
}

class TriageLevel {
  final String level;
  final String message;

  const TriageLevel({
    required this.level,
    required this.message,
  });

  factory TriageLevel.fromJson(Map<String, dynamic> json) {
    return TriageLevel(
      level: json['level'] as String,
      message: json['message'] as String,
    );
  }
}

class Condition {
  final String name;
  final String confidence;
  final String rationale;
  final List<String> typicalSymptoms;

  const Condition({
    required this.name,
    required this.confidence,
    required this.rationale,
    required this.typicalSymptoms,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      name: json['name'] as String,
      confidence: json['confidence'] as String,
      rationale: json['rationale'] as String,
      typicalSymptoms: List<String>.from(json['typical_symptoms'] as List),
    );
  }
}

class RecommendedAction {
  final String urgency;
  final String action;

  const RecommendedAction({
    required this.urgency,
    required this.action,
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      urgency: json['urgency'] as String,
      action: json['action'] as String,
    );
  }
}

class SymptomResponse {
  final TriageLevel triage;
  final List<Condition> conditions;
  final List<RecommendedAction> recommendedNextSteps;
  final String disclaimer;
  final List<String> askedClarifyingQuestions;

  const SymptomResponse({
    required this.triage,
    required this.conditions,
    required this.recommendedNextSteps,
    required this.disclaimer,
    required this.askedClarifyingQuestions,
  });

  factory SymptomResponse.fromJson(Map<String, dynamic> json) {
    return SymptomResponse(
      triage: TriageLevel.fromJson(json['triage'] as Map<String, dynamic>),
      conditions: (json['conditions'] as List)
          .map((c) => Condition.fromJson(c as Map<String, dynamic>))
          .toList(),
      recommendedNextSteps: (json['recommended_next_steps'] as List)
          .map((a) => RecommendedAction.fromJson(a as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String,
      askedClarifyingQuestions:
          List<String>.from(json['asked_clarifying_questions'] as List),
    );
  }
}
