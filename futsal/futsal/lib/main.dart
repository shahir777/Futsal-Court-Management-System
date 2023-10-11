import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:futsal/screen/home.dart';
import 'package:futsal/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  var isLoggedIn = (prefs.getBool('isLoggedIn') == null) ? false : prefs.getBool('isLoggedIn');
  runApp(MaterialApp(
    builder: EasyLoading.init(),
    // debugShowCheckedModeBanner: false,
    home: isLoggedIn ? HomePage(title: '') : LoginPage(title: ''),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final storage = new LocalStorage('user');
    SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
    //
    // var isLoggedIn = prefs.getInt('isLoggedIn') == null?false:prefs.getInt('isLoggedIn');
    // print('isLoggedIn');
    // print(isLoggedIn);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(title: 'Flutter Demo Home Page'),//initialService(),//isLoggedIn? HomePage(title: 'Flutter Demo Home Page'):LoginPage(title: 'Flutter Demo Home Page')//initialService(),//LoginPage(title: 'Flutter Demo Home Page'),
    );
  }
}
