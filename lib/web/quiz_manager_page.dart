import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';
import 'package:realtime_quiz_app/model/quiz.dart';
import 'package:realtime_quiz_app/web/quiz_bottom_sheet_widget.dart';

class QuizManagerPage extends StatefulWidget {
  const QuizManagerPage({super.key});

  @override
  State<QuizManagerPage> createState() => _QuizManagerPageState();
}

class _QuizManagerPageState extends State<QuizManagerPage> {
  String? uid;
  List<QuizManager> quizItems = [];

  signInAnonymously() async {
    final credential = await FirebaseAuth.instance.signInAnonymously();
    setState(() {
      uid = credential.user?.uid ?? "";
    });
  }

  generateQuiz() async {
    if (quizItems.isEmpty) {
      return;
    }
    final pinCode = Random().nextInt(999999).toString().padLeft(6);
    final quizRef = database!.ref("quiz");
    final quizDetailRef = database!.ref("quiz_detail");
    final quizStateRef = database!.ref("quiz_state");

    final newQuizDetailRef = quizDetailRef.push();
    newQuizDetailRef.set({
      "code": pinCode,
      "problems": quizItems
          .map((e) => {
                "title": e.title,
                "options": e.problems
                    ?.map((e2) => e2.textEditingController.text)
                    .toList(),
                "answerIndex": e.answer?.index,
                "answer": e.answer?.textEditingController.text
              })
          .toList(),
    });

    await quizStateRef.child("${newQuizDetailRef.key}").set({
      "quizDetailRef": newQuizDetailRef.key,
      "user": [],
      "state": false,
      "score": [],
      "solve": [{}],
    });

    final newQuizRef = quizRef.push();
    await newQuizRef.set({
      "code": pinCode,
      "uid": uid,
      "generatedTime": DateTime.now().toString(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "quizDetailRef": newQuizDetailRef.key,
    });
  }

  List<Quiz> quizList = [];

  streamQuizes() async {
    database?.ref('quiz').onValue.listen(
      (event) {
        final data = event.snapshot.children;
        quizList.clear();
        for (var element in data) {
          quizList.add(
            Quiz.fromJson(
              jsonDecode(
                jsonEncode(element.value),
              ),
            ),
          );
        }
        setState(() {});
      },
    );
  }

  startQuiz(Quiz item) async {
    final ref =
        await database?.ref('quiz_state/${item.quizDetailRef}/state').get();
    final currentState = ref?.value as bool;
    if (!currentState) {
      final quizDetailRef =
          await database?.ref('quiz_detail/${item.quizDetailRef}').get();
      final problemCount =
          quizDetailRef?.child('/problems').children.length ?? 0;

      DateTime nowDateTime = DateTime.now();
      List<Map> triggerTimes = [];
      int solveTime = 5;
      for (var i = 0; i < problemCount; i++) {
        final startTime = nowDateTime.add(Duration(
          seconds: 5 + (i * solveTime),
        ));
        final endTime = startTime.add(Duration(seconds: 5));
        triggerTimes.add({
          'start': startTime.millisecondsSinceEpoch,
          'end': endTime.millisecondsSinceEpoch
        });
        nowDateTime = endTime;
      }

      if (context.mounted) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text('퀴즈를 시작할까요?'),
                  title: const Text('안내'),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await database
                              ?.ref('quiz_state/${item.quizDetailRef}')
                              .update(
                            {
                              'state': true,
                              'current': 0,
                              'triggers': triggerTimes
                            },
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('네'))
                  ],
                ));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    signInAnonymously();
    streamQuizes();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("퀴즈 출제하기(출제자용)"),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(tabs: [
              Tab(
                text: '출제하기',
              ),
              Tab(text: '퀴즈 목록'),
            ]),
            Expanded(
                child: TabBarView(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: quizItems.length,
                        itemBuilder: (context, index) {
                          return ExpansionTile(
                            title: Text(quizItems[index].title ?? ""),
                            children: quizItems[index]
                                .problems!
                                .map(
                                  (e) => ListTile(
                                    title: Text(e.textEditingController.text),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        // TODO: 퀴즈 생성 및 핀코드 생성 로직 추가
                        generateQuiz();
                      },
                      height: 72,
                      color: Colors.indigo,
                      child: Text(
                        '제출 및 핀코드 생성',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                  itemCount: quizList.length,
                  itemBuilder: (context, index) {
                    final item = quizList[index];
                    return ListTile(
                      title: Text("code : ${item.code}"),
                      subtitle: Text('${item.quizDetailRef}'),
                      onTap: () {
                        // TODO 퀴즈를 시작하는 것.
                        startQuiz(item);
                      },
                    );
                  },
                ),
              ],
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          //TODO: 문제 출제를 위한 모달을 띄우기
          final quiz = await showModalBottomSheet(
              context: context, builder: (context) => QuizBottomSheetWidget());
          setState(() {
            quizItems.add(quiz);
          });
        },
      ),
    );
  }
}
