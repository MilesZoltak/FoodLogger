import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/expandable_fab.dart';
import 'package:logger/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/homeV2.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map? prefs;
  bool init = true;
  bool status = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: FutureBuilder<Map>(
            future: Util().readPrefs(),
            builder: (context, future) {
          if (!future.hasData) return Center(child: CircularProgressIndicator());

          if (init) {
            prefs = future.data;
            init = false;
          }

          return Center(
              child: Column(
                children: [
                  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Text(
                    "Do you want to see your logs?",
                    style: TextStyle(fontSize: 20),
                  ),
                  Checkbox(
                      value: prefs!["showEntries"],
                      onChanged: (val) {
                        setState(() => prefs!["showEntries"] = val);
                      })
            ],
          ),

                    ElevatedButton(child: Text("Save"), onPressed: () async {
                    print(prefs);
                    await Util().changePrefs(prefs!);
                    Navigator.pop(context, prefs!["showEntries"]);
                    setState(() => {});
                  },)
                ],
              ));
        }));
  }
}
