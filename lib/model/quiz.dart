import 'package:json_annotation/json_annotation.dart';
import 'package:realtime_quiz_app/model/problem.dart';

part 'quiz.g.dart';

class QuizManager{
  List<ProblemManager>? problems;
  String? title;
  ProblemManager? answer;

  QuizManager({required this.problems, required this.answer, required this.title});
}

@JsonSerializable()
class QuizDetail{
  String? code;
  List<Problems>? problems;

  QuizDetail({this.code, this.problems});

  factory QuizDetail.fromJson(Map<String, dynamic> json) => _$QuizDetailFromJson(json);
  Map<String, dynamic> toJson() => _$QuizDetailToJson(this);
}

@JsonSerializable()
class Quiz{
  String? code;
  String? generateTime;
  String? quizDetailRef;
  int? timestamp;
  String? uid;

  Quiz({
    this.code,
    this.generateTime,
    this.quizDetailRef,
    this.timestamp,
    this.uid,
});
  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  Map<String, dynamic> toJson() => _$QuizToJson(this);
}