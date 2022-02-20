
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/util.dart';

class Log2 extends StatefulWidget {
  final String title;

  //for editings
  final bool? edit;
  final int? dayIndex;
  final int? mealIndex;
  final DateTime? date;
  final String? food;
  final String? place;
  final bool? star;
  final bool? v;
  final bool? l;
  final String? notes;

  Log2(
      {Key? key,
      required this.title,
      this.edit,
      this.dayIndex,
      this.mealIndex,
      this.date,
      this.food,
      this.place,
      this.star,
      this.v,
      this.l,
      this.notes})
      : super(key: key);

  @override
  _Log2State createState() => _Log2State();
}

class _Log2State extends State<Log2> {
  void tapped(int step) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
    } else {
      setState(() => _currentStep = step);
    }
  }

  Future<void> continued() async {
    if (_currentStep < 4) {
      setState(() => _currentStep += 1);
    } else {
      setState(() => _incomplete = false);

      List<String> extraInfo = [];
      if (star) extraInfo.add("*");
      if (v) extraInfo.add("V");
      if (l) extraInfo.add("L");

      Map<String, dynamic> entry = {};
      entry["timestamp"] = date.millisecondsSinceEpoch;
      entry["Food/Drink"] = food;
      entry["Place"] = place;
      entry["Extra Info"] =
          extraInfo.toString().replaceAll(RegExp(r"[\[\]]"), "");
      entry["Notes"] = notes;

      late Map<String, dynamic> latest;
      if (widget.edit == true) {
        latest = await Util()
            .replaceJSON(entry, widget.dayIndex!, widget.mealIndex!);
        print("lastest:\n $latest");
      } else {
        latest = await Util().appendJSON(entry);
      }

      String snackText =
          widget.edit == true ? "Saved Updates ✓" : "Entry Saved ✓";
      final snackBar = SnackBar(
        content: Text(snackText),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.purple,
        duration: Duration(milliseconds: 500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      await Future.delayed(Duration(milliseconds: 600));
      Navigator.pop(context, latest);
    }
    Util().clearKeyboard(context);
  }

  void cancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
    setState(() => _incomplete = true);
    Util().clearKeyboard(context);
  }

  void resetStepper() {
    setState(() {
      _currentStep = 0;
      _incomplete = true;

      date = DateTime.now();

      food = "";
      _foodController.clear();
      place = "";
      _placeController.clear();
      star = false;
      v = false;
      l = false;
      notes = "";
      _notesController.clear();
    });
  }

  //stepper stuff
  int _currentStep = 0;
  bool _incomplete = true;

  //date and time stuff
  DateTime date = DateTime.now();
  DateTime time = DateTime.now();

  //text entry stuff
  InputDecoration tid = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 2)),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.purple, width: 2)),
    hintStyle: TextStyle(fontSize: 20),
    contentPadding: EdgeInsets.all(10),
  );
  String food = "";
  TextEditingController _foodController = TextEditingController();
  String place = "";
  TextEditingController _placeController = TextEditingController();
  bool star = false;
  bool v = false;
  bool l = false;
  String notes = "";
  TextEditingController _notesController = TextEditingController();

  Map<String, dynamic> entry = {};

  @override
  void initState() {
    if (widget.edit == true) {
      //autofill the text form fields
      date = widget.date!;
      _foodController.text = widget.food!;
      _placeController.text = widget.place!;
      star = widget.star!;
      v = widget.v!;
      l = widget.l!;
      _notesController.text = widget.notes!;

      //also fill in the variables that will be used to send the data off at the end
      food = widget.food!;
      place = widget.place!;
      notes = widget.notes!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //bullshit i need for the controls
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    const OutlinedBorder buttonShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)));
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 16.0);

    final Color cancelColor;
    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    bool _isDark() {
      return Theme.of(context).brightness == Brightness.dark;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Reset",
            onPressed: () {
              resetStepper();
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stepper(
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: details.onStepContinue,
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                            return states.contains(MaterialState.disabled)
                                ? null
                                : (_isDark()
                                    ? colorScheme.onSurface
                                    : colorScheme.onPrimary);
                          }),
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                            return _isDark() ||
                                    states.contains(MaterialState.disabled)
                                ? null
                                : colorScheme.primary;
                          }),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  buttonPadding),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              buttonShape),
                        ),
                        child: Text(_currentStep < 4 ? "Next" : "Save"),
                      ),
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 8.0),
                        child: TextButton(
                          onPressed: details.onStepCancel,
                          style: TextButton.styleFrom(
                            primary: cancelColor,
                            padding: buttonPadding,
                            shape: buttonShape,
                          ),
                          child: Text("Back"),
                        ),
                      ),
                    ],
                  );
                },
                type: StepperType.vertical,
                physics: ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                steps: <Step>[
                  Step(
                      title: Text("Date and Time"),
                      content: Column(
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.calendar_today),
                                  label: Text(DateFormat("EEEE, MM/dd/yy")
                                      .format(date)),
                                  onPressed: () async {
                                    //set date and time if we are editing (to be equal to entry)
                                    if (widget.edit == true) {
                                      date = widget.date!;
                                      time = widget.date!;
                                    }
                                    //pick a new date
                                    dynamic newDate = await showDatePicker(
                                        context: context,
                                        initialDate: date,
                                        firstDate: DateTime.now()
                                            .subtract(Duration(days: 50)),
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 50)));
                                    if (newDate != null) {
                                      newDate = newDate.add(Duration(
                                          hours: time.hour,
                                          minutes: time.minute));
                                      setState(() => date = newDate);
                                    }
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.access_time),
                                  label: Text(DateFormat("jm").format(date)),
                                  onPressed: () async {
                                    //pick a new time of day
                                    TimeOfDay? newTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay(
                                            hour: time.hour,
                                            minute: time.minute));
                                    if (newTime != null) {
                                      DateTime newDate = date.subtract(Duration(
                                          hours: date.hour,
                                          minutes: date.minute));
                                      newDate = newDate.add(Duration(
                                          hours: newTime.hour,
                                          minutes: newTime.minute));
                                      time = newDate;
                                      setState(() => date = newDate);
                                    }
                                  },
                                )
                              ]),
                        ],
                      ),
                      isActive: _currentStep == 0,
                      state: _currentStep >= 0
                          ? StepState.complete
                          : StepState.disabled),
                  Step(
                      title: Text("Food and Drink Consumed"),
                      content: Scrollbar(
                        child: TextFormField(
                          onChanged: (val) {
                            setState(() {
                              food = val;
                            });
                          },
                          controller: _foodController,
                          decoration: tid.copyWith(
                              hintText: "Food & Drink",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => _foodController.clear(),
                              )),
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      isActive: _currentStep == 1,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled),
                  Step(
                      title: Text("Place"),
                      content: Scrollbar(
                        child: TextFormField(
                          onChanged: (val) {
                            setState(() {
                              place = val;
                            });
                          },
                          controller: _placeController,
                          decoration: tid.copyWith(
                              hintText: "Place",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => _placeController.clear(),
                              )),
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      isActive: _currentStep == 2,
                      state: _currentStep >= 2
                          ? StepState.complete
                          : StepState.disabled),
                  Step(
                      title: Text("Extra Info"),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 100),
                            child: CheckboxListTile(
                                title: Text("*"),
                                value: star,
                                onChanged: (val) {
                                  setState(() {
                                    star = val!;
                                  });
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 100),
                            child: CheckboxListTile(
                                title: Text("V"),
                                value: v,
                                onChanged: (val) {
                                  setState(() {
                                    v = val!;
                                  });
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 100),
                            child: CheckboxListTile(
                                title: Text("L"),
                                value: l,
                                onChanged: (val) {
                                  setState(() {
                                    l = val!;
                                  });
                                }),
                          ),
                        ],
                      ),
                      isActive: _currentStep == 3,
                      state: _currentStep >= 3
                          ? StepState.complete
                          : StepState.disabled),
                  Step(
                      title: Text("Context and Comments"),
                      content: Scrollbar(
                        child: TextFormField(
                          onChanged: (val) {
                            setState(() {
                              notes = val;
                            });
                          },
                          controller: _notesController,
                          decoration: tid.copyWith(
                              hintText: "Context...",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () => _notesController.clear(),
                              )),
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      isActive: _currentStep == 4,
                      state: _currentStep >= 4 && _incomplete
                          ? StepState.complete
                          : StepState.disabled)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
