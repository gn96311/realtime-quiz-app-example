import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_quiz_app/main.dart';
import 'package:realtime_quiz_app/quiz_app/quiz_app.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController pinTextEditingController = TextEditingController();
  TextEditingController nicknameTextEditingController = TextEditingController();

  String? uid;

  final codeItems = [];

  signInAnonymously() async {
    final credential = await auth.signInAnonymously();
    uid = credential.user?.uid;
  }

  Future<bool> findPincode(String code) async {
    final quizRef = database?.ref('quiz');
    final result = await quizRef?.get();
    codeItems.clear();
    for (var element in result!.children) {
      final data =
          jsonDecode(jsonEncode(element.value)) as Map<String, dynamic>;
      DateTime nowDateTime = DateTime.now();
      DateTime generatedTime = DateTime.parse(data['generatedTime']);
      if (nowDateTime.difference(generatedTime).inDays < 1) {
        if (data.containsValue(code)) {
          codeItems.add(data['quizDetailRef']);
        }
      }
    }
    return codeItems.isEmpty ? false : true;
  }

  @override
  void initState() {
    // TODO: implement initState
    signInAnonymously();
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
        title: Text("입장 코드 입력"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: pinTextEditingController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '입장 코드 입력',
                    labelText: 'Pin code'),
              ),
              SizedBox(
                height: 24,
              ),
              TextField(
                controller: nicknameTextEditingController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '닉네임 입력',
                    labelText: '플레이어 명칭'),
              ),
              SizedBox(
                height: 24,
              ),
              MaterialButton(
                onPressed: () async {
                  if (pinTextEditingController.text.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('핀코드를 입력해주세요.')));
                      return;
                    }
                  }
                  if (nicknameTextEditingController.text.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('닉네임을 입력해주세요.')));
                      return;
                    }
                  }
                  final result =
                      await findPincode(pinTextEditingController.text.trim());
                  if (result) {
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => QuizPage(
                                  quizRef: codeItems.first,
                                  name:
                                      nicknameTextEditingController.text.trim(),
                                  uid: uid ?? "Unknown User",
                                  code: pinTextEditingController.text.trim(),
                                )),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('등록된 핀코드가 없습니다.')));
                    }
                  }
                },
                child: Text(
                  '입장하기',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                height: 72,
                color: Colors.indigo,
              )
            ],
          ),
        ),
      ),
    );
  }
}
