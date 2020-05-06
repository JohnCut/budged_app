import 'dart:core';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'newplan.dart';

class Plan extends StatefulWidget {
  final String ihText, isText, tasText;
  Plan({
    this.ihText,
    this.isText,
    this.tasText,
  });
  _PlanState createState() => _PlanState(ihText, isText, tasText);
}

class _PlanState extends State<Plan> {
  final String ihText, isText, tasText; // planlanan oranlar
  _PlanState(this.ihText, this.isText, this.tasText);

  final gelirTC = TextEditingController();
  final giderTC = TextEditingController();
  String ihKB = ''; // ih kalan bütçe
  String isKB = ''; // is kalan bütçe
  String anTas = ''; // anlık tasarruf
  String ihAOran = ''; // ih anlık oran
  String isAOran = ''; // is anlık oran
  String tasAOran = ''; // tasarruf anlık oran
  String gidDBValue = 'İH'; // gider kategorisi dropdown list seçili value su
  String gelirSum = ''; // gelir toplamı (gelir list elemanları toplamı)
  String giderSum = ''; // gider toplamı (gider list elemanları toplamı)
  String ihSum = ''; // ih gider toplamı (ih gider list elemanları toplamı)
  String isSum = ''; // is gider toplamı (is gider list elemanları toplamı)
  // 4 TANE LIST OLUŞTURULACAK. (GELİR, GİDER, İH GİDER, İS GİDER)
  // GİDERLER HEM KENDİ KATEGORİSİNİN LIST İNE HEM DE GİDER LIST İNE KAYDEDİLECEK.

  @override
  void initState() {
    print('İH: $ihText, İS: $isText, TAS: $tasText');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Bütçe Planı'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage(ihText : ihText, isText : isText, tasText : tasText)));
              }),
          IconButton(
              icon: Icon(Icons.view_list),
              onPressed: () {
                /* Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Reports())); */
              }),
        ],
      ),
      body: Center(
        child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(border: Border.all()),
            child: Column(children: [
              Container(
                  child: Column(
                children: <Widget>[
                  Text('Kalan Bütçe'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('İH '),
                      Text(ihKB), // ih kalan bütçe
                      Text('/'),
                      Text('İS'),
                      Text(isKB), // is kalan bütçe
                    ],
                  )
                ],
              )),
              Container(
                child: Column(
                  children: <Widget>[
                    Text('Anlık Tasarruf'),
                    Text(anTas), // anlık tasarruf
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text('Hedeflenen Oranlar'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(ihText), // planlanan ih oranı
                              Text('/'),
                              Text(isText), // planlanan is oranı
                              Text('/'),
                              Text(tasText), // planlanan tasarruf oranı
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text('Anlık Oranlar'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(ihAOran), // ih anlık oran
                              Text('/'),
                              Text(isAOran), // is anlık oran
                              Text('/'),
                              Text(tasAOran), // tasarruf anlık oran
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Container(
            // margin: const EdgeInsets.all(15.0),
            // decoration: BoxDecoration(border: Border.all()),
              child: Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text('Gelir giriniz.'),
                      Flexible(
                          child: TextField(
                        controller: gelirTC,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      )),
                      RaisedButton(onPressed: () {
                        // value yu listeye kaydetme işlemi
                      },
                      child: Text('Geliri kaydet'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text('Gider giriniz.'),
                      DropdownButton<String>(
                        value: gidDBValue,
                        onChanged: (String newValue) {
                          setState(() {
                            gidDBValue = newValue;
                          });
                          print(gidDBValue);
                        },
                        items: <String>['İH', 'İS']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      Flexible(
                          child: TextField(
                        controller: giderTC,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      )),
                      RaisedButton(onPressed: () {
                        // value yu hem giderin kendi kategorisinin list ine hem e gider list ine kaydet
                      },
                      child: Text('Gideri kaydet'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(border: Border.all()),
              child: Row(
            children: <Widget>[
              Text('Gelir Toplamı: $gelirSum'), // gelir list elemanları toplamı
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('İH toplamı: $ihSum'), // ih gider list elemanları toplamı
                    Text('İS Toplamı: $isSum'), // is gider list elemanları toplamı
                    Text('Gider Toplamı: $giderSum'), // gider list elemanları toplamı
                  ],
                ),
              )
            ],
          ))
        ]),
      ),
    ));
  }
}
