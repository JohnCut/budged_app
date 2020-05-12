import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'bpDB.dart';
import 'dbhelper.dart';
import 'homepage.dart';
import 'reports.dart';

class Gelir {
  String title, unit;
  Gelir(this.title, this.unit);
  @override
  String toString() {
    return '{ ${this.title}, ${this.unit} }';
  }
}

class Gider {
  String title, type, unit;
  Gider(this.title, this.type, this.unit);
  @override
  String toString() {
    return '{ ${this.title}, ${this.type}, ${this.unit} }';
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
  Future<List<BudgetPlan>> budgetPlans;
  int curUserId;
  var dbHelper;
  int index;
  var i;

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
  // 4 TANE LIST OLUŞTURULACAK. (GELİR, GİDER, İH GİDER, İS GİDER)
  // GİDERLER HEM KENDİ KATEGORİSİNİN LIST İNE HEM DE GİDER LIST İNE KAYDEDİLECEK.

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    /* getPlans(); */
    print('CLICKEDINDEX= $clickedIndex');
    print('CLICKEDID= $clickedID');
    /* print(budgetPlans); */
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                }),
            IconButton(
                icon: Icon(Icons.view_list),
                onPressed: () {
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
                          content: Text('Bütçe Planını Silmek İstiyor Musunuz ?'),
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
                                  dbHelper.delete(clickedID);
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
                            Text(ihKB), // ih kalan bütçe
                            Text('₺'),
                            Text('/'),
                            Text('İS'),
                            Text(isKB), // is kalan bütçe
                            Text('₺'),
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
                          Text(anTas), // anlık tasarruf
                          Text('₺'),
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
                              future: dbHelper.getBudgetPlan(),
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
                                      Text(snapshot.data[clickedIndex]
                                          .ihOran), // planlanan ih oranı
                                      Text('/'),
                                      Text(snapshot.data[clickedIndex]
                                          .isOran), // planlanan is oranı
                                      Text('/'),
                                      Text(snapshot.data[clickedIndex]
                                          .tasOran), // planlanan tasarruf oranı
                                    ],
                                  );
                                }
                                if (null == snapshot.data ||
                                    snapshot.data.length == 0) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                          'PLAN KAYDOLMAMIŞ'), // planlanan ih oranı// planlanan tasarruf oranı
                                    ],
                                  );
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
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    color: Colors.white,
                    elevation: 4,
                    child: Text('Girdi ekle'),
                    onPressed: () {
                      setState(() {
                        if (inputCont == false) {
                          inputCont = true;
                        } else {
                          inputCont = false;
                        }
                      });
                    })
              ],
            )),
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
                                      onPressed: () {
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
                                          gelirAdd(gelirTTC.text,
                                              gelirTC.text); // ekleme işlemi
                                          print(
                                              'GELİRLER LİST LENGTH: ${gelirler.length}');
                                          print('GELİRLER LİST: $gelirler');
                                          sumGelirList();
                                          sumIHGiderList();
                                          sumISGiderList();
                                          sumKalanIHList();
                                          sumKalanISList();
                                          sumAnlikTAS();
                                          calcIHOran();
                                          calcISOran();
                                          calcTASOran();
                                          setState(() {
                                            inputCont = false;
                                          });
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
                                      onPressed: () {
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
                                          giderAdd(giderTTC.text, gidDBValue,
                                              giderTC.text); // ekleme işlemi
                                          print(
                                              'GİDERLER LİST LENGTH: ${giderler.length}');
                                          print(
                                              'GİDERLER LİST: ${giderler[0].title}');
                                          sumIHGiderList();
                                          sumISGiderList();
                                          sumGiderlerList();
                                          sumKalanIHList();
                                          sumKalanISList();
                                          sumAnlikTAS();
                                          calcIHOran();
                                          calcISOran();
                                          calcTASOran();
                                          setState(() {
                                            inputCont = false;
                                          });
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
                        gelirler.isEmpty
                            ? Center(
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Henüz gelir yok.",
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: gelirler.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Container(
                                          color: Color.fromRGBO(
                                              173, 216, 230, 0.4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  gelirler[index].title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20.0,
                                                ),
                                                Text(
                                                  gelirler[index].unit,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '₺',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                        giderler.isEmpty
                            ? Center(
                                child: Container(
                                  height: 30,
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Henüz gider yok.",
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: giderler.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Container(
                                          color: Color.fromRGBO(
                                              255, 223, 191, 0.4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  giderler[index].title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                Text(
                                                  giderler[index].unit,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '₺',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                Text(
                                                  giderler[index].type,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                      ])),
            ),
            Container(
                color: Colors.white,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Text(
                        'Gelir Toplamı: $gelirSum'), // gelir list elemanları toplamı
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                              'İH toplamı: $ihSum'), // ih gider list elemanları toplamı
                          Text(
                              'İS Toplamı: $isSum'), // is gider list elemanları toplamı
                          Text(
                              'Gider Toplamı: $giderSum'), // gider list elemanları toplamı
                        ],
                      ),
                    )
                  ],
                ))
          ]),
        ),
      )),
    );
  }

  gelirAdd(String title, unit) {
    setState(() {
      gelirler.add((Gelir(title, unit)));
    });
    gelirTTC.clear();
    gelirTC.clear();
  } // değerleri gelirler list ine ekler.

  giderAdd(String title, type, unit) {
    setState(() {
      giderler.add((Gider(title, type, unit)));
    });
    giderTTC.clear();
    giderTC.clear();
  } // değerleri giderler list ine ekler.

  sumGelirList() {
    gelirlerSum = 0;
    for (var i = 0; i < gelirler.length; i++) {
      setState(() {
        gelirlerSum += int.parse(gelirler[i].unit);
      });
    }
    print('Gelirlerin Toplamı: $gelirlerSum');
    setState(() {
      gelirSum = gelirlerSum.toString();
    });
  }

  sumIHGiderList() {
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
  }

  sumISGiderList() {
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
      double x = int.parse(gelirSum) / 100;
      ihaoranDB = int.parse(ihSum) / x.round();
      ihAOran = (ihaoranDB).round().toString();
    });
  }

  calcISOran() {
    setState(() {
      double x = int.parse(gelirSum) / 100;
      isaoranDB = int.parse(isSum) / x.round();
      isAOran = (isaoranDB).round().toString();
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
      budgetPlans = dbHelper.getBudgetPlan();
    });
  }

  /* setPerc() {
    setState(() {
      ihText = budgetPlans[clickedIndex].ihOran;
    });
  } */
}
