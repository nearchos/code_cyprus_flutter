import 'package:code_cyprus_app/networking.dart';
import 'package:code_cyprus_app/questions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
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

  StartTreasureHunt({Key key, @required this.title, @required this.treasureHunt}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new StartTreasureHuntState();
}

class StartTreasureHuntState extends State<StartTreasureHunt> {

  bool _loading = false;
  String _error;

  StartReply _startReply;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _saveSession(String session) async {
    debugPrint('Starting session with id: ${session}');
    final SharedPreferences prefs = await _prefs;
    prefs.setString(widget.treasureHunt.uuid, session);
  }

  _startSession(String session) {
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new QuestionsAndAnswers(title: 'Playing', treasureHunt: widget.treasureHunt, session: session), settings: RouteSettings(name: '${session}')));
  }

  // used for the starting time countdown
  Timer _timer;
  DateTime _now = DateTime.now();

  String _existingSession;

  @override
  void initState() {
    super.initState();
    // check prefs for existing session for given TH
    _prefs.then((SharedPreferences prefs) =>
        setState(() {
          _existingSession = prefs.getString(widget.treasureHunt.uuid);
        })
    );

    // start timer -- see https://stackoverflow.com/questions/54610121/flutter-countdown-timer
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _myTeamTextEditingController.dispose();
    _timer.cancel();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _myTeamTextEditingController = TextEditingController();

  _makeRequest(String team, String email) async {
    debugPrint('Making a request...');
    setState(() {
      _loading = true;
    });
    _startReply = await startTreasureHunt(team, widget.treasureHunt);
    if(_startReply.isError()) {
      setState(() {
        _loading = false;
        _error = _startReply.errorMessages.join(' / ');
      });
    } else {
      _saveSession(_startReply.session);
      _startSession(_startReply.session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: widget.title,
        theme: ThemeData(
          primarySwatch: CodeCyprusAppTheme.codeCyprusAppGreen,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false)
              ),
            ),
            body: SingleChildScrollView(
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 10),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        decoration: DottedDecoration(shape: Shape.box, borderRadius: BorderRadius.circular(8), color: Colors.black54),
                        child: Padding(padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text('Enter your team name (up to 16 characters)'),
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
                              // Text('Enter your email (optional to receive results)'),
                              // TextFormField(
                              //     style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppRed, fontWeight: FontWeight.bold),
                              //     keyboardType: TextInputType.emailAddress,
                              //     // The validator receives the text that the user has entered.
                              //     validator: (email) {
                              //       if ((email != null && email.length > 0) && !EmailValidator.validate(email.trim())) {
                              //         return 'Please specify a valid email';
                              //       }
                              //       return null;
                              //     }
                              // ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: _error != null ?
                                  Text('Error: ${_error}', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)) :
                                  Container()
                              ),

                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Text(_loading ? 'Loading ...' : getTreasureHuntTimeDetails(widget.treasureHunt, _now), textAlign: TextAlign.center, style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppGreen, fontStyle: FontStyle.italic))
                              ),

                              _loading ?
                                Center(child: CircularProgressIndicator()) :
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: CodeCyprusAppTheme.codeCyprusAppGreen, // background
                                    onPrimary: Colors.black, // foreground
                                  ),
                                  onPressed: isNotFinishedAndStartsInInLessThan60Minutes(widget.treasureHunt, _now) ? null : () async {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKey.currentState.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      String team = _myTeamTextEditingController.text.trim();
                                      String email = ''; // todo
                                      debugPrint('starting ${team} @ \'${widget.treasureHunt.name}\' ...');
                                      //todo
                                      _makeRequest(team, email);
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
                      )
                    ),

                    Visibility(
                      visible: _existingSession != null,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HorizontalOrLine(label: 'OR', height: 72),
                            Text('You\'ve previously started a session which is still in progress. You can either resume it or start a new one.',
                              style: TextStyle(fontStyle: FontStyle.italic)
                            ),
                            Container(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orangeAccent, // background
                                onPrimary: Colors.black, // foreground
                            ),
                            onPressed: () => _startSession(_existingSession),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Resume session", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black)),
                                  Container(width: 10,),
                                  Icon(Icons.upload_outlined, size: 24, color: Colors.black)
                                ]
                              )
                            )
                          )
                        ]
                      )
                    )
                  ),
                ]
              )
            )
        )
    );
  }
}