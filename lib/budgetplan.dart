import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'bpDB.dart';
import 'dbhelper.dart';
import 'homepage.dart';
import 'reports.dart';

class Gelir {
  String title, unit, time;
  Gelir(this.title, this.unit, this.time);
  @override
  String toString() {
    return '{ ${this.title}, ${this.unit}, ${this.time} }';
  }
}

class Gider {
  String title, type, unit, time;
  Gider(this.title, this.type, this.unit, this.time);
  @override
  String toString() {
    return '{ ${this.title}, ${this.type}, ${this.unit}, ${this.time} }';
  }
}

class Plan extends StatefulWidget {
  final int clickedID, clickedIndex;
  Plan({
    this.clickedID,
    this.clickedIndex,
  });
  _PlanState createState() => _PlanState(clickedID, clickedIndex);
}

class _PlanState extends State<Plan> {
  Future<List<BudgetPlan>> plansFTR;
  Future<List<BudgetPlan>> gelirlerFTR;
  int curUserId;
  var dbHelper;
  int index;
  var i;

  static var now = DateTime.now();
  static var formatNow = DateFormat("dd-MM-yyyy hh:mm:ss").format(now);
  String nowString = "${formatNow.toString()}";

  String ihText, isText, tasText; // planlanan oranlar
  final int clickedID, clickedIndex;
  _PlanState(this.clickedID, this.clickedIndex);

  final gelirTC = TextEditingController();
  final giderTC = TextEditingController();
  final gelirTTC = TextEditingController();
  final giderTTC = TextEditingController();
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
  int ihkbINT = 0;
  int iskbINT = 0;
  int antasINT = 0;
  double ihaoranDB = 0;
  double isaoranDB = 0;
  int tasaoranINT = 0;
  int gelirlerSum = 0;
  int giderlerSum = 0;
  int ihGiderSum = 0;
  int isGiderSum = 0;
  List gelirler = [];
  List giderler = [];
  bool inputCont = false;
  bool delayBool = false;
  // 4 TANE LIST OLUŞTURULACAK. (GELİR, GİDER, İH GİDER, İS GİDER)
  // GİDERLER HEM KENDİ KATEGORİSİNİN LIST İNE HEM DE GİDER LIST İNE KAYDEDİLECEK.

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    print('CLICKEDINDEX= $clickedIndex');
    print('CLICKEDID= $clickedID');

    delayed(2).then((result) {
      if (gelirler.length == 0 && giderler.length == 0) {
        ihKB = '0';
        isKB = '0';
        anTas = '0';
        ihAOran = '-';
        isAOran = '-';
        tasAOran = '-';
        gelirSum = '0';
        ihSum = '0';
        isSum = '0';
        giderSum = '0';
      } else {
        sumGelirList();
        sumIHGiderList();
        sumISGiderList();
        sumGiderlerList();
        sumKalanIHList();
        sumKalanISList();
        sumAnlikTAS();
        calcIHOran();
        calcISOran();
        calcTASOran();
      }
    });
  }

  @override
  void dispose() async {
    await dbHelper.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
          home: Scaffold(
        backgroundColor: Color.fromRGBO(235, 239, 242, 1.0),
        appBar: AppBar(
          title: Text('Bütçe Planı'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  gelirler.removeRange(0, gelirler.length);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                }),
            IconButton(
                icon: Icon(Icons.view_list),
                onPressed: () {
                  gelirler.removeRange(0, gelirler.length);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Reports()));
                }),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content:
                              Text('Bütçe planını silmek istiyor musunuz ?'),
                          contentPadding: const EdgeInsets.all(16.0),
                          actions: <Widget>[
                            FlatButton(
                                child: Text('İPTAL'),
                                textColor: Color(0xFFB6B6B6),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            FlatButton(
                                child: Text('EVET'),
                                textColor: Color(0xFFB6B6B6),
                                onPressed: () {
                                  dbHelper.deletePlan(clickedID);
                                  gelirler.removeRange(0, gelirler.length);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Homepage()));
                                }),
                          ],
                        );
                      });
                }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            elevation: 3.0,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.greenAccent,
            onPressed: () {
              giderTTC.clear();
              giderTC.clear();
              setState(() {
                if (inputCont == false) {
                  inputCont = true;
                } else {
                  inputCont = false;
                }
              });
            }),
        body: Center(
          child: Column(children: [
            Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
              padding: const EdgeInsets.all(10.0),
              child: Column(children: [
                Container(
                    color: Color.fromRGBO(235, 239, 242, 1.0),
                    margin:
                        EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
                    padding: EdgeInsets.all(7.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Kalan Bütçe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text('İH '),
                            Row(children: <Widget>[
                              Text(ihKB), // ih kalan bütçe
                              Text('₺'),
                            ]),
                            Text('/'),
                            Text('İS'),
                            Row(
                              children: <Widget>[
                                Text(isKB), // is kalan bütçe
                                Text('₺'),
                              ],
                            ),
                          ],
                        )
                      ],
                    )),
                Container(
                  color: Color.fromRGBO(235, 239, 242, 1.0),
                  margin: EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
                  padding: EdgeInsets.all(7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'Anlık Tasarruf',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(anTas), // anlık tasarruf
                                Text('₺'),
                              ]),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Color.fromRGBO(235, 239, 242, 1.0),
                  margin: EdgeInsets.symmetric(vertical: 7.0, horizontal: 0.0),
                  padding: EdgeInsets.all(7.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Hedeflenen Oranlar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FutureBuilder(
                              future: dbHelper.getPlans(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) => setState(() {
                                            ihText = snapshot
                                                .data[clickedIndex].ihOran;
                                            isText = snapshot
                                                .data[clickedIndex].isOran;
                                            tasText = snapshot
                                                .data[clickedIndex].tasOran;
                                          }));
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Row(children: <Widget>[
                                        Text('%'),
                                        Text(snapshot.data[clickedIndex]
                                            .ihOran), // planlanan ih oranı
                                      ]),
                                      Text('/'),
                                      Row(children: <Widget>[
                                        Text('%'),
                                        Text(snapshot.data[clickedIndex]
                                            .isOran), // planlanan is oranı
                                      ]),
                                      Text('/'),
                                      Row(children: <Widget>[
                                        Text('%'),
                                        Text(snapshot.data[clickedIndex]
                                            .tasOran), // planlanan tasarruf oranı
                                      ]),
                                    ],
                                  );
                                }
                                if (null == snapshot.data ||
                                    snapshot.data.length == 0) {
                                  return CircularProgressIndicator();
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Anlık Oranlar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  Text('%'),
                                  Text(ihAOran), // ih anlık oran
                                ]),
                                Text('/'),
                                Row(children: <Widget>[
                                  Text('%'),
                                  Text(isAOran), // is anlık oran
                                ]),
                                Text('/'),
                                Row(children: <Widget>[
                                  Text('%'),
                                  Text(tasAOran), // tasarruf anlık oran
                                ]),
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
            IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  if (inputCont != false)
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                color: Color.fromRGBO(235, 239, 242, 1.0),
                                margin: EdgeInsets.all(5.0),
                                padding: EdgeInsets.all(5.0),
                                child: Column(
                                  children: <Widget>[
                                    Text('Gelir giriniz.'),
                                    Flexible(
                                        child: TextField(
                                      controller: gelirTTC,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Gelir İsmi'),
                                    )),
                                    Flexible(
                                        child: TextField(
                                      controller: gelirTC,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Gelir Değeri'),
                                      keyboardType: TextInputType.number,
                                    )),
                                    RaisedButton(
                                      color: Colors.white,
                                      elevation: 4,
                                      onPressed: () async {
                                        if (gelirTTC.text == '' ||
                                            gelirTC.text == '') {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Text(
                                                      'LÜTFEN GEREKLİ ALANLARI DOLDURUN.'),
                                                  contentPadding:
                                                      const EdgeInsets.all(
                                                          16.0),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                        child: Text('TAMAM'),
                                                        textColor:
                                                            Color(0xFFB6B6B6),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                  ],
                                                );
                                              });
                                        } else if (gelirTTC.text != '' &&
                                            gelirTC.text != '') {
                                          await addGelir();
                                          await delayed(4);
                                          sumGelirList();
                                          sumIHGiderList();
                                          sumISGiderList();
                                          sumKalanIHList();
                                          sumKalanISList();
                                          sumAnlikTAS();
                                          calcIHOran();
                                          calcISOran();
                                          calcTASOran();
                                        }
                                      },
                                      child: Text('Geliri kaydet'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Color.fromRGBO(235, 239, 242, 1.0),
                                margin: EdgeInsets.all(5.0),
                                padding: EdgeInsets.all(5.0),
                                child: Column(
                                  children: <Widget>[
                                    Text('Gider giriniz.'),
                                    Flexible(
                                        child: TextField(
                                      controller: giderTTC,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Gider İsmi'),
                                    )),
                                    Flexible(
                                        child: TextField(
                                      controller: giderTC,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Gider Değeri'),
                                      keyboardType: TextInputType.number,
                                    )),
                                    DropdownButton<String>(
                                      value: gidDBValue,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          gidDBValue = newValue;
                                        });
                                        print(gidDBValue);
                                      },
                                      items: <String>['İH', 'İS']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    RaisedButton(
                                      color: Colors.white,
                                      elevation: 4,
                                      onPressed: () async {
                                        if (giderTTC.text == '' ||
                                            giderTC.text == '') {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Text(
                                                      'LÜTFEN GEREKLİ ALANLARI DOLDURUN.'),
                                                  contentPadding:
                                                      const EdgeInsets.all(
                                                          16.0),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                        child: Text('TAMAM'),
                                                        textColor:
                                                            Color(0xFFB6B6B6),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                                  ],
                                                );
                                              });
                                        } else if (giderTTC.text != '' &&
                                            giderTC.text != '') {
                                          await addGider();
                                          await delayed(4);
                                          sumIHGiderList();
                                          sumISGiderList();
                                          sumGiderlerList();
                                          sumKalanIHList();
                                          sumKalanISList();
                                          sumAnlikTAS();
                                          calcIHOran();
                                          calcISOran();
                                          calcTASOran();
                                        }
                                      },
                                      child: Text('Gideri kaydet'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        StreamBuilder(
                          stream: Stream.fromFuture(dbHelper.getGelirler()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        gelirler.removeRange(
                                            0, gelirler.length);
                                        for (var i = 0;
                                            i < snapshot.data.length;
                                            i++) {
                                          if (snapshot.data[i].bpID ==
                                              clickedID) {
                                            addListGelirler(
                                                snapshot.data[i].title,
                                                snapshot.data[i].unit,
                                                snapshot.data[i].time);
                                          } else {}
                                        }
                                      }));
                              return Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: gelirler.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Container(
                                          child: Column(
                                            children: <Widget>[
                                              AutoSizeText(
                                                gelirler[index].time,
                                                maxLines: 1,
                                              ),
                                              Container(
                                                color: Color.fromRGBO(
                                                    173, 216, 230, 0.4),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      AutoSizeText(
                                                        gelirler[index].title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      AutoSizeText(
                                                        '${gelirler[index].unit}₺',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            }
                            if (null == gelirler || gelirler.length == 0) {
                              return Center(
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Henüz gelir yok.",
                                  ),
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                        StreamBuilder(
                          stream: Stream.fromFuture(dbHelper.getGiderler()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        giderler.removeRange(
                                            0, giderler.length);
                                        for (var i = 0;
                                            i < snapshot.data.length;
                                            i++) {
                                          if (snapshot.data[i].bpID ==
                                              clickedID) {
                                            addListGiderler(
                                                snapshot.data[i].title,
                                                snapshot.data[i].type,
                                                snapshot.data[i].unit,
                                                snapshot.data[i].time);
                                          } else {}
                                        }
                                      }));
                              return Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: giderler.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Container(
                                          child: Column(
                                            children: <Widget>[
                                              AutoSizeText(
                                                giderler[index].time,
                                                maxLines: 1,
                                              ),
                                              Container(
                                                color: Color.fromRGBO(
                                                    255, 223, 191, 0.4),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      AutoSizeText(
                                                        giderler[index].title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(
                                                        width: 15.0,
                                                      ),
                                                      AutoSizeText(
                                                        '${giderler[index].unit}₺',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(
                                                        width: 15.0,
                                                      ),
                                                      Text(
                                                        giderler[index].type,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            }
                            if (null == giderler || giderler.length == 0) {
                              return Center(
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Henüz gider yok.",
                                  ),
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ])),
            ),
            Container(
                color: Colors.white,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('Gelir Toplamı: $gelirSum'),
                        Text('₺'),
                      ],
                    ), // gelir list elemanları toplamı
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                                'İH toplamı: $ihSum'), // ih gider list elemanları toplamı
                            Text('₺'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                                'İS Toplamı: $isSum'), // is gider list elemanları toplamı
                            Text('₺'),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                                'Gider Toplamı: $giderSum'), // gider list elemanları toplamı
                            Text('₺'),
                          ],
                        ),
                      ],
                    )
                  ],
                )),
          ]),
        ),
      )),
    );
  }

  addListGelirler(String title, unit, time) {
    setState(() {
      gelirler.add((Gelir(title, unit, time)));
    });
  } // değerleri gelirler list ine ekler.

  addListGiderler(String title, type, unit, time) {
    setState(() {
      giderler.add((Gider(title, type, unit, time)));
    });
  } // değerleri giderler list ine ekler.

  sumGelirList() {
    /* Timer(const Duration(milliseconds: 1500), () { */
    gelirlerSum = 0;
    print(gelirler.length);
    for (var i = 0; i < gelirler.length; i++) {
      setState(() {
        gelirlerSum += int.parse(gelirler[i].unit);
      });
    }
    print('GELİRSUM INT: $gelirlerSum');
    print('Gelirlerin Toplamı: $gelirlerSum');
    setState(() {
      gelirSum = gelirlerSum.toString();
      print('GELİRSUM STRING: $gelirSum');
    });
    /* }); */
  }

  sumIHGiderList() {
    /* Timer(const Duration(milliseconds: 1500), () { */
    ihGiderSum = 0;
    for (var i = 0; i < giderler.length; i++) {
      setState(() {
        if (giderler[i].type == 'İH') {
          ihGiderSum += int.parse(giderler[i].unit);
        }
      });
    }
    print('İH Giderlerinin Toplamı: $ihGiderSum');
    setState(() {
      ihSum = ihGiderSum.toString();
    });
    /* }); */
  }

  sumISGiderList() {
    /* Timer(const Duration(milliseconds: 1500), () { */
    isGiderSum = 0;
    for (var i = 0; i < giderler.length; i++) {
      setState(() {
        if (giderler[i].type == 'İS') {
          isGiderSum += int.parse(giderler[i].unit);
        }
      });
    }
    print('İS Giderlerinin Toplamı: $isGiderSum');
    setState(() {
      isSum = isGiderSum.toString();
    });
    /* }); */
  }

  sumGiderlerList() {
    setState(() {
      giderlerSum = ihGiderSum + isGiderSum;
    });
    print('Giderler Toplamı: $giderlerSum');
    setState(() {
      giderSum = giderlerSum.toString();
    });
  }

  sumKalanIHList() {
    setState(() {
      if (gelirlerSum == 0) {
        gelirSum = "0";
        double a = int.parse(gelirSum) * int.parse(ihText) / 100;
        ihkbINT = a.round() - ihGiderSum;
        ihKB = ihkbINT.toString();
      } else {
        double a = int.parse(gelirSum) * int.parse(ihText) / 100;
        ihkbINT = a.round() - ihGiderSum;
        ihKB = ihkbINT.toString();
      }
    });
  }

  sumKalanISList() {
    setState(() {
      if (gelirlerSum == 0) {
        gelirSum = "0";
        double a = int.parse(gelirSum) * int.parse(isText) / 100;
        iskbINT = a.round() - isGiderSum;
        isKB = iskbINT.toString();
      } else {
        double a = int.parse(gelirSum) * int.parse(isText) / 100;
        iskbINT = a.round() - isGiderSum;
        isKB = iskbINT.toString();
      }
    });
  }

  sumAnlikTAS() {
    setState(() {
      if (gelirSum == "" || giderSum == "") {
        if (gelirSum == "") {
          anTas = giderSum;
        } else if (giderSum == "") {
          anTas = gelirSum;
        }
      } else {
        antasINT = int.parse(gelirSum) - int.parse(giderSum);
        anTas = antasINT.toString();
      }
    });
  }

  calcIHOran() {
    setState(() {
      try {
        double x = int.parse(gelirSum) / 100;
        ihaoranDB = int.parse(ihSum) / x.round();
        var rounded = (ihaoranDB).round();
        ihAOran = rounded.toString();
      } catch (e) {
        ihAOran = '0';
      }
    });
  }

  calcISOran() {
    setState(() {
      try {
        double x = int.parse(gelirSum) / 100;
        isaoranDB = int.parse(isSum) / x.round();
        var rounded = (isaoranDB).round();
        isAOran = rounded.toString();
      } catch (e) {
        isAOran = '0';
      }
    });
  }

  calcTASOran() {
    setState(() {
      tasaoranINT = 100 - (int.parse(ihAOran) + int.parse(isAOran));
      tasAOran = (tasaoranINT).toString();
    });
  }

  getPlans() {
    setState(() {
      plansFTR = dbHelper.getPlans();
    });
  }

  addGelir() async {
    GelirDB e =
        await GelirDB(null, gelirTTC.text, gelirTC.text, nowString, clickedID);
    await dbHelper.insertGE(e);
    gelirTTC.clear();
    gelirTC.clear();
    setState(() {
      inputCont = false;
    });
  }

  getGelirler() {
    setState(() {
      gelirler = dbHelper.getGelirler();
    });
  }

  addGider() async {
    GiderDB e = await GiderDB(
        null, giderTTC.text, giderTC.text, gidDBValue, nowString, clickedID);
    await dbHelper.insertGI(e);
    giderTTC.clear();
    giderTC.clear();
    setState(() {
      inputCont = false;
    });
  }

  getGiderler() {
    setState(() {
      giderler = dbHelper.getGiderler();
    });
  }

  delayed(int sec) async {
    await Future.delayed(Duration(seconds: sec));
    setState(() {
      delayBool = true;
    });
  }
}
