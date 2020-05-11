import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String gelirToplam = '0';
  String aylikTas = '0';
  String ihToplam = '0';
  String isToplam = '0';
  String giderToplam = '0';
  String ihHOran = '0';
  String isHOran = '0';
  String tasHOran = '0';
  String ihAOran = '0';
  String isAOran = '0';
  String tasAOran = '0';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Aylık Raporlar'),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(border: Border.all()),
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[
                        Text('OCAK'),
                      ]),
                      Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(border: Border.all()),
                          child: Column(children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(children: <Widget>[
                                  Text('Gelir Toplamı'),
                                  Text(gelirToplam),
                                ]),
                                Column(children: <Widget>[
                                  Text('Aylık Tasarruf'),
                                  Text(aylikTas),
                                ]),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text('Gider Toplamı (IH + IS)'),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(ihToplam),
                                    Text('+'),
                                    Text(isToplam),
                                    Text('='),
                                    Text(giderToplam),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(children: <Widget>[
                                  Text('Hedeflenen Oranlar'),
                                  Row(children: <Widget>[
                                    Text(ihHOran),
                                    Text('/'),
                                    Text(isHOran),
                                    Text('/'),
                                    Text(tasHOran),
                                  ])
                                ]),
                                Column(children: <Widget>[
                                  Text('Aylık Oranlar'),
                                  Row(children: <Widget>[
                                    Text(ihAOran),
                                    Text('/'),
                                    Text(isAOran),
                                    Text('/'),
                                    Text(tasAOran),
                                  ])
                                ]),
                              ],
                            )
                          ]))
                    ]),
                  )
                ],
              ),
            )));
  }
}
