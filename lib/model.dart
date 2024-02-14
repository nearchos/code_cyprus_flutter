class ListReply {

  List<TreasureHunt> treasureHunts;

  ListReply({required this.treasureHunts});

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

  TreasureHunt({required this.uuid, required this.name, required this.description, required this.startsOn, required this.endsOn, required this.maxDuration});

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

  StartReply({required this.status, required this.session, required this.numOfQuestions, required this.errorMessages});

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
    return '$status - ${isError() ? errorMessages.join(' / ') : session}';
  }
}

enum QuestionType { BOOLEAN, INTEGER, NUMERIC, MCQ, TEXT, UNKNOWN }

extension InterpretFromString on QuestionType {
  static QuestionType toQuestionType(String value) {
    for(QuestionType questionType in QuestionType.values) {
      if(questionType.toString().split('.').last == value) return questionType;
    }
    return QuestionType.UNKNOWN;
  }
}

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

  QuestionReply({required this.status, required this.completed, required this.questionText, required this.questionType, required this.canBeSkipped, required this.requiresLocation, required this.numOfQuestions, required this.currentQuestionIndex, required this.errorMessages});

  factory QuestionReply.fromJson(Map<String, dynamic> json) {
    return QuestionReply(
        status: json['status'],
        completed: json['completed'],
        questionText: json['questionText'],
        questionType: InterpretFromString.toQuestionType(json['questionType']),
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

  AnswerReply({required this.status, required this.correct, required this.completed, required this.message, required this.scoreAdjustment, required this.errorMessages});

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

class LocationReply {
  final String status;
  final String message;
  final List<String> errorMessages;

  LocationReply({required this.status,  required this.message, required this.errorMessages});

  factory LocationReply.fromJson(Map<String, dynamic> json) {
    return LocationReply(
        status: json['status'],
        message: json['message'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  bool isError() {
    return status == 'ERROR';
  }
}

class SkipReply {
  final String status;
  final bool completed;
  final String message;
  final int scoreAdjustment;
  final List<String> errorMessages;

  SkipReply({required this.status, required this.completed, required this.message, required this.scoreAdjustment, required this.errorMessages});

  factory SkipReply.fromJson(Map<String, dynamic> json) {
    return SkipReply(
        status: json['status'],
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

class ScoreReply {
  final String status;
  final bool completed;
  final bool finished;
  final String player;
  final int score;
  final List<String> errorMessages;

  ScoreReply({required this.status, required this.completed, required this.finished, required this.player, required this.score, required this.errorMessages});

  factory ScoreReply.fromJson(Map<String, dynamic> json) {
    return ScoreReply(
        status: json['status'],
        completed: json['completed'],
        finished: json['finished'],
        player: json['player'],
        score: json['score'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  bool isError() {
    return status == 'ERROR';
  }
}

class LeaderboardReply {
  final String status;
  final int numOfPlayers;
  final bool sorted;
  final int limit;
  final bool hasPrize;
  final List<LeaderboardEntry> leaderboard;
  final String treasureHuntName;
  final List<String> errorMessages;

  LeaderboardReply({required this.status, required this.numOfPlayers, required this.sorted, required this.limit, required this.hasPrize, required this.leaderboard, required this.treasureHuntName, required this.errorMessages});

  factory LeaderboardReply.fromJson(Map<String, dynamic> json) {
    var list = json["leaderboard"];
    var listOfLeaderboardEntries = list.map((i) => LeaderboardEntry.fromJson(i)).toList();
    return LeaderboardReply(
        status: json['status'],
        numOfPlayers: json['numOfPlayers'],
        sorted: json['sorted'],
        limit: json['limit'],
        hasPrize: json['hasPrize'],
        leaderboard: json['leaderboard'] == null ? [] : new List<LeaderboardEntry>.from(listOfLeaderboardEntries),
        treasureHuntName: json['treasureHuntName'],
        errorMessages: json['errorMessages'] == null ? [] : new List<String>.from(json['errorMessages'])
    );
  }

  bool isError() {
    return status == 'ERROR';
  }
}

class LeaderboardEntry {
  final String player;
  final int score;
  final int completionTime;

  LeaderboardEntry({required this.player, required this.score, required this.completionTime});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
        player: json['player'],
        score: json['score'],
        completionTime: json['completionTime']
    );
  }
}
