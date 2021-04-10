import 'package:code_cyprus_app/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/rendering.dart';
import 'model.dart';
import 'util.dart';
import 'theme.dart';
import 'horizontal_or_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartTreasureHunt extends StatefulWidget {
  final String title;
  final TreasureHunt treasureHunt;

  StartTreasureHunt({Key key, this.title, this.treasureHunt}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new StartTreasureHuntState();
}

class StartTreasureHuntState extends State<StartTreasureHunt> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveAndStartSession(String session) async {
    debugPrint('Starting session with id: ${session}');
    final SharedPreferences prefs = await _prefs;
    prefs.setString(widget.treasureHunt.uuid, session);
    _startSession(session);
  }

  _startSession(String session) {
    //todo
    debugPrint('starting session: ${session}');
  }

  Future<StartReply> _startReply;

  // used for the starting time countdown
  Timer _timer;
  DateTime _now = DateTime.now();

  String _existingSession = null;

  @override
  void initState() {
    super.initState();
    // check prefs for existing session for given TH
    _prefs.then((SharedPreferences prefs) =>
        setState(() {
          _existingSession = prefs.getString(widget.treasureHunt.uuid);
        }
    ));

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
  }

  @override
  void dispose() {
    _timer.cancel();
    _myTeamTextEditingController.dispose();
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
                                              TextSpan(text: '${widget.treasureHunt.name}', style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
                                              TextSpan(text: '. Enter your details and get ready to start the hunting...', style: TextStyle(color: Colors.black, fontSize: 18))
                                            ]
                                        )
                                    )
                                )
                            )
                          ]
                      ),
                    ),
                    Visibility(
                        visible: _existingSession != null,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orangeAccent, // background
                                      onPrimary: Colors.black, // foreground
                                    ),
                                    onPressed: () => _startSession(_existingSession),
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Resume session", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black)),
                                              Container(width: 10,),
                                              Icon(Icons.save_outlined, size: 24, color: Colors.black)
                                            ]
                                        )
                                    )
                                ),
                                HorizontalOrLine(label: 'OR', height: 72)
                              ]
                            )
                        )
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text('Enter your team name (up to 16 character)'),
                            TextFormField(
                                style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppRed, fontWeight: FontWeight.bold),
                                controller: _myTeamTextEditingController,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a non-empty team name';
                                  } else if(value.trim().contains(' ')) {
                                    return 'The team name should not contain spaces';
                                  } else if(value.length > 16) {
                                    return 'The team name must be up to 16 characters (currently ${value.length})';
                                  }
                                  return null;
                                }
                            ),
                            Container(height: 20),
                            Text('Enter your email (optional to receive results)'),
                            TextFormField(
                                style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppRed, fontWeight: FontWeight.bold),
                                // The validator receives the text that the user has entered.
                                validator: (email) {
                                  if ((email != null && email.length > 0) && !EmailValidator.validate(email.trim())) {
                                    return 'Please specify a valid email';
                                  }
                                  return null;
                                }
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: _getFutureBuilder()
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Text(getTreasureHuntTimeDetails(widget.treasureHunt, _now), textAlign: TextAlign.center, style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppGreen, fontStyle: FontStyle.italic))
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: CodeCyprusAppTheme.codeCyprusAppGreen, // background
                                  onPrimary: Colors.black, // foreground
                                ),
                                onPressed: isNotFinishedAndStartsInInLessThan60Minutes(widget.treasureHunt, _now) ? null : () {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    debugPrint('starting ${_myTeamTextEditingController.text} @ \'${widget.treasureHunt.name}\' ...');
                                    setState(() {
                                      _startReply = startTreasureHunt(_myTeamTextEditingController.text.trim(), widget.treasureHunt);
                                    });
                                  }
                                },
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

  FutureBuilder<StartReply> _getFutureBuilder() {
    return FutureBuilder<StartReply>(
      future: _startReply,
      builder: (context, snapshot) {
        debugPrint('snapshot.connectionState: ${snapshot.connectionState}');
        if(snapshot.connectionState == ConnectionState.none) {
          return Container();
        } else if(snapshot.connectionState == ConnectionState.waiting) {
          return _startReply == null ? Spacer() : Center(child: CircularProgressIndicator());
        } else if(snapshot.hasData) {
          debugPrint('StartReply: ${snapshot.data}');
          if(snapshot.data.isError()) {
            return Text('Error: ${snapshot.data.errorMessages.join(' / ')}', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic));
          }
          _saveAndStartSession(snapshot.data.session);
          return Text('Session started! Let\'s go ...', style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic));
        } else if(snapshot.hasError) {
          debugPrint('StartReply: ${snapshot.data}');
          return Text('Error (${snapshot.error})', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic));
        } else {
          return _startReply == null ? Spacer() : Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}