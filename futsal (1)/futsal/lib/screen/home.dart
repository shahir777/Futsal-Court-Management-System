import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:futsal/screen/rental.dart';
import 'Mybooking.dart';
import 'home1.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}
class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String title;
  String body;
}


class _HomePageState extends State<HomePage> {

  int _index = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotification();
  }

  // Notification Config
  getNotification() async{
    await Firebase.initializeApp();
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    print(settings.authorizationStatus);
    print(AuthorizationStatus.authorized);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
        print(message);
      });
      // FirebaseMessaging.onBackgroundMessage((message) => null)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        print('Notification1111');
        print(message.notification.title);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message.notification.title, textAlign: TextAlign.center,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              subtitle: Text(message.notification.body, textAlign: TextAlign.center,),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  print('hello');
                },
              ),
            ],
          ),
        );
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_index) {
      case 0:
        child = Home1Page();
        break;
      case 1:
        child = Rental();
        break;
      case 2:
        child = MyBooking();
        break;
    }
    return Scaffold(
      body: SizedBox.expand(child: child),
      // backgroundColor: Colors.black87,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (newIndex) => setState(() => _index = newIndex),
        currentIndex: _index,
        selectedItemColor: Colors.green[500],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), title: Text("Home")),
          BottomNavigationBarItem(icon: Icon(Icons.sports_football_rounded), title: Text("Rental Items")),
          BottomNavigationBarItem(icon: Icon(Icons.history), title: Text("My Booking")),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[500],
        title: Text(
          "Hilltop Arena",
          style: TextStyle(color: Colors.grey[100], fontSize: 24),
        ),
        centerTitle: true,
      ),
    );
  }
}