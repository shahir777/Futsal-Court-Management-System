import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futsal/screen/register.dart';
import 'package:futsal/service/Other_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String phone = "";
  String password = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }


  getData() async {
    await Firebase.initializeApp();
    // AuthClass().initialService();

    // FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
    //   print('event');
    //   print(event.docs.first.data());
    // });
  }


  @override
  static final String path = "lib/src/pages/login/login1.dart";
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
                // ListTile(
                //     title: TextField(
                //       style: TextStyle(color: Colors.white),
                //       decoration: InputDecoration(
                //           hintText: "Email address:",
                //           hintStyle: TextStyle(color: Colors.white70),
                //           border: InputBorder.none,
                //           icon: Icon(Icons.email, color: Colors.white30,)
                //       ),
                //     )
                // ),
                // Divider(color: Colors.grey.shade600,),
                ListTile(
                    title: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Mobile Number",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.phone_android, color: Colors.white30,)
                      ),
                        keyboardType: TextInputType.number,
                      onChanged: (val){
                        phone = val;
                      },
                    )
                ),
                Divider(color: Colors.grey.shade600,),
                ListTile(
                    title: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "Password:",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          icon: Icon(Icons.lock, color: Colors.white30,)
                      ),
                      onChanged: (val){
                        password = val;
                      },
                    )
                ),
                Divider(color: Colors.grey.shade600,),
                SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async{
                          if(phone.isEmpty || password.isEmpty){
                            moreService().toaster("Please Enter phone number and password", Colors.red);
                          }
                          else if(phone.length != 10){
                            moreService().toaster("please Enter valid phone number", Colors.red);
                          }
                          else if(password.length < 6){
                            moreService().toaster("Password must be minimum of 6", Colors.red);
                          }
                          else{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(phone)
                                .get()
                                .then((DocumentSnapshot documentSnapshot) async {
                              if (documentSnapshot.exists) {
                                // if(documentSnapshot.data())
                                var data = jsonDecode(jsonEncode(documentSnapshot.data()));
                                print(base64.encode(utf8.encode(password)));
                                if(data['password'] == base64.encode(utf8.encode(password))){
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (builder) => HomePage()),
                                          (route) => false);
                                  CollectionReference collectionsReference = FirebaseFirestore.instance.collection('users');
                                  collectionsReference.doc(data["phone"]).update(
                                      {
                                        "login_on":DateTime.now().millisecondsSinceEpoch,
                                      });
                                  prefs.setBool('isLoggedIn', true);
                                  prefs.setString('user', json.encode(data));
                                  // await storage.setItem('isLoggedIn', true);
                                  // await storage.setItem('user', data);
                                  moreService().toaster('You have been Successfully Logged In', Colors.green);
                                }
                                else{
                                  moreService().toaster('Incorrect Password', Colors.red);
                                }
                              }
                              else{
                                moreService().toaster("User doesn't Exist", Colors.red);
                              }
                            });
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
                  child: Text("Don't have an Account? SIGN UP", style: TextStyle(color: Colors.grey.shade500),),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => RegisterPage()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(),
    );
  }
}