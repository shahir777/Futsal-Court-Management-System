import 'package:flutter/material.dart';
import 'package:futsaladmin/service/extraService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  var phone = '';
  var password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.grey.shade800,
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(height: 50,),
                  ClipRRect(
                    // child: Image.asset('assets/logo.jpeg'),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  SizedBox(height: 50,),

                  ListTile(
                      title: TextField(
                        controller: TextEditingController(text: phone.toString()),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "User Name:",
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            icon: Icon(Icons.person, color: Colors.white30,)
                        ),
                        // keyboardType: TextInputType.number,
                        onChanged: (val){
                          phone = val;
                        },
                      )
                  ),
                  Divider(color: Colors.grey.shade600,),
                  ListTile(
                      title: TextField(
                        obscureText: true,
                        controller: TextEditingController(text: password.toString()),
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
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            if(password == 'admin' && phone == 'admin'){
                              moreService().toaster('Successfully Logged In', Colors.green);
                              prefs.setBool('isLoggedIn', true);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (builder) => MyHomePage()),
                                      (route) => false);
                            }
                            else if(phone == '' || password == ''){
                              moreService().toaster('Please enter username and password', Colors.red);
                            }
                            else{
                              moreService().toaster('Incorrect username or password', Colors.red);
                            }
                          },
                          color: Colors.cyan,
                          child: Text('Login', style: TextStyle(color: Colors.white70, fontSize: 16.0),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
