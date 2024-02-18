import 'package:flutter/material.dart';
import 'theme.dart';
import 'home.dart';

void main() {
  runApp(const CodeCyprusApp());
}

class CodeCyprusApp extends StatefulWidget {
  const CodeCyprusApp({super.key});

  @override
  State<CodeCyprusApp> createState() => _CodeCyprusAppState();
}

class _CodeCyprusAppState extends State<CodeCyprusApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Cyprus App',
      theme: ThemeData(
        primarySwatch: CodeCyprusAppTheme.codeCyprusAppGreen,
        useMaterial3: true
      ),
      home: MyHomePage(key: widget.key, title: 'Code Cyprus app'),
    );
  }
}