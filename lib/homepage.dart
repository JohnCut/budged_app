import 'package:flutter/material.dart';

import 'budgetplan.dart';
import 'newplan.dart';

class Homepage extends StatefulWidget {
  final String ihText, isText, tasText;
  Homepage({
    this.ihText,
    this.isText,
    this.tasText,
  });
  _HomepageState createState() => _HomepageState(ihText, isText, tasText);
}

class _HomepageState extends State<Homepage> {
  final String ihText, isText, tasText;
  _HomepageState(this.ihText, this.isText, this.tasText);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: Text('Anasayfaların En Güzeli'),
        ),
        body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          RaisedButton(
            onPressed: () {
              if (ihText == null && isText == null && tasText == null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('ÖNCE BİR BÜTÇE PLANI OLUŞTURULMALI.'),
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
                            ihText: ihText, isText: isText, tasText: tasText)));
              }
            },
            child: Text('Plana git!'),
          ),
          RaisedButton(
            onPressed: () {
              if (ihText != null && isText != null && tasText != null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('ZATEN BİR BÜTÇE PLANI OLUŞTURULMUŞ.'),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewPlan()));
              }
            },
            child: Text('+'),
          ),
        ]),
      )),
    );
  }
}
