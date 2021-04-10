import 'package:code_cyprus_app/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'model.dart';
import 'theme.dart';

class Questions extends StatefulWidget {
  final String title;
  final String session;

  Questions({Key key, this.title, this.session}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new QuestionsState();
}

class QuestionsState extends State<Questions> {

  Future<QuestionReply> _currentQuestionReply;
  Future<AnswerReply> _currentAnswerReply;

  _requestNextQuestion() {
    debugPrint('request next question');
    setState(() {
      _currentQuestionReply = fetchQuestion(widget.session);
    });
  }

  _submitAnswer(String answer) {
    debugPrint('submit answer: ${answer}');
    setState(() {
      _currentAnswerReply = submitAnswer(widget.session, answer);
    });
  }

  Future<QuestionReply> _questionReply;
  Future<AnswerReply> _answerReply;

  @override
  void initState() {
    super.initState();
    _requestNextQuestion();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _myTeamTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.title,
        theme: ThemeData(
          primarySwatch: CodeCyprusAppTheme.codeCyprusAppGreen,
        ),
        home: Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            appBar: AppBar(
              title: Text(widget.title),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false)
              ),
            ),
            body:
            SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 32),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset("images/fly.gif", height: 100.0, width: 100.0),
                              Expanded(
                                  child: Bubble(
                                      alignment: Alignment.topLeft,
                                      elevation: 4,
                                      nip: BubbleNip.leftCenter,
                                      nipWidth: 20,
                                      color: Colors.yellow.shade100,
                                      child: RichText(
                                          text: TextSpan(
                                              children: [
                                                TextSpan(text: 'You picked ', style: TextStyle(color: Colors.black, fontSize: 18)),
                                                TextSpan(text: 'Hello', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                                                TextSpan(text: '. Enter your details and get ready to start the hunting...', style: TextStyle(color: Colors.black, fontSize: 18))
                                              ]
                                          )
                                      )
                                  )
                              )
                            ]
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text('Question'),
                                    TextFormField(
                                        style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppRed, fontWeight: FontWeight.bold),
                                        controller: _myTeamTextEditingController,
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a non-empty answer';
                                          // } else if(value.trim().contains(' ')) {
                                          //   return 'The answer should not contain spaces';
                                          }
                                          return null;
                                        }
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: CodeCyprusAppTheme.codeCyprusAppGreen, // background
                                          onPrimary: Colors.black, // foreground
                                        ),
                                        onPressed: _submitAnswer(_myTeamTextEditingController.text.trim()),
                                        child: Container(
                                            height: 50,
                                            alignment: Alignment.center,
                                            child: Text("Register", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal))
                                        )
                                    )
                                  ]
                              )
                          )
                      )
                    ]
                )
            )
        )
    );
  }
}