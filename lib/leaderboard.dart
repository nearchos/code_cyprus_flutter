import 'package:code_cyprus_app/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'dart:async';
import 'model.dart';
import 'theme.dart';

class Leaderboard extends StatefulWidget {
  final String title;
  final TreasureHunt treasureHunt;
  final String session;

  Leaderboard({required Key? key, required this.title, required this.treasureHunt, required this.session}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new LeaderboardState();
}

class LeaderboardState extends State<Leaderboard> {

  // check if we can use keyword late:  late Future<TreasureHunts> treasureHunts;
  late Future<LeaderboardReply> _leaderboardReply;

  // used for the starting time countdown
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // start timer -- see https://stackoverflow.com/questions/54610121/flutter-countdown-timer
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
        oneSec, (timer) {
          setState(() {
            _now = DateTime.now();
          });
        }
    );

    // make http request
    _leaderboardReply = leaderboard(widget.session, true);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
              leading: IconButton(icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false)),
            ),
            body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("images/drums.gif", height: 100.0, width: 100.0),
                            Expanded(
                                child: ChatBubble(
                                    clipper: ChatBubbleClipper7(type: BubbleType.receiverBubble),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.all(10),
                                    shadowColor: Colors.black,
                                    backGroundColor: Colors.yellow[100],
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(text: 'The leaderboard for \'', style: TextStyle(fontSize: 18)),
                                      TextSpan(text: '${widget.treasureHunt.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      TextSpan(text: '\' is...', style: TextStyle(fontSize: 18)),
                                    ]))
                                  // child: Container()
                                )
                            )
                          ]
                      )
                    ),
                    Expanded(
                        child: FutureBuilder<LeaderboardReply>(
                          future: _leaderboardReply,
                          builder: (context, snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            } else if (snapshot.data!.isError()) {
                              return Text("${snapshot.data!.errorMessages.join(' / ')}");
                            } else {
                              return _getLeaderboardView(snapshot.data!);
                            }
                          }
                        )
                    )
                  ]
                )
            )
        )
    );
  }

  _getLeaderboardView(LeaderboardReply leaderboardReply) {
    final List<LeaderboardEntry> leaderboardEntries = leaderboardReply.leaderboard;
    return ListView.separated(
        separatorBuilder: (context, index) =>
            Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Divider(color: Colors.black)
            ),
        padding: const EdgeInsets.all(8),
        itemCount: leaderboardEntries.length,
        itemBuilder: (BuildContext context, int index) {
          final LeaderboardEntry leaderboardEntry = leaderboardEntries[index];
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(leaderboardEntry.completionTime);
          return ListTile(
            leading: Text.rich(
              TextSpan(text: '${leaderboardEntry.score}', style: TextStyle(fontSize: 24), children: <InlineSpan>[TextSpan(text: 'pts', style: TextStyle(fontSize: 12))])
            ),
            title: Text(leaderboardEntry.player, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text('${dateTime.toLocal()}')
          );
        }
    );
  }
}