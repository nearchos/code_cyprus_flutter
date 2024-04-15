import 'package:code_cyprus_app/model.dart';

String getTreasureHuntTimeDetails(TreasureHunt treasureHunt, DateTime now) {
  int startsOnAsMillisecondsSinceEpoch = treasureHunt.startsOn;
  int endsOnAsMillisecondsSinceEpoch = treasureHunt.endsOn;
  DateTime startsOnDateTime = DateTime.fromMillisecondsSinceEpoch(startsOnAsMillisecondsSinceEpoch);
  DateTime endsOnDateTime = DateTime.fromMillisecondsSinceEpoch(endsOnAsMillisecondsSinceEpoch);

  // check if it hasn't started yet
  int diffInDays = startsOnDateTime.difference(now).inDays;
  if(diffInDays >= 1) return 'Starts in ${diffInDays} days';
  int diffInHours = startsOnDateTime.difference(now).inHours;
  if(diffInHours >= 1) return 'Starts in ${diffInHours} hours';
  int diffInMinutes = startsOnDateTime.difference(now).inMinutes;
  if(diffInMinutes >= 1) return 'Starts in ${diffInMinutes} minutes';
  int diffInSeconds = startsOnDateTime.difference(now).inSeconds;
  if(diffInSeconds >= 1) return 'Starts in ${diffInSeconds} seconds';

  // check if it has already ended
  int endedInDays = now.difference(endsOnDateTime).inDays;
  if(endedInDays >= 1) return 'Ended ${endedInDays} days ago';
  int endedInHours = now.difference(endsOnDateTime).inHours;
  if(endedInHours >= 1) return 'Starts in ${endedInHours} hours';
  int endedInMinutes = now.difference(endsOnDateTime).inMinutes;
  if(endedInMinutes >= 1) return 'Starts in ${endedInMinutes} minutes';
  int endedInSeconds = now.difference(endsOnDateTime).inSeconds;
  if(endedInSeconds >= 1) return 'Starts in ${endedInSeconds} seconds';

  // it is currently running
  return 'Currently running!';
}

String getTreasureHuntEndingInDetails(TreasureHunt treasureHunt, DateTime now) {
  int endsOnAsMillisecondsSinceEpoch = treasureHunt.endsOn;
  DateTime endsOnDateTime = DateTime.fromMillisecondsSinceEpoch(endsOnAsMillisecondsSinceEpoch);

  // check if it has already ended
  int endsInDays = endsOnDateTime.difference(now).inDays;
  if(endsInDays >= 1) return 'Ends in ${endsInDays} days';
  int endsInHours = endsOnDateTime.difference(now).inHours;
  if(endsInHours >= 1) return 'Ends in ${endsInHours} hours';
  int endsInMinutes = endsOnDateTime.difference(now).inMinutes;
  if(endsInMinutes >= 1) return 'Ends in ${endsInMinutes} minutes';
  int endsInSeconds = endsOnDateTime.difference(now).inSeconds;
  if(endsInSeconds >= 1) return 'Ends in ${endsInSeconds} seconds';

  // it is currently running
  return 'Already ended';
}

bool isFinished(TreasureHunt treasureHunt, DateTime now) {
  int endsOnAsMillisecondsSinceEpoch = treasureHunt.endsOn;
  DateTime endsOnDateTime = DateTime.fromMillisecondsSinceEpoch(endsOnAsMillisecondsSinceEpoch);
  bool isFinished = (now.difference(endsOnDateTime).inSeconds < 0) ? true : false;
  return isFinished;
}

bool isNotFinishedAndStartsInInLessThan60Minutes(TreasureHunt treasureHunt, DateTime now) {
  int startsOnAsMillisecondsSinceEpoch = treasureHunt.startsOn;
  int endsOnAsMillisecondsSinceEpoch = treasureHunt.endsOn;
  DateTime startsOnDateTime = DateTime.fromMillisecondsSinceEpoch(startsOnAsMillisecondsSinceEpoch);
  DateTime endsOnDateTime = DateTime.fromMillisecondsSinceEpoch(endsOnAsMillisecondsSinceEpoch);
  bool isFinished = (now.difference(endsOnDateTime).inSeconds < 0) ? true : false;
  bool startsInLessThan60Minutes = startsOnDateTime.difference(now).inMinutes < 60;
  return !isFinished && startsInLessThan60Minutes;
}