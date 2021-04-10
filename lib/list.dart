import 'package:flutter/material.dart';
import 'dart:async';
import 'networking.dart';
import 'model.dart';
import 'theme.dart';
import 'start.dart';
import 'util.dart';

class TreasureHuntsListView extends StatefulWidget {
  final String title;

  TreasureHuntsListView({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TreasureHuntsListViewState();
}

class TreasureHuntsListViewState extends State<TreasureHuntsListView> {

  bool _includeFinished = false;

  _startTreasureHunt(TreasureHunt selectedTreasureHunt) {
    setState(() {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new StartTreasureHunt(title: 'Enter your details', treasureHunt: selectedTreasureHunt), settings: RouteSettings(name: 'Start treasure hunt')));
    });
  }

  // check if we can use keyword late:  late Future<TreasureHunts> treasureHunts;
  Future<ListReply> _listReply;

  // used for the starting time countdown
  Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // start timer -- see https://stackoverflow.com/questions/54610121/flutter-countdown-timer
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
        oneSec,
        (timer) {
          setState(() {
            _now = DateTime.now();
          });
        }
    );

    // make http request
    _listReply = fetchListOfTreasureHunts(_includeFinished);
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
                      child: Image.asset("images/popcorn.gif", height: 100.0, width: 100.0),
                    ),
                    Row(
                        children: [
                          Checkbox(value: _includeFinished, onChanged: (value) {
                            setState(() {
                              _includeFinished = value;
                              // make http request
                              _listReply = fetchListOfTreasureHunts(_includeFinished);
                            });
                          }),
                          Text('Include finished treasure hunts', style: TextStyle(fontSize: 16))
                        ]
                    ),
                    Expanded(
                      child: FutureBuilder<ListReply>(
                        future: _listReply,
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator()
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          } else {
                            return _getListView(snapshot.data);
                          }
                        },
                      )
                    )
                  ],
                )
            )
        )
    );
  }

  _getListView(ListReply treasureHuntsList) {
    final List<TreasureHunt> treasureHunts = treasureHuntsList.treasureHunts;
    return ListView.separated(
        separatorBuilder: (context, index) =>
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Divider(color: Colors.black)
          ),
        padding: const EdgeInsets.all(8),
        itemCount: treasureHunts.length,
        itemBuilder: (BuildContext context, int index) {
          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: index % 2 == 1 ? Colors.amber.shade100 : Colors.amber.shade300,
                // background
                onPrimary: Colors.black, // foreground
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Center(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(treasureHunts[index].name, style: TextStyle(fontSize: 20, color: CodeCyprusAppTheme.codeCyprusAppBlue)),
                    Container(height: 4),
                    Text(treasureHunts[index].description, style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87)),
                    Container(height: 4),
                    Text('${getTreasureHuntTimeDetails(treasureHunts[index], _now)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic, color: CodeCyprusAppTheme.codeCyprusAppRed))
                  ]
                ))
              ),
              onPressed: () => _startTreasureHunt(treasureHunts[index])
          );
        }
    );
  }
}