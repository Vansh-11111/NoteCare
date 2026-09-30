import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        appBar:  AppBar(
          title: Text('Project 1',style: TextStyle(
            color: Color.fromARGB(255, 48, 139, 48),
            fontStyle: FontStyle.italic,
            fontSize: 22,
            decoration: TextDecoration.underline,
            decorationColor: Color.fromARGB(255, 48, 139, 48),
          ),),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
        )
        
      ),
    );
  }
}
