import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal/screen/login.dart';
import 'package:futsal/service/Auth_Service.dart';
import 'dart:async';

import 'package:futsal/service/Other_Service.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  AuthClass authClass = AuthClass();
  TextEditingController phoneController = TextEditingController();
  String verificationIdFinal = "";
  int start = 60;
  bool wait = false;
  String buttonName = "Send";
  String smsCode = "";
  String password = "";
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getData();
  }


  // getData() async {
  //   await Firebase.initializeApp();
  //   FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
  //     print('event');
  //     print(event.docs.first.data());
  //   });
  // }


  @override
 // static final String path = "lib/src/pages/login/login1.dart";
  Widget _buildPageContent() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.grey.shade800,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 50,),
                ClipRRect(
                  child: Image.asset('assets/logo.jpeg'),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                SizedBox(height: 50,),
                ListTile(
                    title: TextField(
                      controller: phoneController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Mobile Number:",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.phone_android, color: Colors.white30,),
                        suffixIcon: InkWell(
                          onTap: wait
                              ? null
                              : () async {
                            FocusScope.of(context).unfocus();
                            if (phoneController.text.length != 10){
                              moreService().toaster('Invalid phone number', Colors.red);
                            }
                            else
                              FirebaseFirestore.instance
                                .collection('users')
                                .doc(phoneController.text)
                                .get()
                                .then((DocumentSnapshot documentSnapshot) async {
                                if(documentSnapshot.exists){
                                  moreService().toaster('Phone number already Exist', Colors.red);
                                }
                                else{
                                  print(phoneController.text.length);
                                  setState(() {
                                    start = 60;
                                    wait = true;
                                    buttonName = "Resend";
                                  });
                                  await authClass.verifyPhoneNumber(
                                      "+91 ${phoneController.text}", context,
                                      setData);
                                }

                              });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 0),
                            child: Text(
                              buttonName,
                              style: TextStyle(
                                color: wait ? Colors.grey : Colors.white,
                                // fontSize: 17,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                        keyboardType: TextInputType.number
                    )
                ),
                Divider(color: Colors.grey.shade600,),
                ListTile(
                    title: TextField(
                      // controller: TextEditingController()..text = password,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Password:",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.lock, color: Colors.white30,),
                      ),
                      onChanged: (val){
                          password = val;
                      },
                    ),
                ),
                Divider(color: Colors.grey.shade600,),
                ListTile(
                    title: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "OTP:",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.vpn_key, color: Colors.white30,),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13.0),
                            child: Text(start == 60 ||start == 0?'':start.toString(), style: TextStyle(color: Colors.grey),),
                          )
                        ),
                        keyboardType: TextInputType.number,
                      onChanged: (pin){
                        print("Completed: " + pin);
                        setState(() {
                          smsCode = pin;
                        });
                      },
                    )
                ),
                Divider(color: Colors.grey.shade600,),
                SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async {
                          if(password.isEmpty)
                            moreService().toaster('Please Enter password', Colors.red);
                          else if(password.length < 6)
                            moreService().toaster('Password must be minimum of 6', Colors.red);
                          else{
                            var item = await (_firebaseMessaging.getToken());
                            print(item);
                            Map<String,dynamic> data = {
                              "phone":this.phoneController.text,
                              "register_on":DateTime.now().millisecondsSinceEpoch,
                              "login_on":DateTime.now().millisecondsSinceEpoch,
                              "password": base64.encode(utf8.encode(password)),
                              "token": item
                            };
                            authClass.signInwithPhoneNumber(
                                verificationIdFinal, smsCode, context, data);
                          }
                          FocusScope.of(context).unfocus();
                        },
                        color: Colors.cyan,
                        child: Text('Login', style: TextStyle(color: Colors.white70, fontSize: 16.0),),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40,),
                // Text('Forgot your password?', style: TextStyle(color: Colors.grey.shade500),),
                // SizedBox(height: 40,),
                InkWell(
                  child: Text("Already have an Account? LOG IN", style: TextStyle(color: Colors.grey.shade500),),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => LoginPage()
                    ));
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }


  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer _timer = Timer.periodic(onsec, (timer) {
      // print(start);
      if (start == 0) {
        setState(() {
          // print('start');
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  void setData(String verificationId) {
    setState(() {
      verificationIdFinal = verificationId;
    });
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(),
    );
  }
}