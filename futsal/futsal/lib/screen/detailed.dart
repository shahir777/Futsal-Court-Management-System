import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:futsal/service/Other_Service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';



class DetailedPage extends StatefulWidget {
  DetailedPage(this.type, this.image, {Key key, this.title}) : super(key: key);
  final String title;
  final String type;
  final String image;
  @override
  _DetailedPageState createState() => _DetailedPageState(this.type, this.image);
}



class _DetailedPageState extends State<DetailedPage> {

  var shoes_s = 0;
  var shoes_m = 0;
  var shoes_l = 0;
  var name = '';
  var address = '';
  var phone = '';
  var image = '';
  var type = '';
  var time = '';
  var displayDate = '';
  var s = 0;
  var m = 0;
  var l = 0;
  var isEmpty = false;
  var dt = {};
  var allDate = ['07.00am - 08.00am','08.00am - 09.00am','09.00am - 10.00am','10.00am - 11.00am','11.00am - 12.00pm',
    '12.00pm - 01.00pm','01.00pm - 02.00pm','02.00pm - 03.00pm','03.00pm - 04.00pm','04.00pm - 05.00pm','05.00pm - 06.00pm',
    '06.00pm - 07.00pm','07.00pm - 08.00pm','08.00pm - 09.00pm','09.00pm - 10.00pm','10.00pm - 11.00pm',
  ];
  var id = '';
  var data = [];
  var hide = false;
  DateTime selectedDate;
  _DetailedPageState(this.type, this.image);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();



    // Remove Expired Time Slot
    print(DateFormat('hh:mm a').format(DateTime.now()));
    var time = DateFormat('hh:mm a').format(DateTime.now());
    var t1 = time.split(' ').last;
    var t2 = time.split(':').first;
    var t3 = t2 + '.00' + t1.toLowerCase();
    var ii = 0;
    var isThere = false;
    for(var j in allDate){
      ii++;
      if(j.split(' - ')[0] == t3){
        isThere = true;
        print(allDate.sublist(ii, allDate.length));
        allDate = allDate.sublist(ii, allDate.length);
      }
    }
    if(!isThere){
      isEmpty = true;
      allDate = [];
    }


    var AP = (allDate[0].split(' - ')[0]);
    print(AP);

    getId();
  }




  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Razorpay Config
    EasyLoading.dismiss();
  }

  getId() async{
    // Get User ID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = (json.decode(prefs.getString('user')));
    phone = user['phone'];
    print(phone);
  }


  getDate(tm, tm1) async {
    // Get Available Shoes and Jersey
    await EasyLoading.show(
      status: 'Checking available slot',
      maskType: EasyLoadingMaskType.black,
    );
    setState(() {
      hide = true;
    });
    DateTime now = new DateTime.now();
    // DateTime date = new DateTime(now.year, now.month, now.day, 11);
    var i = now.toString().split(' ')[0];
    id = i+'-'+tm;
    print(id);

    FirebaseFirestore.instance.collection('rental').doc(id).snapshots().listen((event) {
      print(event.data());
    });

    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("rental").doc(id).get();
    if(ds.exists){

      FirebaseFirestore.instance.collection('rental').doc(id).snapshots().listen((event) {
        var dt = (event.data());
        this.dt = dt;
        if(type == 'Shoes'){
          setState(() {
            // var dt = jsonDecode(jsonEncode(ds.data()));
            s = dt['shoes_total_s'] - dt['shoes_reg_s'].length;
            m = dt['shoes_total_m'] - dt['shoes_reg_m'].length;
            l = dt['shoes_total_l'] - dt['shoes_reg_l'].length;
            s < 0?s = 0:s = s;
            m < 0?m = 0:m = m;
            l < 0?l = 0:l = l;
          });
        }
        if(type == 'Jersey'){
          setState(() {
            // var dt = jsonDecode(jsonEncode(ds.data()));
            s = dt['jersey_total_s'] - dt['jersey_reg_s'].length;
            m = dt['jersey_total_m'] - dt['jersey_reg_m'].length;
            l = dt['jersey_total_l'] - dt['jersey_reg_l'].length;
            s < 0?s = 0:s = s;
            m < 0?m = 0:m = m;
            l < 0?l = 0:l = l;
          });
        }
      });
    }
    else{
      DocumentSnapshot ds1 = await FirebaseFirestore.instance.collection("settings").doc('available_jersey').get();
      var dt = jsonDecode(jsonEncode(ds1.data()));
      print(dt);
      var items = {
        'shoes_total_s': dt['shoes_s'],
        'shoes_reg_s': [],
        'shoes_total_m': dt['shoes_m'],
        'shoes_reg_m': [],
        'shoes_total_l': dt['shoes_l'],
        'shoes_reg_l': [],
        'jersey_total_s': dt['jersey_s'],
        'jersey_reg_s': [],
        'jersey_total_m': dt['jersey_m'],
        'jersey_reg_m': [],
        'jersey_total_l': dt['jersey_l'],
        'jersey_reg_l': [],
        'id': id,
        'date': i,
        'time': tm1,
      };
      CollectionReference collectionsReference = FirebaseFirestore.instance.collection('rental');
      collectionsReference.doc(id).set(items);
      getDate(tm, tm1);
    }
    setState(() {
      hide = false;
    });
    EasyLoading.dismiss();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // height: 250,
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                    bottom: 20.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('Book your ${type}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold)),
                          // Text('subtitle', style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(height: 10,),
                Text('Available ${type} Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('S - ${s}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text('M - ${m}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text('L - ${l}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: name.toString()),
                    decoration: InputDecoration(
                      labelText: "Name",
                    ),
                    onChanged: (val){
                      name = val;
                    },
                    style: TextStyle(
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: address.toString()),
                    decoration: InputDecoration(
                      labelText: "Address",
                    ),
                    onChanged: (val){
                      address = val;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: time.toString()),
                    decoration: InputDecoration(
                      labelText: "Available Slot",
                    ),
                    readOnly: true,
                    onTap: (){
                      setState(() {
                        shoes_s = 0;
                        shoes_m = 0;
                        shoes_l = 0;
                      });
                      Dialog('service', allDate,context);
                    },
                  ),
                  const SizedBox(height: 15.0),
                  Text('No.of ${type}',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 15.0),
                  hide?Container():Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .4,
                        child: Column(
                          children: [
                            Text('Small',style: TextStyle(fontWeight: FontWeight.bold),),
                            CupertinoSpinBox(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                              min: 0,
                              max: s.toDouble(),
                              value: shoes_s.toDouble(),
                              // direction: Axis.vertical,
                              onChanged: (value) {
                                shoes_s = value.toInt();
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .4,
                        child: Column(
                          children: [
                            Text('Medium',style: TextStyle(fontWeight: FontWeight.bold),),
                            CupertinoSpinBox(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                              min: 0,
                              max: m.toDouble(),
                              value: shoes_m.toDouble(),
                              // direction: Axis.vertical,
                              onChanged: (value) {
                                shoes_m = value.toInt();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  hide?Container():Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .4,
                        child: Column(
                          children: [
                            Text('Large',style: TextStyle(fontWeight: FontWeight.bold),),
                            CupertinoSpinBox(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                              min: 0,
                              max: l.toDouble(),
                              value: shoes_l.toDouble(),
                              // direction: Axis.vertical,
                              onChanged: (value) {
                                shoes_l = value.toInt();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  MaterialButton(
                    child: Text("Register"),
                    color: Colors.pink,
                    onPressed: () {
                      if(name.isEmpty || address.isEmpty || (shoes_l == 0 && shoes_m == 0 && shoes_s == 0)){
                        moreService().toaster('Please Fill all the Data', Colors.red);
                      }
                      else if(shoes_l > l || shoes_m > m || shoes_s > s){
                        moreService().toaster('Please Check Available Shoes', Colors.red);
                      }
                      else{
                        var iid = DateTime.now().millisecondsSinceEpoch;
                        Map<String,dynamic> data = {
                          "name": name,
                          "address": address,
                          "register_on": iid,
                          "phone_number": phone,
                          "current_status": "Requested",
                          "paid_status": false,
                          "type": 'Rental',
                          "time": time,
                          "amount": 0,
                          "category":type,
                          "no_of_s_${type}": shoes_s,
                          "no_of_m_${type}": shoes_m,
                          "no_of_l_${type}": shoes_l,
                        };
                        CollectionReference collectionsReference = FirebaseFirestore.instance.collection('mybooking');
                        collectionsReference.doc(iid.toString()).set(data);
                        Map<String,dynamic> item = {};
                        var small = [];
                        var medium = [];
                        var large = [];

                        if(type == 'Shoes'){
                          small = dt['shoes_reg_s'];
                          medium = dt['shoes_reg_m'];
                          large = dt['shoes_reg_l'];
                        }
                        if(type == 'Jersey'){
                          small = dt['jersey_reg_s'];
                          medium = dt['jersey_reg_m'];
                          large = dt['jersey_reg_l'];
                        }

                        for(var j = 0;j < shoes_s;j++){
                          small.add(iid);
                        }
                        for(var j = 0;j < shoes_m;j++){
                          medium.add(iid);
                        }
                        for(var j = 0;j < shoes_l;j++){
                          large.add(iid);
                        }
                        if(type == 'Shoes'){
                          item = {
                            "shoes_reg_s":small,
                            "shoes_reg_m":medium,
                            "shoes_reg_l":large,
                          };
                        }
                        if(type == 'Jersey'){
                          item = {
                            "jersey_reg_s":small,
                            "jersey_reg_m":medium,
                            "jersey_reg_l":large,
                          };
                        }
                        CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('rental');
                        collectionsReference1.doc(id).update(item);
                        moreService().toaster('Successfully Registered', Colors.green);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (builder) => HomePage()),
                                (route) => false);
                      }
                      // FocusScope.of(context).unfocus();
                    },
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void Dialog(service, list, context){
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        contentPadding: EdgeInsets.all(10),
        title: new Text('Available Slot'),
        content: isEmpty?
        Container(
          height: MediaQuery.of(context).size.height * .5,
          child: Center(
            child: Text('No Available Slots'),
          ),
        )
            :
         Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * .5),
          // color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for(var i in list)
                  ListTile(
                    // leading: Icon(Icons.person_outline, color: Colors.white,),
                    title: Text(i, style: TextStyle(color: Colors.black87),),
                    onTap: () {
                      var tm = ((i.split(' - ')[0]).split('.').join(''));
                      // print(tm, i);
                      getDate(tm, i);
                      setState(() {
                        time = i;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}