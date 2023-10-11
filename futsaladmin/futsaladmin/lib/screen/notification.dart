import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:futsaladmin/service/extraService.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;



class NotificationPage extends StatefulWidget {
  NotificationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {


  var data = [];
  String title = '';
  String body = '';
  Map<String, String> message = {};
  var tokenList = [];


  String constructFCMPayload(String token) {
    return jsonEncode({
      'registration_ids': tokenList,
      'notification': {
        'title': title,
        'body': body,
      },
    });
  }


  Future<void> sendPushMessage(token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key = AAAA_auspQo:APA91bH0LvAtpVGsFNNyqXmvER2VI_KYV_V23zihuYRUYqbx8ZPUg3LLm_sYOMagn38S34UuSMRF3Du2EI7JyP1H27VCVuAh5ktQ7s1ScJVX-LNmCkdnKbFhwyXs6Vg10mytaDTBD6u3',
        },
        body: constructFCMPayload(token),
      ).then((value) => print(value.body));
      print('FCM request for device sent!');
      title = '';
      body = '';
    } catch (e) {
      print(e);
    }
  }






  getData() async {

    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      print('event');
      print(event.docs.first.data());
    });


    var data = await FirebaseFirestore.instance.collection('users').get();

    var t1 = (data.docs.map((e) => e.data()['token'])).toList();

    tokenList = (t1.where((element) => element != null).toList());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var now = (DateTime.now());
    getData();
    // displayDate = DateFormat('d/M/yyyy').format(now);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[500],
          title: Text('Notification'),
          centerTitle: true,
    ),
    body: Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (val){
                title = val;
              },
              controller: TextEditingController(text: title.toString()),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2.0),
                  ),
                  labelText: "Title",
                  labelStyle: TextStyle(color: Colors.black45)
              ),
            ),
            SizedBox(height: 20,),
            TextField(
              onChanged: (val){
                body = val;
              },
              controller: TextEditingController(text: body.toString()),
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 2.0),
                  ),
                  labelText: "Body",
                  labelStyle: TextStyle(color: Colors.black45)
              ),
            ),
            RaisedButton(
                child: Text('Send'),
                color: Colors.green,
                textColor: Colors.white, // foreground
                onPressed: () async {
                  if(title == '' || body == ''){
                    moreService().toaster('Please fill all field', Colors.red);
                  }
                  else{
                    moreService().toaster('Notification Successfully Sent', Colors.green);
                    sendPushMessage('displayDate');
                  }
                }
            ),
          ],
        ),
      ),
    )
    );
  }
}