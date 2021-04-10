import 'package:flutter/cupertino.dart';

class ListReply {

  List<TreasureHunt> treasureHunts;

  ListReply({@required this.treasureHunts});

  factory ListReply.fromJson(Map<String, dynamic> json) {

    var list = json["treasureHunts"];
    var listOfTreasureHunts = list.map((i) => TreasureHunt.fromJson(i)).toList();

    return ListReply(
        treasureHunts: new List<TreasureHunt>.from(listOfTreasureHunts)
    );
  }
}

class TreasureHunt {

  final String uuid;
  final String name;
  final String description;
  final int startsOn;
  final int endsOn;
  final int maxDuration;

  TreasureHunt({@required this.uuid, @required this.name, @required this.description, @required this.startsOn, @required this.endsOn, @required this.maxDuration, });

  factory TreasureHunt.fromJson(Map<String, dynamic> json) {
    return TreasureHunt(
        uuid: json['uuid'],
        name: json['name'],
        description: json['description'],
        startsOn: json['startsOn'],
        endsOn: json['endsOn'],
        maxDuration: json['maxDuration']
    );
  }
}

class StartReply {
  final String status;
  final String session;
  final int numOfQuestions;
  final List<String> errorMessages;

  StartReply({@required this.status, this.session, this.numOfQuestions, this.errorMessages});

  bool isError() {
    return status == 'ERROR';
  }

  factory StartReply.fromJson(Map<String, dynamic> json) {
    return StartReply(
        status: json['status'],
        session: json['session'],
        numOfQuestions: json['numOfQuestions'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  @override
  String toString() {
    return '${status} - ${isError() ? errorMessages.join(' / ') : session}';
  }
}

enum QuestionType { BOOLEAN, INTEGER, NUMERIC, MCQ, TEXT }

class QuestionReply {
  final String status;
  final bool completed;
  final String questionText;
  final QuestionType questionType;
  final bool canBeSkipped;
  final bool requiresLocation;
  final int numOfQuestions;
  final int currentQuestionIndex;
  final List<String> errorMessages;

  QuestionReply({@required this.status, this.completed, this.questionText, this.questionType, this.canBeSkipped, this.requiresLocation, this.numOfQuestions, this.currentQuestionIndex, this.errorMessages});

  factory QuestionReply.fromJson(Map<String, dynamic> json) {
    return QuestionReply(
        status: json['status'],
        completed: json['completed'],
        questionText: json['questionText'],
        questionType: json['questionType'],
        canBeSkipped: json['canBeSkipped'],
        requiresLocation: json['requiresLocation'],
        numOfQuestions: json['numOfQuestions'],
        currentQuestionIndex: json['currentQuestionIndex'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  bool isError() {
    return status == 'ERROR';
  }
}

class AnswerReply {
  final String status;
  final bool correct;
  final bool completed;
  final String message;
  final int scoreAdjustment;
  final List<String> errorMessages;

  AnswerReply({@required this.status, this.correct, this.completed, this.message, this.scoreAdjustment, this.errorMessages});

  factory AnswerReply.fromJson(Map<String, dynamic> json) {
    return AnswerReply(
        status: json['status'],
        correct: json['correct'],
        completed: json['completed'],
        message: json['message'],
        scoreAdjustment: json['scoreAdjustment'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  bool isError() {
    return status == 'ERROR';
  }
}