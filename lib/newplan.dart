import 'package:flutter/material.dart';

import 'budgetplan.dart';
import 'homepage.dart';

class NewPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPlanState();
  }
}

class _NewPlanState extends State<NewPlan> {
  final ihTC = TextEditingController();
  final isTC = TextEditingController();
  final tasTC = TextEditingController();
  String ihText, isText, tasText;
  bool verifyPercBool = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Bütçe Planı Yarat'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Homepage()));
              }),
        ],
      ),
      body: Center(
        child: Column(children: [
          Container(
            child: Column(children: [
              Text('Zorunlu Harcamalar (İH)'),
              Row(children: [
                Text(
                  '%',
                ),
                Flexible(
                    child: TextField(
                  controller: ihTC,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  autofocus: true,
                ))
              ]),
              Text('İsteğe Bağlı Harcamalar (İS)'),
              Row(children: [
                Text(
                  '%',
                ),
                Flexible(
                    child: TextField(
                  controller: isTC,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                ))
              ]),
              Text('Tasarruf'),
              Row(children: [
                Text(
                  '%',
                ),
                Flexible(
                    child: TextField(
                  controller: tasTC,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                ))
              ]),
              RaisedButton(
                  child: Text('Plan Oluştur'),
                  onPressed: () {
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Plan(
                                  ihText: ihText,
                                  isText: isText,
                                  tasText: tasText)));
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
