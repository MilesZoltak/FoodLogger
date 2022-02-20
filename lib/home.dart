import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/expandable_fab.dart';
import 'package:logger/log.dart';
import 'package:logger/util.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  final String path;

  Home(this.path);

  @override
  _HomeState createState() => _HomeState();
}

List<String> filterByDate(DateTime date, List<String> entries) {
  String dateStr = DateFormat("EEEE, MM/dd/yy").format(date);
  entries = entries.where((entry) => entry.startsWith('"$dateStr')).toList();
  return entries;
}

List<List<String>> parseEntries(List<String> entries) {
  List<List<String>> output = [];
  entries.forEach((entry) {
    String raw = entry;
    List<String> items = raw.split('","');
    int i = 0;
    items.forEach((element) {
      items[i] = element.replaceAll('""', '"');
      i++;
    });
    output.add(items);
  });
  return output;
}

Widget noDataContent(bool noData, DateTime date) {
  if (noData) {
    return Center(
      child: CircularProgressIndicator(),
    );
  } else {
    String msg = "There are no entries for this day.";
    DateTime now = DateTime.now();
    if (isToday(date)) {
      msg += "\nMake a new entry!";
    }
    return Center(
      child: Text(
        msg,
        style: TextStyle(fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }
}

dynamic content(List<String> entry) {
  String header = entry[1]; //"${entry[0].substring(1)} at ${entry[1]}";
  String foodAndDrink = entry[2];
  String place = entry[3];
  bool star = entry[4].isNotEmpty;
  bool v = entry[5].contains("v");
  bool l = entry[5].contains("l");
  String notes = entry[6];
  notes = notes.isEmpty ? "" : notes.substring(0, notes.length - 1);
  List<Widget> items = [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("Food and Drink:", style: TextStyle(fontSize: 18))],
          ),
          Text(
            foodAndDrink,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    ),
    Divider(
      color: Colors.grey,
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Place:",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          Text(
            place,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    ),
    Divider(
      color: Colors.grey,
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Extra Info:", style: TextStyle(fontSize: 18)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(star ? "*" : "",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(v ? "V" : "",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(l ? "L" : "",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    ),
    Divider(
      color: Colors.grey,
    ),
    Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text("Notes:", style: TextStyle(fontSize: 18))],
            ),
            Text(
              notes,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        )),
  ];

  return {header, items};
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();
  return now.day == date.day &&
      now.month == date.month &&
      now.year == date.year;
}

class _HomeState extends State<Home> {
  DateTime date = DateTime.now();
  int numItems = 0;
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: Util().streamFile(widget.path),
      builder: (context, snap) {
        String? data = "";
        List<String> entries = [];
        List<String> entriesToday = [];
        numItems = 0;
        List<List<String>> parsedEntries = [];
        if (snap.hasData) {
          // String? data = snap.data;
          data = snap.data;
          // List<String> entries = data!.trimRight().split("\n");
          entries = data!.trimRight().split("\n");
          // print("entries $entries");
          // List<String> entriesToday = filterByDate(date, entries);
          entriesToday = filterByDate(date, entries);
          // print("entries today $entriesToday");
          numItems = entriesToday.length > 0 ? entriesToday.length : 1;
          // print(entriesToday);
          parsedEntries = parseEntries(entriesToday);
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Food Logger"),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  dynamic result = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Delete All Logs?"),
                          content: Text(
                              "Do you really want to delete all the logs?  You will not be able to recover them."),
                          actions: [
                            TextButton(
                              child: Text(
                                "Ok",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                            ),
                            TextButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                            )
                          ],
                        );
                      });
                  if (result) {
                    await Util().eraseFile();
                    final snackBar = SnackBar(
                      content: Text("Deleted Logs ✓"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.purple,
                      duration: Duration(milliseconds: 500),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    setState(() {});
                  }
                },
              )
            ],
          ),
          floatingActionButton: ExpandableFab(
            distance: 120,
            children: [
              ActionButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  Share.shareFiles([widget.path]);
                },
              ),
              ActionButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () async {},
              ),
              ActionButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  setState(() => edit = !edit);
                },
              ),
              ActionButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () async {
                  dynamic result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Log(title: "Add Entry")));
                  if (result != null) {
                    setState(() => numItems += 1);
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        child: Text(DateFormat("EEEE, MM/dd/yy").format(date)),
                        onPressed: () async {
                          dynamic result = await showDatePicker(
                              context: context,
                              initialDate: date,
                              //TODO: replace the first date with the earliest date where a meal was logged
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 7)),
                              lastDate: DateTime.now());
                          print("result = $result");
                          if (result != null) {
                            setState(() {
                              date = result;
                              print("DATE! $date");
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (parsedEntries.isEmpty) {
                        return noDataContent(
                            snap.connectionState != ConnectionState.done, date);
                      }
                      dynamic output = content(parsedEntries[index]);
                      String header = output.first;
                      List<Widget> items = output.last;
                      return ExpansionTile(
                        title: Text(
                          header,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        children: items,
                        trailing: edit
                            ? ElevatedButton(
                                child: Text("Edit"),
                                onPressed: () {
                                  List<String> data = parsedEntries[index];
                                  List<String> timeList = data[1].split(":");
                                  int hour = int.parse(timeList[0]);
                                  if (timeList[1].contains("P")) hour += 12;
                                  if (hour % 12 == 0) hour -= 12;
                                  int minute =
                                      int.parse(timeList[1].substring(0, 2));
                                  DateTime editDate = DateTime(date.year,
                                      date.month, date.day, hour, minute);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Log(
                                              title: "Edit Entry",
                                              edit: true,
                                              index: index,
                                              date: editDate,
                                              food: data[2],
                                              place: data[3],
                                              star: data[4] == "*",
                                              v: data[5].contains("v"),
                                              l: data[5].contains("l"),
                                              notes: data[6].replaceAll(
                                                  RegExp('"\$'), ""))));
                                  setState(() => edit = false);
                                },
                              )
                            : null,
                      );
                    },
                    itemCount: numItems,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
