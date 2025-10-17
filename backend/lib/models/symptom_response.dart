import 'package:json_annotation/json_annotation.dart';

part 'symptom_response.g.dart';

@JsonSerializable()
class TriageLevel {
  final String level;
  final String message;

  const TriageLevel({
    required this.level,
    required this.message,
  });

  factory TriageLevel.fromJson(Map<String, dynamic> json) =>
      _$TriageLevelFromJson(json);

  Map<String, dynamic> toJson() => _$TriageLevelToJson(this);
}

@JsonSerializable()
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

  factory Condition.fromJson(Map<String, dynamic> json) =>
      _$ConditionFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionToJson(this);
}

@JsonSerializable()
class RecommendedAction {
  final String urgency;
  final String action;

  const RecommendedAction({
    required this.urgency,
    required this.action,
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) =>
      _$RecommendedActionFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedActionToJson(this);
}

@JsonSerializable()
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

  factory SymptomResponse.fromJson(Map<String, dynamic> json) =>
      _$SymptomResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomResponseToJson(this);
}
