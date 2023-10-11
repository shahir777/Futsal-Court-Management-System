import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:futsal/service/Other_Service.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MyBooking extends StatefulWidget {
  MyBooking({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyBookingState createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {

  List service = ['Turf','Tournament'];
  // List add = ['Kasaragod', 'Kannur'];
  List Date = ['29/03/2021 04:00:00','07/07/2021 02:30:00'];
  List image = ["assets/img/sac.png","assets/img/selectrical.jpeg"];
  bool isLoggedIn = false;
  var id = '';
  var user = {};
  List tournament = [];
  List rental = [];
  List data = [];
  var phone = '';
  @override



  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
    getData();
  }


  getId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = (json.decode(prefs.getString('user')));
    phone = user['phone'];
    print('phone');
    print(phone);
  }

  checkDate(){
    var t1 = '';
    var t2 = '';
    var t3 = '';
    var t4 = '';
    var t5 = '';
    var t6 = '';
    var t7;
    var t8;
    var now = DateTime.now();
    CollectionReference collectionsReference;
    collectionsReference = FirebaseFirestore.instance.collection('mybooking');
    for(var i in data){
      t1 = (now.toString().split(' ')[0]);
      t2 = (i['dt'].split(' ')[0]);
      t3 = (now.toString().split(' ')[1].split(':')[0]);
      t4 = DateFormat('yyyy-MM-dd hh:mm a').format(now);
      t8 = (now);
      t5 = (i['slot'][0]['time'].split(' - ')[0].split('.').join(':'));
      t6 = (t5.split(':')[0]+ ':00 '+t5.split('0').last.toUpperCase());
      t7 = (DateFormat('yyyy-MM-dd hh:mm a').parse((i['dt'].split(' ')[0] + ' ' + t6)));
      print(t7);
      print(t8);
      print(t7.isBefore(t8));
      if(i['current_status'] == 'Upcoming'){
        if(t7.isBefore(t8)){
          collectionsReference.doc(i['register_on'].toString()).update(
          {
            "current_status":'Completed',
          });
        }
      }
    }

  }


  getData() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection('mybooking').where('phone_number',isEqualTo: phone).where('current_status', isNotEqualTo: 'Requested').where('type', isEqualTo: 'Turf').orderBy('current_status',descending: true).orderBy('register_on').snapshots().listen((event) {
      print('event');
      print(event.docs);
      setState(() {
        data = event.docs.map((a)=>a.data()).toList();
      });
      checkDate();
    });
    await getTournament();
  }


  getTournament() async{
    FirebaseFirestore.instance.collection('mybooking').where('phone_number',isEqualTo: phone).where('type', isEqualTo: 'Tournament').where('current_status', isEqualTo: 'Requested').orderBy('register_on', descending: true).snapshots().listen((event) {
      print('event');
      print(event.docs);
      setState(() {
        tournament = event.docs.map((a)=>a.data()).toList();
      });
      // checkDate();
    });
    await getRental();
  }


  getRental() async{
    FirebaseFirestore.instance.collection('mybooking').where('phone_number',isEqualTo: phone).where('type', isEqualTo: 'Rental').where('current_status', isEqualTo: 'Requested').orderBy('register_on', descending: true).snapshots().listen((event) {
      print('event');
      print(event.docs);
      setState(() {
        rental = event.docs.map((a)=>a.data()).toList();
      });
      // checkDate();
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:


      DefaultTabController(
        length: 3,
        child: MaterialApp(
          home: Scaffold(
            appBar: TabBar(
              labelColor: Colors.black87,
              onTap: (index) {
                print(index);
              },
              tabs: [
                Tab(text: 'Turf'),
                Tab(text: 'Tournament'),
                Tab(text: 'Others'),
              ],
            ),
            body: TabBarView(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:
                    data.length == 0?Center(
                      child: Text('No Booking Found'),
                    ):
                    ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, position) {
                        return Card(
                          elevation: 0.5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: (){
                              Dialog('service', data[position], context);
                            },
                            child: Row(
                              children: <Widget>[
                                _buildThumbnail(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                data[position]['date'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 18.0),
                                                softWrap: true,
                                              ),
                                            ),
                                            _buildTag(context, data[position], data[position]['current_status'])
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Start: " + data[position]['slot'][0]['time'].split(' - ')[0] ,
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Total Hours: " + data[position]['slot'].length.toString()),
                                            // _buildTag(context, data[position], 'seats')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:
                    tournament.length == 0?Center(
                      child: Text('No Booking Found'),
                    ):
                    ListView.builder(
                      itemCount: tournament.length,
                      itemBuilder: (context, position) {
                        return Card(
                          elevation: 0.5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: (){
                              cancelDialog('tournament', tournament[position], context);
                            },
                            child: Row(
                              children: <Widget>[
                                _buildThumbnail(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                tournament[position]['tournament_name'].toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 18.0),
                                                softWrap: true,
                                              ),
                                            ),
                                            // _buildTag(context, tournament[position], tournament[position]['current_status'])
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Team name: " + tournament[position]['team_name'].toString() ,
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("First price: " + tournament[position]['first_price'].toString()),
                                            // _buildTag(context, data[position], 'seats')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:
                    rental.length == 0?Center(
                      child: Text('No Booking Found'),
                    ):
                    ListView.builder(
                      itemCount: rental.length,
                      itemBuilder: (context, position) {
                        return Card(
                          elevation: 0.5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4.0),
                            onTap: (){
                              cancelDialog('rental', rental[position], context);
                            },
                            child: Row(
                              children: <Widget>[
                                _buildThumbnail(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                rental[position]['category'].toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 18.0),
                                                softWrap: true,
                                              ),
                                            ),
                                            // _buildTag(context, rental[position], rental[position]['current_status'])
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Time: " + rental[position]['time'].toString() ,
                                              ),
                                            ],
                                          ),
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text("Total ${rental[position]['category']}: " + (rental[position]['no_of_l_${rental[position]['category']}'] + rental[position]['no_of_m_${rental[position]['category']}'] + rental[position]['no_of_s_${rental[position]['category']}']).toString()),
                                            // _buildTag(context, data[position], 'seats')
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }


  Container _buildThumbnail() {
    return Container(
      height: 120,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0),
          bottomLeft: Radius.circular(4.0),
        ),
        image: DecorationImage(
          image: NetworkImage('https://images.financialexpress.com/2020/11/football.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Container _buildTag(BuildContext context, item, type) {
    var len = 0;//(item['number_of_teams']) - (item['registered'].length);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: type == 'Upcoming'?Colors.blue:type == 'Cancelled'?Colors.red: type == 'Completed'?Colors.green:Colors.deepPurple),
      child: Column(
        children: [
          Text(
            item['current_status'].toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  void cancelDialog(service, list, context){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                            child: Text('Cancel Booking'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              print(list['register_on']);
                              CollectionReference collectionsReference;
                              collectionsReference =
                                  FirebaseFirestore.instance.collection(
                                      'mybooking');
                              if (await confirm(
                                context,
                                title: Text('Cancel Booking'),
                                content: Text('Are you sure? You want to cancel this booking.'),
                                textOK: Text('Yes'),
                                textCancel: Text('No'),
                              )) {
                                return {
                                  collectionsReference.doc(list['register_on'].toString()).update(
                                      {
                                        "current_status":'Cancelled',
                                      }),
                                  moreService().toaster("Successfully Cancelled", Colors.green),
                                  Navigator.pop(context)
                                };
                              }

                              return {
                                print('pressedCancel'),
                              };
                            }
                        )
                      ],
                    ),
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Booking'),
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
                          // for(var i in list)
                          if(service == 'tournament')
                          ListTile(
                            title: Text('Tournament Name: ' + list['tournament_name'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          if(service == 'tournament')
                            ListTile(
                              title: Text('Tournament ID: ' + list['tournament_id'].toString(),
                                style: TextStyle(color: Colors.black87),),
                            ),
                          if(service == 'tournament')
                            ListTile(
                            title: Text('Team Name: ' +
                                list['team_name'].toString(), style: TextStyle(
                                color: Colors.black87),),
                          ),

                          if(service == 'rental')
                            ListTile(
                              title: Text('Type: ' + list['category'].toString(),
                                style: TextStyle(color: Colors.black87),),
                            ),
                          if(service == 'rental')
                            ListTile(
                              title: Text('Time: ' + list['time'].toString(),
                                style: TextStyle(color: Colors.black87),),
                            ),
                          if(service == 'rental')
                            ListTile(
                              title: Text("${list['category']} (S): " + ((list['no_of_s_${list['category']}']).toString()),
                                      // list['no_of_m_${list['type']}'] + list['no_of_s_${list['type']}']).toString(),
                                style: TextStyle(
                                  color: Colors.black87),),
                            ),
                          if(service == 'rental')
                            ListTile(
                              title: Text("${list['category']} (M): " + ((list['no_of_m_${list['category']}']).toString()),
                                // list['no_of_m_${list['type']}'] + list['no_of_s_${list['type']}']).toString(),
                                style: TextStyle(
                                    color: Colors.black87),),
                            ),
                          if(service == 'rental')
                            ListTile(
                              title: Text("${list['category']} (L): " + ((list['no_of_l_${list['category']}']).toString()),
                                // list['no_of_m_${list['type']}'] + list['no_of_s_${list['type']}']).toString(),
                                style: TextStyle(
                                    color: Colors.black87),),
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

  void Dialog(service, list, context){


    var timeSlot = [];
    var currentTime = [];
    getTimeSlot() async{
      DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(list['date'].split('/').join('')).get();
      if(ds.exists){
        var dt = jsonDecode(jsonEncode(ds.data()));
        setState(() {
          timeSlot = dt['date'];
          currentTime = list['slot'].map((a)=>a['time']).toList();
          print(timeSlot);
        });

      }
    }




    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (list['current_status'] == 'Upcoming') ? RaisedButton(
                            child: Text('Cancel Booking'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              getTimeSlot();
                              print(list['slot'].map((a)=>a['time']).toList());
                              // Navigator.pop(context);

                              var t5 = '';
                              var t6 = '';
                              var t7;
                              var t8;
                              CollectionReference collectionsReference;
                              CollectionReference collectionsReference1;
                              collectionsReference =
                                  FirebaseFirestore.instance.collection(
                                      'mybooking');
                              collectionsReference1 =
                                  FirebaseFirestore.instance.collection(
                                      'date');
                              var now = DateTime.now();
                              if (await confirm(
                                context,
                                title: Text('Cancel Booking'),
                                content: Text('Are you sure? You want to cancel this booking.'),
                                textOK: Text('Yes'),
                                textCancel: Text('No'),
                              )) {
                              return {
                                // Navigator.pop(context),
                                t8 = (now.add(Duration(hours: 3))),
                                t5 = (list['slot'][0]['time'].split(' - ')[0].split('.').join(':')),
                                t6 = (t5.split(':')[0]+ ':00 '+t5.split('0').last.toUpperCase()),
                                t7 = (DateFormat('yyyy-MM-dd hh:mm a').parse((list['dt'].split(' ')[0] + ' ' + t6))),
                                if(t7.isAfter(t8)){
                                  for(var i in currentTime){
                                    if(timeSlot.contains(i))
                                      timeSlot.remove(i)
                                  },
                                  collectionsReference1.doc(list['date'].split('/').join('')).update(
                                      {
                                        "date":timeSlot,
                                      }),
                                  collectionsReference.doc(list['register_on'].toString()).update(
                                  {
                                    "current_status":'Cancelled',
                                  }),

                                  moreService().toaster("Successfully Cancelled", Colors.green),
                                  // Navigator.pop(context),
                                  Navigator.pop(context)
                              }else{
                                  moreService().toaster("You Can't Cancel now", Colors.red),
                                }
                              };
                              }

                              return {
                                print('pressedCancel'),

                              };
                            }
                        ) : Container()
                      ],
                    ),
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Booking'),
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
                          // for(var i in list)
                          ListTile(
                            title: Text('Date: ' + list['date'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          for(var i in list['slot'])
                            ListTile(
                              title: Text('Time: ' + i['time'],
                                style: TextStyle(color: Colors.black87),),
                            ),
                          ListTile(
                            title: Text('Current Status: ' +
                                list['current_status'], style: TextStyle(
                                color: Colors.black87),),
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