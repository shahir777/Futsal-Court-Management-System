import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:futsaladmin/screen/rental.dart';
import 'package:futsaladmin/screen/tournament_list.dart';
import 'package:futsaladmin/screen/turf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'notification.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  var slot;

  final List categories = [
    {"id":"1","name":"Turf Bookings", "icon":Icons.event},
    {"id":"2","name":"Tournament Bookings", "icon":Icons.event_available},
    {"id":"3","name":"Rental Bookings", "icon":Icons.list},
    {"id":"4","name":"Live Scoring", "icon":Icons.score},
    {"id":"5","name":"Notification Centre", "icon":Icons.notifications},
    {"id":"6","name":"Logout", "icon":Icons.power_settings_new},
  ];



  getSlot(setState) async {
    FirebaseFirestore.instance.collection('settings').doc('score_card').snapshots().listen((event) {
      // print(dt);
      setState(() {
        slot = (event.data()['match']);
        // total = {"jersey_m": dt['jersey_m'], "jersey_l": dt['jersey_l'], "shoes_l": dt['shoes_l'], "shoes_m": dt['shoes_m'], "jersey_s": dt['jersey_s'], "shoes_s": dt['shoes_s']};
      });
      print(slot[0]['team']);
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSlot(setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          // height: 400,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0
                    ),
                    delegate: SliverChildBuilderDelegate(
                      _buildCategoryItem,
                      childCount: categories.length,

                    )

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryItem(BuildContext context, int index) {
    // var category = categories[index];
    return MaterialButton(
      elevation: 1.0,
      highlightElevation: 1.0,

      onPressed: () async {
        if(categories[index]['id'] == '1'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TurfPage()));
        }
        if(categories[index]['id'] == '2'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TournamentListPage()));
        }
        if(categories[index]['id'] == '3'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RentalPage()));
        }
        if(categories[index]['id'] == '4'){
          await DialogSetting(context);
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => RentalPage()));
        }
        if(categories[index]['id'] == '5'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()));
        }
        if(categories[index]['id'] == '6'){
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => LoginPage(title: '')),
                  (route) => false);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.green,
      textColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(categories[index]['icon'], size: 50,),
          SizedBox(height: 5.0),
          Text(
            categories[index]['name'],
            textAlign: TextAlign.center,
            maxLines: 3,),
        ],
      ),
    );
  }


  Future<void> DialogSetting(context) async {

    var slot1 = [];

    // print()
    await getSlot(setState);
    setState((){
      slot1 = json.decode(json.encode(slot));
    });


    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                // getSlot(setState);
                return AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                            child: Text('Apply'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              if(slot1[0]['team'] == '' || slot1[0]['score'] == '' || slot1[1]['team'] == '' || slot1[1]['score'] == ''){

                              }
                              else{
                                CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('settings');
                                collectionsReference1.doc('score_card').update({"match": slot1});
                                Navigator.pop(context);
                              }
                            }
                        )
                      ],
                    ),
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Scoring'),
                  content: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery
                            .of(context)
                            .size
                            .height * .5),
                    // color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextField(
                                  onChanged: (val){
                                    slot1[0]['team'] = val;
                                  },
                                  controller: TextEditingController(text: slot1[0]['team'].toString()),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      labelText: "Team 1",
                                      labelStyle: TextStyle(color: Colors.black45)
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  onChanged: (val){
                                    slot1[0]['score'] = val;
                                  },
                                  controller: TextEditingController(text: slot1[0]['score'].toString()),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      labelText: "Score",
                                      labelStyle: TextStyle(color: Colors.black45)
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextField(
                                  onChanged: (val){
                                    slot1[1]['team'] = val;
                                  },
                                  controller: TextEditingController(text: slot1[1]['team'].toString()),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      labelText: "Team 2",
                                      labelStyle: TextStyle(color: Colors.black45)
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  onChanged: (val){
                                    slot1[1]['score'] = val;
                                  },
                                  controller: TextEditingController(text: slot1[1]['score'].toString()),
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                                      ),
                                      labelText: "Score",
                                      labelStyle: TextStyle(color: Colors.black45)
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
