import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model.dart';

const String BASE_URL = 'codecyprus.org';
const String APP_ID = 'code_cyprus_flutter';

Future<ListReply> fetchListOfTreasureHunts(bool includeFinished) async {
  Uri uri = includeFinished ?
  Uri.https(BASE_URL, 'th/api/list', {'include-finished': 'true'}) :
    Uri.https(BASE_URL, 'th/api/list');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return ListReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load list of treasure hunts');
  }
}

Future<StartReply> startTreasureHunt(String team, TreasureHunt treasureHunt) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/start', {'player': team, 'app': APP_ID, 'treasure-hunt-id': treasureHunt.uuid});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return StartReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load list of treasure hunts');
  }
}

Future<QuestionReply> fetchQuestion(String session) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/question', {'session': session});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return QuestionReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load current question');
  }
}

Future<AnswerReply> submitAnswer(String session, String answer) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/answer', {'session': session, 'answer': answer});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return AnswerReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to submit answer');
  }
}

Future<LocationReply> sendLocation(String session, double latitude, double longitude) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/location', {'session': session, 'latitude': '${latitude}', 'longitude': '${longitude}'});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return LocationReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to submit answer');
  }
}

Future<SkipReply> skip(String session) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/skip', {'session': session});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return SkipReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to submit answer');
  }
}

Future<ScoreReply> score(String session) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/score', {'session': session});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return ScoreReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to submit answer');
  }
}

Future<LeaderboardReply> leaderboard(String session, bool sorted) async {
  Uri uri = Uri.https(BASE_URL, 'th/api/leaderboard', {'session': session, 'sorted': sorted ? 'true' : 'false'});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return LeaderboardReply.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to submit answer');
  }
}