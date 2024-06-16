import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'problem.g.dart';

class ProblemManager {
  int? index;
  TextEditingController textEditingController;

  ProblemManager({
    required this.index,
    required this.textEditingController,
  });
}


@JsonSerializable()
class Problems {
  int? answerIndex;
  String? answer;
  List<String>? options;
  String? title;

  Problems({this.answerIndex, this.answer, this.options, this.title});

  factory Problems.fromJson(Map<String, dynamic> json) => _$ProblemsFromJson(json);
  Map<String, dynamic> toJson() => _$ProblemsToJson(this);
}