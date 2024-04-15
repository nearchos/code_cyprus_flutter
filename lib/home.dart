import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'list.dart';
import 'theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _help() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('About Code Cyprus'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 20),
                  Text('Code Cyprus\' mission is to'),
                  Container(height: 10),
                  Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text('``Promote the value and beauty of coding to teenagers in Cyprus!´´',
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.green))),
                  Container(height: 10),
                  Text('Our main activity is to organize a yearly, free event to actively engage as many high-school students as possible.'),
                  Container(height: 10),
                  Text('Learn more about Code Cyprus and our next event by visiting our webpage.'),
                  Container(height: 20),
                  ElevatedButton(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('codecyprus.org'),
                            Container(width: 10), // spacer
                            Icon(Icons.open_in_new)
                          ]),
                      onPressed: () => _launchURL('https://codecyprus.org/about')
                  ),
                ]
            ),
            actions: [
              TextButton(child: Text("Close"), onPressed: () {
                Navigator.of(context).pop(); }
              )
            ],
          );
        });
  }

  String _getMarketplaceLink() {
    try {
      if (Platform.isAndroid) {
        return 'https://play.google.com/store/apps/details?id=org.codecyprus.android_client';
      } else if (Platform.isIOS) {
        // iOS-specific code
        return "todo"; // todo replace with app store marketplace URL for this app
      }
    } catch(e) {
      debugPrint('Error: $e');
    }
    return "Error";
  }

  _about() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('About the app'),
            content: Container(
                width: double.maxFinite,
                child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      _getListTile(Image.asset('images/pirate.png'), 'Code Cyprus', 'http://codecyprus.org', 'http://codecyprus.org'),
                      _getListTile(Icon(Icons.favorite), 'Love the app?', 'Rate us', _getMarketplaceLink()),
                      _getListTile(Icon(Icons.build), 'Version', '$_version', null),
                      _getListTile(Icon(Icons.code), 'Open Source Software', 'View on Github', 'https://github.com/nearchos/code_cyprus_flutter')
                    ]
                )
            ),
            actions: [
              TextButton(child: Text("Close"), onPressed: () {
                Navigator.of(context).pop(); }
              )
            ],
          );
        });
  }

  _start() {
    setState(() {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => TreasureHuntsListView(key: widget.key, title: 'Select treasure hunt'), settings: RouteSettings(name: 'Select treasure hunt')));
    });
  }

  late String _version;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) => setState(() {
      _version = packageInfo.version;
    }));
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
                child: ChatBubble(
                    clipper: ChatBubbleClipper7(type: BubbleType.receiverBubble),
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.all(10),
                    shadowColor: Colors.black,
                    backGroundColor: Colors.yellow[100],
                    child: Text('Ahoy pirates! And welcome to the Code Cyprus\' treasure hunt app!\n\nIf you have questions, select the help menu. When ready, click the button below to get started!', style: TextStyle(fontSize: 16))
                )
            ),
            Expanded(
              child: Image.asset(
                  "images/waving.gif"
              )
            ),
            Padding(
                padding: EdgeInsets.all(32),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.black, backgroundColor: CodeCyprusAppTheme.codeCyprusAppGreen),
                    onPressed: _start,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Let's Get Started!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
                              Container(width: 10,),
                              Icon(Icons.run_circle, size: 24, color: Colors.black)
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

  _getListTile(graphics, final String title, final String subtitle, final String? url) {
    return ListTile(
        leading: graphics == null ? null : graphics,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontStyle: FontStyle.italic)),
        onTap: url == null ? null : () => _launchURL(url)
    );
  }

  _launchURL(String url) async {
    // debugPrint('launching $url ...');
    final Uri uri = Uri.parse(url);
    await canLaunchUrl(uri) ? await launchUrl(uri) : throw 'Could not launch $url';
  }
}