import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:futsal/screen/home.dart';
import 'package:futsal/screen/login.dart';
// import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Other_Service.dart';

class AuthClass {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut({BuildContext context}) async {
    try {
      await _auth.signOut();
      // await storage.delete(key: "token");
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context, Function setData) async {
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      print('Verification Completed');
      // moreService().toaster('Verification Code sent to your phone number', Colors.green);
      showSnackBar(context, "Verification Completed");
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException exception) {
      showSnackBar(context, exception.toString());
    };
    PhoneCodeSent codeSent =
        (String verificationID, [int forceResnedingtoken]) {
          print('Verification Code sent on the phone number');

          // showSnackBar(context, "Verification Code sent on the phone number");
          moreService().toaster('Verification Code sent to your phone number', Colors.green);
          setData(verificationID);
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationID) {
      moreService().toaster('Your OTP has been Expired', Colors.red);
    };

    try {
      print('asdfghj');
      await _auth.verifyPhoneNumber(
          timeout: Duration(seconds: 60),
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      moreService().toaster('Something Wrong. Please retry', Colors.red);
      // showSnackBar(context, e.toString());
    }
  }

  Future<void> signInwithPhoneNumber(
      String verificationId, String smsCode, BuildContext context, data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> _counter;
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      // storeTokenAndData(userCredential);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => HomePage()),
              (route) => false);
      await Firebase.initializeApp();

      CollectionReference collectionsReference = FirebaseFirestore.instance.collection('users');
      collectionsReference.doc(data["phone"]).set(data);
      prefs.setBool('isLoggedIn', true);
      prefs.setString('user', json.encode(data));
      moreService().toaster('You have been Successfully Registered', Colors.green);
    } catch (e) {
      moreService().toaster('Something Wrong. Please retry', Colors.red);
      // showSnackBar(context, e.toString());
    }
  }

  void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
