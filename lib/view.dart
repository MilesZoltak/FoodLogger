import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class View extends StatefulWidget {
  final Map<String, dynamic>? data;

  View({this.data});

  @override
  _ViewState createState() => _ViewState();
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
            Text(
              entry[key],
              style: TextStyle(fontSize: 18),
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

class _ViewState extends State<View> {
  //qr scanning stuff
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  late Barcode result;

  // late BuildContext context_BABY;
  QRViewController? controller;
  Map<String, dynamic> data = {};

  @override
  void reassemble() {
    super.reassemble();

    if (controller == null) return;

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      String qrString = result.code;
      Map<String, dynamic> qrJSON = jsonDecode(qrString);
      String decrypted = await Util().readDoc(qrJSON["docName"], qrJSON["key"]);
      setState(() => data = jsonDecode(decrypted));
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  PageController _pageController = PageController();
  DateTime date = DateTime.now();
  int pageCount = 1;
  int pageIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (data.length == 0 && widget.data != null) {
      data = widget.data!;
    }

    if (data.length != 0) pageCount = data["days"].length;
    if (pageIndex < 0) pageIndex = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text("View Logs"),
      ),
      body: Center(
          child: data.length == 0
              ? QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: double.maxFinite * 0.75),
                )
              : Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                          itemCount: pageCount,
                          controller: _pageController,
                          onPageChanged: (val) async {
                            await Future.delayed(Duration(milliseconds: 100));
                            setState(() => pageIndex = val);
                          },
                          itemBuilder: (context, dayIndex) {
                            print(dayIndex);
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
                                            return ExpansionTile(
                                              title: Text(
                                                DateFormat.jm().format(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        entry["timestamp"])),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              children: getEntryData(entry),
                                            );
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
                )),
    );
  }
}
