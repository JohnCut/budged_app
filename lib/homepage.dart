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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MaterialApp(
          home: Scaffold(
        appBar: AppBar(
          title: Text('Anasayfa'),
        ),
        body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FutureBuilder(
            future: dbHelper.getBudgetPlan(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  clickedIndex = index;
                                  clickedID = snapshot.data[index].id;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Plan(
                                            clickedIndex: clickedIndex,
                                            clickedID: clickedID)));
                              },
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(snapshot.data[index].ihOran),
                                    Text('/'),
                                    Text(snapshot.data[index].isOran),
                                    Text('/'),
                                    Text(snapshot.data[index].tasOran),
                                    Text(snapshot.data[index].time),
                                  ])),
                        );
                      }),
                );
              }
              if (null == snapshot.data || snapshot.data.length == 0) {
                return Container();
              }
              return CircularProgressIndicator();
            },
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => NewPlan()));
            },
            child: Text('+'),
          ),
        ]),
      )),
    );
  }
}
