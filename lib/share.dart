import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/util.dart';
import 'package:logger/view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

class ShareCenter extends StatefulWidget {
  final Map<String, dynamic> data;

  ShareCenter(this.data);

  @override
  _ShareCenterState createState() => _ShareCenterState();
}

class _ShareCenterState extends State<ShareCenter> {
  String startStr = "";
  String endStr = "";

  late DateTime start;
  late DateTime end;

  @override
  Widget build(BuildContext context) {

    DateTime dataStart = DateTime.fromMillisecondsSinceEpoch(
        widget.data["days"].first.values.first.first["timestamp"]);
    DateTime dataEnd = DateTime.fromMillisecondsSinceEpoch(
        widget.data["days"].last.values.first.first["timestamp"]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Share"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                child: Text(startStr.isNotEmpty && endStr.isNotEmpty
                    ? "$startStr - $endStr"
                    : "Select Dates"),
                onPressed: () async {
                  dynamic result = await showDialog(
                      context: context,
                      builder: (context) {
                        return DateRangePickerDialog(
                            firstDate: dataStart, lastDate: dataEnd);
                      });

                  if (result != null) {
                    setState(() {
                      start = result.start;
                      startStr =
                          DateFormat("EEEE, MM/dd/yyyy").format(result.start);
                      end = result.end;
                      endStr =
                          DateFormat("EEEE, MM/dd/yyyy").format(result.end);
                    });
                  }
                },
              ),
              Visibility(
                visible: startStr.isNotEmpty && endStr.isNotEmpty,
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Share in app:",
                          style: TextStyle(fontSize: 28),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text("Share File"),
                        onPressed: () async {
                          String jsonPath =
                              await Util().shareAsJSON(widget.data, start, end);
                          await Share.shareFiles([jsonPath],
                              subject: "Logs", text: "Shared via Logger <3");
                          await Util().deleteShareJSON();
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.qr_code_2),
                        label: Text("Share QR"),
                        onLongPress: () async {
                          String docName = "nneT26wcqKl6hXEsxdiw";
                          String key = "1632173286115464";
                          print("this is the read: ${await Util().readDoc(docName, key)}");
                        },
                        onPressed: () async {
                          Map<String, dynamic> trimmed =
                              Util().trimmedData(widget.data, start, end);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return FutureBuilder(
                                  future: Util().uploadDoc(jsonEncode(trimmed)),
                                  builder: (context, future) {
                                    if (!future.hasData) {
                                      return CircularProgressIndicator();
                                    }
                                    dynamic outputs = future.data;
                                    Map<String, dynamic> keys = {"key": outputs.first, "docName": outputs.last};
                                    String qr_data = jsonEncode(keys);
                                    return AlertDialog(
                                        title: Text("Scan In App"),
                                        content: Container(
                                          width: double.maxFinite,
                                          child: QrImage(
                                            errorStateBuilder: (contextio, errorState) {
                                              print("damn");
                                              return Text("damn");
                                            },
                                            data: qr_data,
                                            version: QrVersions.auto,
                                          ),
                                        ));
                                  }
                                );
                              });
                        },
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Share as spreadsheet:",
                          style: TextStyle(fontSize: 28),
                        )),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.grid_on_sharp),
                    label: Text("Share"),
                    onPressed: () async {
                      String csvPath =
                          await Util().shareAsCSV(widget.data, start, end);
                      await Share.shareFiles([csvPath],
                          subject: "Logs", text: "Shared via Logger <3");
                      await Util().deleteShareCSV();
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Receive Logs:",
                          style: TextStyle(fontSize: 28),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.folder_open),
                        label: Text("Open File"),
                        onPressed: () async {
                          String? filePath = "";
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null) {
                            filePath = result.files.single.path;
                            Map<String, dynamic> data =
                                await Util().readShareJSON(filePath!);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => View(data: data)));
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.qr_code_scanner_sharp),
                        label: Text("Scan QR"),
                        onPressed: () async {
                          // dynamic qrResult = await showDialog(
                          //     context: context,
                          //     builder: (context) {
                          //       return AlertDialog(
                          //         content: Flexible(
                          //           child: Container(
                          //             width: double.maxFinite,
                          //             height: double.maxFinite,
                          //             child: QRView(
                          //               key: qrKey,
                          //               onQRViewCreated: _onQRViewCreated,
                          //               overlay: QrScannerOverlayShape(
                          //                   borderColor: Colors.red,
                          //                   borderRadius: 10,
                          //                   borderLength: 30,
                          //                   borderWidth: 10,
                          //                   cutOutSize: double.maxFinite - 8),
                          //             ),
                          //           ),
                          //         ),
                          //       );
                          //     });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => View()));
                        },
                      )
                    ],
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
