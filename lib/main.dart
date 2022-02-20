import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:logger/expandable_fab.dart';
import 'package:logger/home.dart';
import 'package:logger/homeV2.dart';
import 'package:logger/log.dart';
import 'package:flutter/material.dart';
import 'package:logger/util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

Future<String> futureContents() async {
  return await Util().readFile();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Food Logger",
          theme: ThemeData(
            primarySwatch: Colors.purple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder<String>(
              future: Util().getFilePath(),
              builder: (context, future) {
                if (!future.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                String path = future.data!;
                return Home2(path);
              }),
        ),
        onTap: () {
          Util().clearKeyboard(context);
        });
  }
}
