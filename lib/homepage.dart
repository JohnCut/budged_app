import 'package:flutter/material.dart';

import 'bpDB.dart';
import 'budgetplan.dart';
import 'dbhelper.dart';
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
  Future<List<BudgetPlan>> budgetPlans;
  int curUserId;
  var dbHelper;
  final String ihText, isText, tasText;
  _HomepageState(this.ihText, this.isText, this.tasText);
  int clickedIndex;
  int clickedID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DBHelper();
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
        backgroundColor: Color.fromRGBO(182, 195, 204, 1.0),
        appBar: AppBar(
          title: Text('Anasayfa'),
        ),
        floatingActionButton: FloatingActionButton(
            elevation: 3.0,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NewPlan()));
            }),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Bütçeni Oluştur!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 25.0),
                      Text(
                          '50/30/20 kuralı, kişisel finansman alanında uygulanan en etkili metotlardan biridir.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold)),
                      Text(
                          'Fakat sen bu oranları dilediğince ayarlamakta serbestsin.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
              Container(
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 15.0),
                color: Color.fromRGBO(235, 239, 242, 1.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FutureBuilder(
                        future: dbHelper.getPlans(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Flexible(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: RaisedButton(
                                          elevation: 4,
                                          color: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 0.0),
                                          onPressed: () {
                                            setState(() {
                                              clickedIndex = index;
                                              clickedID =
                                                  snapshot.data[index].id;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Plan(
                                                        clickedIndex:
                                                            clickedIndex,
                                                        clickedID: clickedID)));
                                          },
                                          child: Column(children: <Widget>[
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Row(children: <Widget>[
                                                    Text('%'),
                                                    Text(snapshot
                                                        .data[index].ihOran),
                                                  ]),
                                                  Text('/'),
                                                  Row(children: <Widget>[
                                                    Text('%'),
                                                    Text(snapshot
                                                        .data[index].isOran),
                                                  ]),
                                                  Text('/'),
                                                  Row(children: <Widget>[
                                                    Text('%'),
                                                    Text(snapshot
                                                        .data[index].tasOran),
                                                  ]),
                                                ]),
                                            SizedBox(height: 10.0),
                                            Text(snapshot.data[index].time),
                                          ])),
                                    );
                                  }),
                            );
                          }
                          if (snapshot.data == null || snapshot.data.length == 0) {
                            return Container(
                              child: Text('HEMEN BİR BÜTÇE PLANI OLUŞTUR!'),
                            );
                          }
                          return Text('HEMEN BİR BÜTÇE PLANI OLUŞTUR!');
                        },
                      ),
                    ]),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
