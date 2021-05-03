import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'list.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Cyprus App',
      theme: ThemeData(
        primarySwatch: CodeCyprusAppTheme.codeCyprusAppGreen,
      ),
      home: MyHomePage(title: 'Code Cyprus app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _help() {
    // todo
  }

  _about() {
    // todo
  }

  _start() {
    setState(() {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new TreasureHuntsListView(title: 'Select treasure hunt'), settings: RouteSettings(name: 'Select treasure hunt')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.help), tooltip: 'Help', onPressed: _help),
          IconButton(icon: Icon(Icons.info), tooltip: 'About', onPressed: _about)
        ]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Bubble(
                    alignment: Alignment.center,
                    elevation: 4,
                    color: Colors.yellow.shade100,
                    padding: BubbleEdges.all(20),
                    child: Text('Ahoy pirates! And welcome to the Code Cyprus\' treasure hunt app!\n\nIf you have questions, select the help menu. When ready, click the button below to get started!', style: TextStyle(fontSize: 16))
                )
            ),
            Image.asset(
              "images/waving.gif",
              height: 200.0,
              width: 200.0,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 48, 32, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: CodeCyprusAppTheme.codeCyprusAppGreen, // background
                  onPrimary: Colors.black, // foreground
                ),
                onPressed: _start,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Let's Get Started!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
                        Container(width: 10,),
                        Icon(Icons.send_rounded, size: 24, color: Colors.black)
                      ]
                  )
                )
              )
            )
          ],
        ),
      ),
    );
  }
}
