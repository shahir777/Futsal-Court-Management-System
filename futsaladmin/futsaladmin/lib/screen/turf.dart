import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:futsaladmin/service/extraService.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'Booking.dart';


class TurfPage extends StatefulWidget {
  TurfPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TurfPageState createState() => _TurfPageState();
}

class _TurfPageState extends State<TurfPage> {


  var data = [];
  String displayDate = '';
  DateTime selectedDate;
  Map<String, String> message = {};

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;




  // String constructFCMPayload(String token) {
  //   // _messageCount++;
  //   return jsonEncode({
  //     // "category":"com.project.futsal",
  //     'registration_ids': ['egvocYSQTKm1JcFIgQXgRe:APA91bF-KkcMuM8laL5Xq1LQM8Xn1-8pQTWfBVA2PVvFr9sFf6qr4EMi9TA-4Z_TAb9Wo0RBJcYrZnRAxE56LoMj7jNlN2cO9OJnN0PSWS9lgYEXNJFCv30M9Mfs1SOHSNm2pzAIVYh8'],
  //     // 'restricted_package_name': 'com.project.futsaladmin',
  //     // "topic": "to all",
  //     // 'SenderId':'1089506944266',
  //     'data': {
  //       'via': 'FlutterFire Cloud Messaging!!!',
  //       // 'count': _messageCount.toString(),
  //     },
  //     'notification': {
  //       'title': 'Hello FlutterFire!',
  //       'body': 'This notification was created via FCM!',
  //     },
  //   });
  // }


  // Future<void> sendPushMessage() async {
  //   // if (_token == null) {
  //   //   print('Unable to send FCM message, no token exists.');
  //   //   return;
  //   // }
  //
  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'key = AAAA_auspQo:APA91bH0LvAtpVGsFNNyqXmvER2VI_KYV_V23zihuYRUYqbx8ZPUg3LLm_sYOMagn38S34UuSMRF3Du2EI7JyP1H27VCVuAh5ktQ7s1ScJVX-LNmCkdnKbFhwyXs6Vg10mytaDTBD6u3',
  //       },
  //       body: constructFCMPayload('_token'),
  //     ).then((value) => print(value.body));
  //     print('FCM request for device sent!');
  //   } catch (e) {
  //     print(e);
  //   }
  // }



  getData(date) async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection('mybooking').where('date', isEqualTo: date).where('current_status', isNotEqualTo: 'Requested').where('type', isEqualTo: 'Turf').orderBy('current_status',descending: true).orderBy('register_on').snapshots().listen((event) {
      print(event.docs);
      setState(() {
        data = event.docs.map((a)=>a.data()).toList();
        print(data);
      });
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var now = (DateTime.now());
    displayDate = DateFormat('d/M/yyyy').format(now);


    getData(displayDate);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text('Turf Booking'),
        centerTitle: true,
      ),
      floatingActionButton: new FloatingActionButton(
        // elevation: 0.0,
          child: new Icon(Icons.add),
          // backgroundColor: new Color(0xFFE57373),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingPage()));
          }
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child:

          ListView(
            // itemCount: data.length,
            // itemBuilder: (context, position) {
            //   Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onTap: (){
                            // Select Date and Check for Available Slot
                            if(selectedDate.toString() == 'null'){
                              selectedDate = DateTime.now();
                            };
                            _selectDate(context);
                            print(selectedDate.toString());
                          },
                          readOnly: true,
                          controller: TextEditingController(text: displayDate.toString()),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black45, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black45, width: 2.0),
                            ),
                            labelText: "Date of Booking",
                            labelStyle: TextStyle(color: Colors.black45)
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: RaisedButton(
                            child: Text('Search'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              getData(displayDate);
                            }
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  for(var i in data)
                    data.length == 0?Center(
                      child: Text('No Booking Found'),
                    ):
                  Card(
                    elevation: 0.5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4.0),
                      onTap: (){
                        Dialog(i, context);
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
                                          i['date'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 18.0),
                                          softWrap: true,
                                        ),
                                      ),
                                      _buildTag(context, i, i['current_status'])
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Start: " + i['slot'][0]['time'].split(' - ')[0] ,
                                        ),
                                      ],
                                    ),
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Total Hours: " + i['slot'].length.toString()),
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
                  ),
                ],
              // );
            // },
          ),
        ),
      ),
    );
  }



  Future<void> _selectDate(BuildContext context) async {
    var date = DateTime.now();
    selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: date,
      lastDate: date.add(new Duration(days: 30)),
    );
    setState(() {
      selectedDate = selectedDate;
      displayDate = (selectedDate.day.toString() +'/'+ selectedDate.month.toString() + "/"+selectedDate.year.toString());
    });
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



  void Dialog(list, context){

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

                              CollectionReference collectionsReference =
                                  FirebaseFirestore.instance.collection(
                                      'mybooking');
                              collectionsReference.doc(list['register_on'].toString()).update(
                                  {
                                    "current_status":'Cancelled',
                                  });
                              Navigator.pop(context);
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
                            title: Text('Name: ' + list['name'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Phone Number: ' + list['phone_number'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Amount Paid: ' + list['amount'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
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