import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as crypt;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:logger/expandable_fab.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';

class Util {
  final String? date;

  Util({this.date});

  //* TESTING NEW FILE STORAGE ARCHITECTURE*/
  Future<File> get _localFileTEST async {
    final path = await _localPath;
    return File('$path/logger-$date.json');
  }

  Future<File> createPrefs() async {
    final path = await _localPath;
    final file = File("$path/prefs.json");
    Map prefs = Map();
    prefs["showEntries"] = true;
    return await file.writeAsString(json.encode(prefs));
  }

  Future<Map> readPrefs() async {
    final path = await _localPath;

    File? file;
    if (await File("$path/prefs.json").exists()) {
      file = File("$path/prefs.json");
    } else {
      await createPrefs();
      file = File("$path/prefs.json");
    }

    final contents = await file.readAsString();
    Map prefs = json.decode(contents);
    return prefs;
  }

  Future changePrefs(Map newPrefs) async {
    final path = await _localPath;

    File file = File("$path/prefs.json");
    return await file.writeAsString(json.encode(newPrefs));
  }

  Future<String> readFileTEST() async {
    try {
      final file = await _localFileTEST;

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<List<String>> getDirList() async {
    try {
      final path = await _localPath;
      var dir = new Directory(path);
      List contents = dir.listSync();
      print("contents: $contents");
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> streamFiles() async {
    final path = await _localPath;
    var dir = new Directory(path);
    List contents = dir.listSync();
    List<String> files = [];
    contents.forEach((element) {
      if (element.runtimeType.toString() == "_File") {
        if (element.path.contains("logger-")) files.add(element.path);
      }
    });
    return files;
  }

  // Future<File> addEntry(Map data) {
  //   DateTime day = data["timestamp"];
  //   String filename = "logger-day-${day.millisecondsSinceEpoch}";
  // }

  Future<Map> readFileNEW(String path) async {
    final file = File(path);
    return json.decode(await file.readAsString());
  }

  //DELETE ME
  Future writeDummyFiles() async {
    final path = await _localPath;
    for (int i = 0; i < 10; i++) {
      File f = File('$path/logger-$i.json');
      Map contents = Map();
      contents["name"] = i;
      contents["numDogs"] = i;
      f.writeAsString(json.encode(contents));
    }
  }

  //file io stuff
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print("path = $path");
    return File('$path/cbt-e_logs.json');
  }

  Future<File> writeFile(String data) async {
    final file = await _localFile;

    //sort the entries (bc excel won't interpret it, even tho the app code doesn't require it)
    String sorted = sortEntries(data);

    // Write the file
    return file.writeAsString('$sorted');
  }

  Future<File> eraseFile() async {
    final file = await _localFile;

    //erase file
    return file.writeAsString("");
  }

  //write to file
  Future<File> appendToFile(List<String> data) async {
    String line = data.join(",") + "\n";

    String file = await readFile();
    line = file + line;

    // Write the variable as a string to the file.
    return writeFile(line);
  }

  String sortEntries(String entriesStr) {
    List<String> entries = entriesStr.trimRight().split("\n");
    entries.sort(compareEntries);
    entriesStr = entries.join("\n") + "\n";
    return entriesStr;
  }

  int compareEntries(String a, String b) {
    List<String> aList = a.split('","');
    String aDay = aList[0].substring(1);
    String aTime = aList[1];

    List<String> bList = b.split('","');
    String bDay = bList[0].substring(1);
    String bTime = bList[1];

    DateTime aDate = DateTime.parse("${formatDay(aDay)} ${formatTime(aTime)}");
    DateTime bDate = DateTime.parse("${formatDay(bDay)} ${formatTime(bTime)}");

    return aDate.compareTo(bDate);
  }

  String formatDay(String day) {
    day = day.replaceAll(RegExp(r"\w+,\s"), "");
    List<String> dmy = day.split("/");
    return "20${dmy[2]}-${dmy[0]}-${dmy[1]}";
  }

  String formatTime(String time) {
    List<String> hm = time.replaceAll(RegExp(r" [AP]M"), "").split(":");

    //convert to 24h format
    if (time.contains("PM")) hm[0] = (int.parse(hm[0]) + 12).toString();
    //fix noon and midnight
    if (int.parse(hm[0]) % 12 == 0) hm[0] = (int.parse(hm[0]) - 12).toString();
    //add leading 0 to hours
    if (hm[0].length == 1) hm[0] = "0${hm[0]}";
    // print(hm);

    return hm.join(":") + ":00";
  }

  // Future<File> overwriteFile(List<List<String>> data) async {
  //
  //   List<String> lines = [];
  //   data.forEach((line) {
  //     lines.add(line.join("\n"));
  //   });
  //
  //   String file = lines.join(",");
  //
  //   return writeFile(file);
  // }

  //read from file
  Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> getFile() async {
    return await _localFile;
  }

  Future<String> getFilePath() async {
    File file = await getFile();
    return file.path;
  }

  Stream<String> streamFile(String path) {
    return File(path).openRead().transform(utf8.decoder);
  }

  void clearKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    }
  }

  //this is where all the new stuff is
  Future<File> get _localJSON async {
    final path = await _localPath;
    return File('$path/cbt-e_logs.json');
  }

  //this is where all the new stuff is
  Future<File> get _localShareCSV async {
    final path = await _localPath;
    return File('$path/cbt-e_logs_share.csv');
  }

  Future<File> get _localShareJSON async {
    final path = await _localPath;
    return File('$path/cbt-e_logs_share.json');
  }

  File streamJSON(String path) {
    return File(path);
  }

  Future createJSON() async {
    File file = await _localJSON;
    String data =
        '{"days": [{"${DateFormat("EEEE, MM/dd/yyyy").format(DateTime.now())}": [{"timestamp": ${DateTime.now().millisecondsSinceEpoch}, "food/drink": "pizza", "place": "kitchen table", "extra info": "", "notes": "just your average meal"}]},{"${DateFormat("EEEE, MM/dd/yyyy").format(DateTime.now().add(Duration(days: 2)))}": [{"timestamp": ${DateTime.now().add(Duration(days: 2, hours: 3)).millisecondsSinceEpoch}, "food/drink": "pizza", "place": "kitchen table", "extra info": "", "notes": "just your average meal"}]}]}';
    await file.writeAsString(jsonEncode(data));
  }

  Future<String> readJSON() async {
    //read from file
    try {
      final file = await _localJSON;

      // Read the file
      String fileStr = await file.readAsStringSync();
      final contents = fileStr;
      // final contents = jsonDecode(fileStr);
      return contents;
    } catch (e) {
      print("ERROR: ${e.toString()}");
      return "";
    }
  }

  int compareTimestamps(dynamic a, dynamic b) {
    return a["timestamp"] - b["timestamp"];
  }

  int compareDays(dynamic a, dynamic b) {
    return a[a.keys.first][0]["timestamp"] - b[b.keys.first][0]["timestamp"];
  }

  Future<void> writeJSON(Map<String, dynamic> data) async {
    File file = await _localJSON;
    // String data = '{"days": [{"${DateFormat("EEEE, MM/dd/yyyy").format(DateTime.now())}": [{"timestamp": ${DateTime.now().millisecondsSinceEpoch}, "food/drink": "pizza", "place": "kitchen table", "extra info": "", "notes": "just your average meal"}]},{"${DateFormat("EEEE, MM/dd/yyyy").format(DateTime.now().add(Duration(days: 2)))}": [{"timestamp": ${DateTime.now().add(Duration(days: 2, hours: 3)).millisecondsSinceEpoch}, "food/drink": "pizza", "place": "kitchen table", "extra info": "", "notes": "just your average meal"}]}]}';
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>> appendJSON(Map<String, dynamic> addition) async {
    String contents = await readJSON();
    List days = contents.isNotEmpty ? jsonDecode(contents)["days"] : [];
    print("addition: $addition");
    String day = DateFormat("EEEE, MM/dd/yyyy")
        .format(DateTime.fromMillisecondsSinceEpoch(addition["timestamp"]));
    // print(days);

    //decalre i here bc we will need it outside the loop
    int i = 0;
    for (i = 0; i < days.length; i++) {
      String entryDay = days[i].keys.first;

      //this means we are adding to an existing day
      if (day == entryDay) {
        List entries = days[i][entryDay];
        entries.add(addition);
        entries.sort(compareTimestamps);
        i = days.length + 1;
      }
    }

    //this means we are adding a new day
    if (i == days.length) {
      Map<String, dynamic> newDay = {};
      newDay[day] = [addition];
      days.add(newDay);
    }
    //sort days (rare but necessary)
    days.sort(compareDays);
    // print(days);

    Map<String, dynamic> data = {};
    data["days"] = days;
    await writeJSON(data);

    //return the new data so that we can update the ui bc state management sucks
    return data;
  }

  Future<Map<String, dynamic>> deleteJSONEntry(
      int dayIndex, int mealIndex) async {
    String contents = await readJSON();
    List days = contents.isNotEmpty ? jsonDecode(contents)["days"] : [];
    if (days[dayIndex].values.first.length > 1) {
      Map<String, dynamic> thinned = {};
      List keep = days[dayIndex].values.first;
      keep.removeAt(mealIndex);
      thinned[days[dayIndex].keys.first] = keep;
      days[dayIndex] = thinned;
    } else {
      days.removeAt(dayIndex);
    }

    Map<String, dynamic> data = {};
    data["days"] = days;
    await writeJSON(data);

    //return the new data so that we can update the ui bc state management sucks
    return data;
  }

  Future<Map<String, dynamic>> deleteJSONRange(
      DateTime start, DateTime end) async {
    String contents = await readJSON();
    List days = contents.isNotEmpty ? jsonDecode(contents)["days"] : [];
    int startIndex = -1;
    int endIndex = -1;

    for (int i = 0; i < days.length; i++) {
      DateTime firstEntryOfDay = DateTime.fromMillisecondsSinceEpoch(
          days[i].values.first[0]["timestamp"]);
      if (startIndex < 0 && start.isBefore(firstEntryOfDay)) startIndex = i;
      if (firstEntryOfDay.isBefore(end.add(Duration(days: 1))))
        endIndex = i + 1;
    }
    days.removeRange(startIndex, endIndex);
    Map<String, dynamic> data = {};
    data["days"] = days;
    await writeJSON(data);

    //return the new data so that we can update the ui bc state management sucks
    return data;
  }

  Future<Map<String, dynamic>> replaceJSON(
      Map<String, dynamic> replacement, int dayIndex, int mealIndex) async {
    //first delete the thing we are replacing
    await deleteJSONEntry(dayIndex, mealIndex);

    //now write the new data
    Map<String, dynamic> data = await appendJSON(replacement);

    return data;
  }

  Future<String> shareAsCSV(
      Map<String, dynamic> data, DateTime start, DateTime end) async {
    List<String> lines = [];
    List days = data["days"];

    days.forEach((day) {
      String dayStr = day.keys.first;
      List entries = day.values.first;
      entries.forEach((entry) {
        //check if we even need to add this
        DateTime entryTime =
            DateTime.fromMillisecondsSinceEpoch(entry["timestamp"]);

        if (entryTime.isAfter(start) &&
            entryTime.isBefore(end.add(Duration(days: 1)))) {
          String time = DateFormat("jm").format(entryTime);
          String food = entry["Food/Drink"];
          String place = entry["Place"];
          String star = entry["Extra Info"].contains("*") ? "*" : "";
          String vl =
              entry["Extra Info"].replaceFirst("*,", "").replaceFirst("*", "");
          String notes = entry["Notes"];
          String line =
              '"$dayStr","$time","$food","$place","$star","$vl","$notes"';
          lines.add(line);
          print(line);
        }
      });
    });

    String raw = lines.join("\n");
    final file = await _localShareCSV;
    File csv = await file.writeAsString(raw);
    return "${await _localPath}/cbt-e_logs_share.csv";
  }

  Future deleteShareCSV() async {
    final file = await _localShareCSV;
    await file.delete();
  }

  Future deleteShareJSON() async {
    final file = await _localShareJSON;
    await file.delete();
  }

  Map<String, dynamic> trimmedData(
      Map<String, dynamic> data, DateTime start, DateTime end) {
    List days = data["days"];
    days = days
        .where((day) =>
            DateTime.fromMillisecondsSinceEpoch(
                    day.values.first.first["timestamp"])
                .isBefore(end.add(Duration(days: 1))) &&
            DateTime.fromMillisecondsSinceEpoch(
                    day.values.first.first["timestamp"])
                .isAfter(start))
        .toList();
    data["days"] = days;

    return data;
  }

  Future<String> shareAsJSON(
      Map<String, dynamic> data, DateTime start, DateTime end) async {
    data = trimmedData(data, start, end);

    final file = await _localShareJSON;
    File json = await file.writeAsString(jsonEncode(data));
    return "${await _localPath}/cbt-e_logs_share.json";
  }

  Future<Map<String, dynamic>> readShareJSON(String path) async {
    //read from file
    try {
      final file = File(path);

      // Read the file
      String fileStr = file.readAsStringSync();
      // final contents = fileStr;
      final contents = jsonDecode(fileStr);
      return contents;
    } catch (e) {
      print("ERROR: ${e.toString()}");
      return {};
    }
  }

  Future uploadDoc(String logs) async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable("uploadLogs");
    try {
      final key = crypt.Key.fromLength(32);
      String utf8Key = DateTime.now().microsecondsSinceEpoch.toString();
      final iv = crypt.IV.fromUtf8(utf8Key);
      final encrypter = crypt.Encrypter(crypt.AES(key));
      final encrypted = encrypter.encrypt(logs, iv: iv);
      print(utf8Key);
      final results = await callable({
        "bytes": encrypted.bytes.toList(),
        "base16": encrypted.base16,
        "base64": encrypted.base64
      });
      print("Upload successful!");
      return {utf8Key, results.data};
    } catch (e) {
      print("ERROR: ${e.toString()}");
    }
  }

  Future readDoc(String docName, String utf8Key) async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable("readLogs");
    try {
      final results = await callable({"docName": docName});
      final iv = crypt.IV.fromUtf8(utf8Key);
      dynamic output = results.data;
      List lst = output["bytes"];
      List<int> ints = lst.map((e) => int.parse(e.toString())).toList();
      final encrypted = crypt.Encrypted(Uint8List.fromList(ints));
      final decrypted = crypt.Encrypter(crypt.AES(crypt.Key.fromLength(32)))
          .decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      print("ERROR: ${e.toString()}");
    }
  }
}
