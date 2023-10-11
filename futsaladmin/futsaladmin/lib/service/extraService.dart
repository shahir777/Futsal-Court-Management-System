


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class moreService {
  toaster(msg, color){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        // textColor: Colors.white,
        fontSize: 16.0
    );
  }
}