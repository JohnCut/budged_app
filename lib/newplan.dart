import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'budgetplan.dart';
import 'bpDB.dart';
import 'dart:async';

import 'dbhelper.dart';
import 'homepage.dart';

class NewPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPlanState();
  }
}

class _NewPlanState extends State<NewPlan> {
  var dbHelper;

  static var now = DateTime.now();
  String currentDay = now.day.toString();
  String currentMonth = now.month.toString();
  String currentYear = now.year.toString();
  String currentTime = DateFormat("H:m:s").format(now);

  final ihTC = TextEditingController();
  final isTC = TextEditingController();
  final tasTC = TextEditingController();
  String ihText, isText, tasText;
  bool verifyPercBool = false;
  int tasAns;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    setState(() {
      ihText = ihTC.text;
      isText = isTC.text;
      tasText = tasTC.text;
    });
  }

  @override
  void dispose() async {
    await dbHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Color.fromRGBO(182, 195, 204, 1.0),
      appBar: AppBar(
        title: Text('Bütçe Planı Yarat'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    margin:
                        EdgeInsets.symmetric(vertical: 40.0, horizontal: 0.0),
                    color: Color.fromRGBO(235, 239, 242, 1.0),
                    child: Column(children: [
                      Text('Zorunlu Harcamalar (İH)',
                          style: TextStyle(
                            color: Color.fromRGBO(18, 31, 38, 1.0),
                            fontSize: 20.0,
                          )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('%',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            Flexible(
                                child: Container(
                              padding: EdgeInsets.all(0.0),
                              margin: EdgeInsets.all(0.0),
                              width: 30.0,
                              child: TextField(
                                scrollPadding: EdgeInsets.all(0.0),
                                controller: ihTC,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                autofocus: true,
                                onChanged: (text) {
                                  setState(() {
                                    ihText = text;
                                    setTasValue(ihText, isText, tasTC.text);
                                    if (ihText == '' ||
                                        isText == '' ||
                                        ihText == null ||
                                        isText == null) {
                                      tasTC.text = '';
                                    } else {
                                      tasTC.text = tasAns.toString();
                                    }
                                  });
                                },
                              ),
                            ))
                          ]),
                      SizedBox(height: 15.0),
                      Text('İsteğe Bağlı Harcamalar (İS)',
                          style: TextStyle(
                            color: Color.fromRGBO(18, 31, 38, 1.0),
                            fontSize: 20.0,
                          )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('%',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            Flexible(
                                child: Container(
                              padding: EdgeInsets.all(0.0),
                              margin: EdgeInsets.all(0.0),
                              width: 30.0,
                              child: TextField(
                                scrollPadding: EdgeInsets.all(0.0),
                                controller: isTC,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                autofocus: true,
                                onChanged: (text) {
                                  setState(() {
                                    isText = text;
                                    setTasValue(ihText, isText, tasTC.text);
                                    if (ihText == '' ||
                                        isText == '' ||
                                        ihText == null ||
                                        isText == null) {
                                      tasTC.text = '';
                                    } else {
                                      tasTC.text = tasAns.toString();
                                    }
                                    print('tasText: $tasText');
                                  });
                                },
                              ),
                            ))
                          ]),
                      SizedBox(height: 15.0),
                      Text('Tasarruf',
                          style: TextStyle(
                            color: Color.fromRGBO(18, 31, 38, 1.0),
                            fontSize: 20.0,
                          )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('%',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            Flexible(
                                child: Container(
                              padding: EdgeInsets.all(0.0),
                              margin: EdgeInsets.all(0.0),
                              width: 30.0,
                              child: TextField(
                                scrollPadding: EdgeInsets.all(0.0),
                                controller: tasTC,
                                keyboardType: TextInputType.number,
                                maxLength: 2,
                                autofocus: true,
                              ),
                            ))
                          ]),
                      SizedBox(height: 25.0),
                      RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text('Plan Oluştur'),
                          onPressed: () {
                            print('$currentDay/$currentMonth/$currentYear $currentTime');
                            verifyPerc();
                            if (verifyPercBool != true) {
                              print('ORANLARIN TOPLAMI 100 OLMALI');
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content:
                                          Text('ORANLARIN TOPLAMI 100 OLMALI'),
                                      contentPadding:
                                          const EdgeInsets.all(16.0),
                                      actions: <Widget>[
                                        FlatButton(
                                            child: Text('TAMAM'),
                                            textColor: Color(0xFFB6B6B6),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    );
                                  });
                            } else {
                              addPlan();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Homepage()));
                            }
                          }),
                    ]),
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  verifyPerc() {
    print('IH: $ihText IS: $isText TAS: ${tasTC.text}');
    if (ihText == '' || isText == '' || tasTC.text == '') {
      setState(() {
        verifyPercBool = false;
      });
    } else {
      if (int.parse(ihText) + int.parse(isText) + int.parse(tasTC.text) != 100) {
        setState(() {
          verifyPercBool = false;
        });
      } else {
        setState(() {
          verifyPercBool = true;
        });
      }
    }
  }

  addPlan() async {
    BudgetPlan e = await BudgetPlan(null, currentDay, currentMonth, currentYear, currentTime, ihText, isText, tasTC.text);
    await dbHelper.insertBP(e);
  }

  setTasValue(String ihV, String isV, String tasV) {
    setState(() {
      if (ihV == '' || isV == '' || ihV == null || isV == null) {
      } else {
        tasAns = 100 - (int.parse(ihV) + int.parse(isV));
        print(tasAns);
      }
    });
  }
}
