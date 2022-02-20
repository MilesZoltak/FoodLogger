import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/expandable_fab.dart';
import 'package:logger/help.dart';
import 'package:logger/logV2.dart';
import 'package:logger/share.dart';
import 'package:logger/util.dart';
import 'package:logger/settings.dart';
import 'package:logger/view.dart';

class Home2 extends StatefulWidget {
  final String path;

  Home2(this.path);

  @override
  _Home2State createState() => _Home2State();
}

Widget deleteBackground() {
  return Container(
    color: Colors.red,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        )
      ],
    ),
  );
}

Widget editBackground() {
  return Container(
    color: Colors.green,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ))
      ],
    ),
  );
}

List<Widget> getEntryData(dynamic entry) {
  List<Widget> content = [];
  entry.keys.forEach((key) {
    if (key != "timestamp") {
      content.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "$key:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ));
      content.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                entry[key],
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ));
      content.add(Divider(
        color: Colors.grey,
      ));
    }
  });
  return content;
}

Future selectDate(context, List days, DateTime initialDate) async {
  DateTime first = DateTime.fromMillisecondsSinceEpoch(
      days.first.values.first[0]["timestamp"]);
  DateTime last = DateTime.fromMillisecondsSinceEpoch(
      days.last.values.first[0]["timestamp"]);
  return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      selectableDayPredicate: (DateTime date) {
        String selectedDate = DateFormat("EEEE, MM/dd/yyyy").format(date);
        return days.where((day) => day.keys.first == selectedDate).isNotEmpty;
      });
}

class _Home2State extends State<Home2> {
  PageController _pageController = PageController();
  DateTime date = DateTime.now();
  int pageCount = 1;
  int pageIndex = -1;
  Map<String, dynamic> data = {};
  bool showEntries = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logger"),
        actions: [
          IconButton(
            icon: Icon(Icons.warning_rounded),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Help()));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              var result = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));

              if (result != null) {
                setState(() => showEntries = result);
              }
            },
          )
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 100,
        children: [
          ActionButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              if (data["days"] == null || data["days"].isEmpty) {
                String snackText = "There is nothing to delete.";
                final snackBar = SnackBar(
                  content: Text(snackText),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.purple,
                  duration: Duration(milliseconds: 500),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
              dynamic result = await showDialog(
                context: context,
                builder: (context) {
                  bool deleteAll = true;
                  return StatefulBuilder(builder: (context, stateSetter) {
                    DateTime first = DateTime.fromMillisecondsSinceEpoch(
                        data["days"].first.values.first[0]["timestamp"]);
                    DateTime last = DateTime.fromMillisecondsSinceEpoch(
                        data["days"].last.values.first[0]["timestamp"]);
                    return DateRangePickerDialog(
                      firstDate: first,
                      lastDate: last,
                      helpText: "Delete Days",
                      saveText: "Delete",
                    );
                  });
                },
              );
              if (result.runtimeType == DateTimeRange) {
                DateTimeRange range = result;

                Map<String, dynamic> latest =
                    await Util().deleteJSONRange(range.start, range.end);

                setState(() {
                  data = latest;
                  pageCount = data["days"].length;
                  if (pageIndex >= pageCount) pageIndex = pageCount - 1;
                });
              }
            },
          ),
          ActionButton(
            icon: Icon(Icons.qr_code_scanner_sharp),
            onPressed: () async {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => View()));
            },
          ),
          ActionButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (data["days"] == null || data["days"].isEmpty) {
                String snackText = "There is nothing to delete.";
                final snackBar = SnackBar(
                  content: Text(snackText),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.purple,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShareCenter(data)));
            },
          ),
          ActionButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              dynamic latest = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Log2(title: "Add Entry")));
              if (latest != null) {
                setState(() {
                  data = latest;
                  pageCount = data["days"].length;
                  if (pageIndex >= pageCount) pageIndex = pageCount - 1;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
          child: StreamBuilder(
        stream:
            Util().streamJSON(widget.path).openRead().transform(utf8.decoder),
        builder: (context, snap) {
          Widget noData = Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "You have no logs.\nTap the purple button to get started!",
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ));
          if (!snap.hasData && snap.connectionState == ConnectionState.done) {
            return noData;
          } else if (!snap.hasData) {
            return CircularProgressIndicator();
          }
          data = jsonDecode(snap.data.toString());
          if (data["days"].isEmpty) {
            return noData;
          }

          pageCount = data["days"].length;
          if (pageIndex < 0) {
            pageIndex = pageCount - 1;
            _pageController = PageController(initialPage: pageIndex);
          }

          return FutureBuilder<Map>(
              future: Util().readPrefs(),
              builder: (context, future) {
                if (!future.hasData)
                  return Center(child: CircularProgressIndicator());
                showEntries = future.data!["showEntries"];
                if (!showEntries) {
                  return Center(
                      child: Text(
                    "You're doing great.",
                    style: TextStyle(fontSize: 20),
                  ));
                }
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                          itemCount: pageCount,
                          controller: _pageController,
                          onPageChanged: (dayIndex) async {
                            await Future.delayed(Duration(milliseconds: 100));
                            setState(() => pageIndex = dayIndex);
                          },
                          itemBuilder: (context, dayIndex) {
                            String day = data["days"][pageIndex].keys.first;
                            List dayEntries = data["days"][pageIndex][day];
                            return Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        DateTime initialDate =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                dayEntries[0]["timestamp"]);
                                        dynamic selectedDate = await selectDate(
                                            context, data["days"], initialDate);
                                        try {
                                          selectedDate =
                                              DateFormat("EEEE, MM/dd/yyyy")
                                                  .format(selectedDate);
                                          //sets pageindex to the index of selected date (made a list of all keys in ["days"] and then did index of B^) p cool i think)
                                          setState(() => pageIndex =
                                              data["days"]
                                                  .map((e) => e.keys.first)
                                                  .toList()
                                                  .indexOf(selectedDate));
                                        } catch (e) {
                                          print("ERROR: ${e.toString()}");
                                        }
                                      },
                                    )),
                                Expanded(
                                  child: dayEntries.isEmpty
                                      ? Center(
                                          child: Text(
                                          "There are no entries for this day.",
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      : ListView.builder(
                                          itemBuilder: (context, mealIndex) {
                                            dynamic entry =
                                                dayEntries[mealIndex];
                                            return Dismissible(
                                                key: UniqueKey(),
                                                confirmDismiss: (dir) async {
                                                  if (dir ==
                                                      DismissDirection
                                                          .startToEnd) {
                                                    return true ==
                                                        await showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title: Text(
                                                                          "Delete Entry?"),
                                                                      content: Text(
                                                                          "Are you sure you want to delete this entry?  You will not be able to retrieve it."),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(fontSize: 18, color: Colors.green),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context,
                                                                                false);
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                          child:
                                                                              Text(
                                                                            "OK",
                                                                            style:
                                                                                TextStyle(fontSize: 18, color: Colors.red),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            dynamic
                                                                                latest =
                                                                                await Util().deleteJSONEntry(dayIndex, mealIndex);
                                                                            setState(() =>
                                                                                data = latest);
                                                                            Navigator.pop(context,
                                                                                true);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ));
                                                  } else {
                                                    dynamic latest =
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Log2(
                                                                          title:
                                                                              "Edit Entry",
                                                                          edit:
                                                                              true,
                                                                          dayIndex:
                                                                              pageIndex,
                                                                          mealIndex:
                                                                              mealIndex,
                                                                          date:
                                                                              DateTime.fromMillisecondsSinceEpoch(entry["timestamp"]),
                                                                          food:
                                                                              entry["Food/Drink"],
                                                                          place:
                                                                              entry["Place"],
                                                                          star:
                                                                              entry["Extra Info"].contains("*"),
                                                                          v: entry["Extra Info"]
                                                                              .contains("V"),
                                                                          l: entry["Extra Info"]
                                                                              .contains("L"),
                                                                          notes:
                                                                              entry["Notes"],
                                                                        )));
                                                    if (latest != null) {
                                                      setState(() {
                                                        data = latest;
                                                        pageCount =
                                                            data["days"].length;
                                                        pageIndex = pageIndex >=
                                                                pageCount
                                                            ? pageCount - 1
                                                            : pageIndex;
                                                      });
                                                    }
                                                    return false;
                                                  }
                                                },
                                                background: deleteBackground(),
                                                secondaryBackground:
                                                    editBackground(),
                                                child: ExpansionTile(
                                                  title: Text(
                                                    DateFormat.jm().format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            entry[
                                                                "timestamp"])),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  children: getEntryData(entry),
                                                ));
                                          },
                                          itemCount: dayEntries.length,
                                        ),
                                )
                              ],
                            );
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 50),
                              child: Container(
                                width: pageIndex == 0 ? 10 : 7,
                                height: pageIndex == 0 ? 10 : 7,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: pageCount > 2,
                            child: Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 50),
                                child: Container(
                                  width: pageIndex != pageCount - 1 &&
                                          pageIndex > 0
                                      ? 10
                                      : 7,
                                  height: pageIndex != pageCount - 1 &&
                                          pageIndex > 0
                                      ? 10
                                      : 7,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: pageCount > 1,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 50),
                              child: Container(
                                width: pageIndex == pageCount - 1 ? 10 : 7,
                                height: pageIndex == pageCount - 1 ? 10 : 7,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              });
        },
      )),
    );
  }
}
