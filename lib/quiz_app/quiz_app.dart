import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';
import 'package:realtime_quiz_app/model/problem.dart';
import 'package:realtime_quiz_app/model/quiz.dart';

class QuizPage extends StatefulWidget {
  final String quizRef;
  final String name;
  final String uid;
  final String code;

  const QuizPage({
    super.key,
    required this.quizRef,
    required this.name,
    required this.uid,
    required this.code,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  DatabaseReference? quizStateRef;
  List<Problems> problemsSets = [];
  List<Map<String, int>> problemTriggers = [];

  String quizStatePath = "quiz_state";
  String quizDetailPath = 'quiz_detail';

  fetchQuizInformations() {
    quizStateRef = database?.ref('${quizStatePath}/${widget.quizRef}');
    final quizDetailRef = database?.ref('${quizDetailPath}/${widget.quizRef}');
    quizDetailRef?.get().then((value) {
      final obj = jsonDecode(jsonEncode(value.value));
      final quizDetail = QuizDetail.fromJson(obj);

      quizDetail.problems?.forEach((element) {
        problemsSets.add(element);
      });
      quizStateRef?.child('triggers').get().then((value) {
        for (var element in value.children) {
          final trigger = element.value as Map;
          problemTriggers.add({
            'start': trigger['start'],
            'end': trigger['end'],
          });
        }
      });
      quizStateRef?.child('user').push().set({
        'uid': widget.uid,
        'name': widget.name,
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchQuizInformations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} (코드: ${widget.code})'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Text('참가자'),
                Expanded(
                  child: StreamBuilder(
                    stream: quizStateRef?.child('/user').onValue,
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        final items = snapshot.data?.snapshot.children.toList() ?? [];
                        return ListView.builder(
                          itemCount: items.length,
                            itemBuilder: (context, index){
                            final item = items[index].value as Map;
                            return ListTile(
                              title: Text('${item["name"]}'),
                              subtitle: Text('${item["uid"]}'),
                            );
                        });
                      } return Container();
                    },
                  ),
                ),
                Divider(),
                Text('퀴즈 시작 상태'),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
