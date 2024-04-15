import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';
import 'theme.dart';
import 'package:code_cyprus_app/networking.dart';
import 'package:code_cyprus_app/util.dart';
import 'package:code_cyprus_app/model.dart';
import 'package:code_cyprus_app/leaderboard.dart';

class QuestionsAndAnswers extends StatefulWidget {
  final String title;
  final TreasureHunt treasureHunt;
  final String session;

  QuestionsAndAnswers({required Key? key, required this.title, required this.treasureHunt, required this.session}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new QuestionsAndAnswersState();
}

class QuestionsAndAnswersState extends State<QuestionsAndAnswers> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  _clearSession(String session) async {
    debugPrint('Clearing session with id: $session');
    final SharedPreferences prefs = await _prefs;
    prefs.remove(widget.treasureHunt.uuid);
  }

  // used for the starting time countdown
  late Timer _timer;
  DateTime _now = DateTime.now();

  bool _loading = false;
  String? _error = null;
  String? _locationError = null;
  QuestionReply? _questionReply = null;
  AnswerReply? _answerReply = null;
  ScoreReply? _scoreReply = null;

  void _reloadQuestion() async {
    // make http request
    setState(() {
      _loading = true;
    });
    final String secret = await _getSecret();
    final QuestionReply qr = await fetchQuestion(widget.session, secret);
    if(qr.isError()) {
      setState(() {
        _loading = false;
        _error = _questionReply?.errorMessages.join(' / ');
      });
    } else {
      setState(() {
        _loading = false;
        _error = null;
        if(qr.completed) _clearSession(widget.session);
        _questionReply = qr;
        _reloadScore();
      });
    }
  }

  void _reloadScore() async {
    final ScoreReply sr = await score(widget.session);
    if(sr.isError()) {
      setState(() {
        _loading = false;
        _error = _questionReply?.errorMessages.join(' / ');
      });
    } else {
      setState(() {
        _loading = false;
        _error = null;
        _scoreReply = sr;
      });
    }
  }

  final int delayForShowingCorrectAnswer = 5000; // show for 5 seconds
  int _lastShownCorrect = 0;

  Future<String> _getSecret() async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString('secret') ?? "";
  }

  @override
  void initState() {
    super.initState();

    // start timer -- see https://stackoverflow.com/questions/54610121/flutter-countdown-timer
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        _now = DateTime.now();
        if(_answerReply != null && _answerReply!.correct && _lastShownCorrect < _now.millisecondsSinceEpoch) {
          _answerReply = null;
        }
        _updateLocation();
      });
    });

    _reloadQuestion();
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
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(false)
              ),
              actions: [
                Visibility(
                  visible: !kIsWeb,
                  child: IconButton(icon: Icon(Icons.qr_code), tooltip: 'Scan QR-Code', onPressed: _scanCode),
                ),
                IconButton(icon: Icon(Icons.leaderboard), tooltip: 'Leaderboard', onPressed: _showLeaderboard),
                IconButton(icon: Icon(Icons.arrow_forward), tooltip: 'Skip', onPressed: _askToSkipQuestion),
                IconButton(icon: Icon(Icons.refresh), tooltip: 'Reload', onPressed: _reloadQuestion)
              ],
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _getScoreWidget(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("images/sleepy.gif", height: 100.0, width: 100.0),
                            Expanded(
                                child: ChatBubble(
                                    clipper: ChatBubbleClipper7(type: BubbleType.receiverBubble),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.all(10),
                                    shadowColor: Colors.black,
                                    backGroundColor: Colors.yellow[100],
                                    child:  _getQuestionTextUI()
                                )
                            )
                          ]
                      ),
                    ),
                    Visibility(
                      visible: _locationError != null,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Location error: $_locationError', style: TextStyle(color: Colors.red, fontSize: 11)),
                      )
                    ),
                    _getFeedbackWidget(),
                    _getInputWidget(),
                    Container(),
                  ]
                )
              )
            )
        )
    );
  }

  Widget _getQuestionTextUI() {
    if(_loading && _questionReply == null) {
      return Center(child: Text('Loading ...'));
    } else {
      if (_questionReply == null || _error != null) {
        return Text('Error: $_error',
          style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic));
      } else if(_questionReply!.completed) {
        return Text('You have completed the treasure hunt!',
            style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic));
      } else {
        return Column(
          children: [
            Html(
              data: "${_questionReply?.questionText}",
              onLinkTap: (url, attributes, element) {
                  debugPrint("Opening $url...");
                  if(url != null) {
                    _showLink(url);
                  }
              },
              // onLinkTap: (url) {
              //   debugPrint("Opening $url...");
              //   _showLink(url);
              // },
            ),
            Visibility(
              visible: _questionReply!.requiresLocation,
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.green),
                  Text("Requires location!", style: TextStyle(color: Colors.green, decoration: TextDecoration.underline))
                ]
              )
            )
          ]
        );
      }
    }
  }

  // todo add option to 'remember' choice
  void _showLink(String src) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Open link?"),
            content: Text('${src}'),
            actions: [
              TextButton(child: Text("Open"), onPressed: () {
                _launchURL(src);
                Navigator.of(context).pop();
              }),
              TextButton(child: Text("Cancel"), onPressed: () { Navigator.of(context).pop(); })
            ],
          );
        }
    );
  }

  _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Widget _getScoreWidget() {
    return Container(
      color: Colors.grey.shade300,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Text('Score: ${_scoreReply == null ? 0 : _scoreReply!.score}'),
            Expanded(child: Container()),
            Text('${getTreasureHuntEndingInDetails(widget.treasureHunt, _now)}')
          ]
        )
      )
    );
  }

  Widget _getFeedbackWidget() {
    if(_loading || _answerReply == null) {
      return Container(
          color: Colors.grey.shade100,
          height: 64
      );
    } else {
      return Container(
          color: Colors.grey.shade100,
          height: 64,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_answerReply!.correct ? Icons.done : Icons.close, color: _answerReply!.correct ? Colors.green : Colors.red),
                Text('${_answerReply!.correct ? 'Correct! ' : 'Nope. '}', style: TextStyle(color: _answerReply!.correct ? Colors.green : Colors.red)),
                SizedBox(width: 8),
                Flexible(
                  child: Text('${_answerReply!.message}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11))
                )
              ]
            )
          )
      );
    }
  }

  Widget _getInputWidget() {
    if(_loading) {
      return Container(
          height: 64, child: Center(child: CircularProgressIndicator()));
    } else if(_questionReply == null) {
      return Center(child: Text('Error!', style: TextStyle(color: Colors.red)));
    } else if(_questionReply!.completed) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Row(
            children: [
              ElevatedButton(
                  child: Row(children: [
                    Icon(Icons.leaderboard),
                    Text('Leaderboard')
                  ]),
                  onPressed: _showLeaderboardNoReturn)
            ],
            mainAxisAlignment: MainAxisAlignment.center
        ),
      );
    } else {
      if(_error != null) {
        return Container(); // empty widget - the error message is shown in the question text
      } else {
        if(_questionReply!.questionType == QuestionType.BOOLEAN) {
          return Padding(
              padding: EdgeInsets.all(8),
              child: _getBooleanAnswerArea()
          );
        } else if(_questionReply!.questionType == QuestionType.MCQ) {
          return Padding(
              padding: EdgeInsets.all(8),
              child: _getMcqAnswerArea()
          );
        } else if(_questionReply!.questionType == QuestionType.INTEGER || _questionReply!.questionType == QuestionType.NUMERIC) {
          return Padding(
              padding: EdgeInsets.all(8),
              child: _getTextAnswerFormArea(true)
          );
        } else { // QuestionType.TEXT
          return Padding(
              padding: EdgeInsets.all(8),
              child: _getTextAnswerFormArea(false)
          );
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _myAnswerTextEditingController = TextEditingController();

  Widget _getTextAnswerFormArea(bool numeric) {
    return Column(
      children: [
        Form(
            key: _formKey,
            child: TextFormField(
              autofocus: true,
              style: TextStyle(color: CodeCyprusAppTheme.codeCyprusAppRed, fontWeight: FontWeight.bold),
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              controller: _myAnswerTextEditingController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a non-empty answer';
                } else if(value.trim().contains(' ')) {
                  return 'The answer should not contain spaces';
                }
                return null;
              }
            )
        ),
        Container(height: 8),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            if (_formKey.currentState != null && _formKey.currentState!.validate())  {
              _submitAnswer(_myAnswerTextEditingController.text);
            }
          }
        )
      ],
    );
  }

  Widget _getBooleanAnswerArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            child: Text('True / Yes'),
            onPressed: () => _submitAnswer('true')
        ),
        ElevatedButton(
            child: Text('False / No'),
            onPressed: () => _submitAnswer('false')
        )
      ],
    );
  }

  Widget _getMcqAnswerArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            child: Text('A'),
            onPressed: () => _submitAnswer('A')
        ),
        ElevatedButton(
            child: Text('B'),
            onPressed: () => _submitAnswer('B')
        ),
        ElevatedButton(
            child: Text('C'),
            onPressed: () => _submitAnswer('C')
        ),
        ElevatedButton(
            child: Text('D'),
            onPressed: () => _submitAnswer('D')
        )
      ],
    );
  }

  void _submitAnswer(String answer) async {
    debugPrint('submitting answer \'${answer}\' ...'); // todo delete
    setState(() {
      _loading = true;
    });
    final AnswerReply ar = await submitAnswer(widget.session, answer);
    final ScoreReply sr = await score(widget.session);
    debugPrint('AnswerReply: ${ar}');
    if(ar.isError()) {
      setState(() {
        _loading = false;
        _error = ar.errorMessages.join(' / ');
      });
    } else {
      _loading = false;
      _error = null;
      _answerReply = ar;
      _lastShownCorrect = _now.millisecondsSinceEpoch + delayForShowingCorrectAnswer;
      _scoreReply = sr;
      if(ar.correct) {
        _reloadQuestion();
        _myAnswerTextEditingController.text = '';
      }
    }
  }

  void _askToSkipQuestion() {
    debugPrint('skipping question ...');
    //todo
    if(_questionReply != null && !_questionReply!.canBeSkipped) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Cannot skip"),
              content: Text('This question cannot be skipped.'),
              actions: [
                TextButton(child: Text("Ok, got it"), onPressed: () {
                  Navigator.of(context).pop(); }
                )
              ],
            );
          }
      );
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Skip question?"),
              content: Text('Are you sure you want to skip this question?'),
              actions: [
                TextButton(child: Text("Yes, skip it"), onPressed: () {
                  _skipQuestion();
                  Navigator.of(context).pop();
                }),
                TextButton(child: Text("No, I've changed my mind"), onPressed: () {
                  Navigator.of(context).pop(); }
                  )
              ],
            );
          }
      );
    }
  }

  void _skipQuestion() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final SkipReply sr = await skip(widget.session);
    if(sr.isError()) {
      setState(() {
        _loading = true;
        _error = sr.errorMessages.join(' / ');
      });
    } else {
      setState(() {
        _loading = false;
        _error = null;
        _answerReply = null;
        _reloadQuestion();
      });
    }
  }

  void _scanCode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#78C557',
        'Cancel',
        true,
        ScanMode.QR);

    debugPrint('Scanned: $barcodeScanRes');
    // copy value in form
    _myAnswerTextEditingController.value = _myAnswerTextEditingController.value.copyWith(
      text: barcodeScanRes,
      // selection: TextSelection.collapsed(offset: barcodeScanRes.length)
      selection: TextSelection(baseOffset: 0, extentOffset: barcodeScanRes.length)
    );
  }

  void _showLeaderboard() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => Leaderboard(key: widget.key, title: 'Leaderboard', treasureHunt: widget.treasureHunt, session: widget.session), settings: RouteSettings(name: 'Leaderboard for ${widget.session}')));
  }

  void _showLeaderboardNoReturn() {
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => Leaderboard(key: widget.key, title: 'Leaderboard', treasureHunt: widget.treasureHunt, session: widget.session), settings: RouteSettings(name: 'Leaderboard for ${widget.session}')));
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;


    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      // don't continue accessing the position and request users of the
      // App to enable the location services.
      _locationError = 'Location service disabled - you must enable it first';

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _locationError = 'Location permission denied - you must approve them first';

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationError = 'Location denied forever';
      return false;
    }

    _locationError = null;
    return true;
  }

  int _locationLastUpdatedTimestamp = 0;
  final int delayForLocationUpdates = 30 * 1000; // 30 seconds

  void _updateLocation() async {
    if(_now.millisecondsSinceEpoch - _locationLastUpdatedTimestamp < delayForLocationUpdates) {
      return; // no need for action so exit method
    }

    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    // remember this so we do not attempt it again sooner than 'delayForLocationUpdates' later
    _locationLastUpdatedTimestamp = _now.millisecondsSinceEpoch;

    final position = await _geolocatorPlatform.getCurrentPosition();

    debugPrint('Location: (${position.latitude}, ${position.longitude})');
    sendLocation(widget.session, position.latitude, position.longitude);
  }
}