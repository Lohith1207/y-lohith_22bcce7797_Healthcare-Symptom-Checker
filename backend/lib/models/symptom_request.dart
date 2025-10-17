import 'package:json_annotation/json_annotation.dart';

part 'symptom_request.g.dart';

@JsonSerializable()
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

  factory SymptomRequest.fromJson(Map<String, dynamic> json) =>
      _$SymptomRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomRequestToJson(this);
}
