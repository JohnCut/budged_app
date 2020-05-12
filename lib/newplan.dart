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
  int curUserId;
  var dbHelper;

  static var now = DateTime.now();
  static var formatNow = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);
  String nowString = "${formatNow.toString()}";

  final ihTC = TextEditingController();
  final isTC = TextEditingController();
  final tasTC = TextEditingController();
  String ihText, isText, tasText;
  bool verifyPercBool = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
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
      body: Center(
        child: Column(children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 0.0),
            color: Color.fromRGBO(235, 239, 242, 1.0),
            child: Column(children: [
              Text('Zorunlu Harcamalar (İH)',
                  style: TextStyle(
                    color: Color.fromRGBO(18, 31, 38, 1.0),
                    fontSize: 20.0,
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('%',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                  ),
                ))
              ]),
              SizedBox(height: 15.0),
              Text('İsteğe Bağlı Harcamalar (İS)',
                  style: TextStyle(
                    color: Color.fromRGBO(18, 31, 38, 1.0),
                    fontSize: 20.0,
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('%',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                  ),
                ))
              ]),
              SizedBox(height: 15.0),
              Text('Tasarruf',
                  style: TextStyle(
                    color: Color.fromRGBO(18, 31, 38, 1.0),
                    fontSize: 20.0,
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('%',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
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
                    print(nowString);
                    verifyPerc();
                    if (verifyPercBool != true) {
                      print('ORANLARIN TOPLAMI 100 OLMALI');
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('ORANLARIN TOPLAMI 100 OLMALI'),
                              contentPadding: const EdgeInsets.all(16.0),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Homepage()));
                    }
                  }),
            ]),
          )
        ]),
      ),
    ));
  }

  getTFValue() {
    setState(() {
      ihText = ihTC.text;
      isText = isTC.text;
      tasText = tasTC.text;
    });
    print('İH: $ihText, İS: $isText, TAS: $tasText');
  }

  verifyPerc() {
    getTFValue();
    if (ihText == '' || isText == '' || tasText == '') {
      setState(() {
        verifyPercBool = false;
      });
    } else {
      if (int.parse(ihText) + int.parse(isText) + int.parse(tasText) != 100) {
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
    BudgetPlan e = await BudgetPlan(null, nowString, ihText, isText, tasText);
    await dbHelper.save(e);
  }
}
