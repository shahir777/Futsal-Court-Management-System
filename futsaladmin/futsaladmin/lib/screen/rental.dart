
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';

import 'add_tournament.dart';
// import 'package:futsal/screen/tournament.dart';
// import 'package:futsal/service/Other_Service.dart';



class RentalPage extends StatefulWidget {
  RentalPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _RentalPageState createState() => _RentalPageState();
}



class _RentalPageState extends State<RentalPage> {

  // var imageRight = true;
  var data = [];
  var item;
  var total = {"jersey_m": 0, "jersey_l": 0, "shoes_l": 0, "shoes_m": 0, "jersey_s": 0, "shoes_s": 0};


  getData() async {
    await Firebase.initializeApp();
    // DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(iid.toString()).get();
    var date = DateTime.now();
    var id = (date.toString().split(' ')[0]);
    print(id);
    FirebaseFirestore.instance.collection('mybooking').where('type', isEqualTo: 'Rental').where('date', isEqualTo: id).snapshots().listen((event) {
      print('event');
      setState(() {
        data = event.docs.map((a)=>a.data()).toList();
        print(data);
      });

    });
  }


  @override
  void initState() {
    print(item);
    // TODO: implement initState
    super.initState();
    getData();
    getSlot(setState);
  }



  getSlot(setState) async {
    FirebaseFirestore.instance.collection('settings').doc('available_jersey').snapshots().listen((event) {
      var dt = (event.data());
      // print(data);
      setState(() {
        total = {"jersey_m": dt['jersey_m'], "jersey_l": dt['jersey_l'], "shoes_l": dt['shoes_l'], "shoes_m": dt['shoes_m'], "jersey_s": dt['jersey_s'], "shoes_s": dt['shoes_s']};
      });
      // print(total);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Rental'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
        // elevation: 0,
      ),
      floatingActionButton: new FloatingActionButton(
        // elevation: 0.0,
          child: new Icon(Icons.settings),
          // backgroundColor: new Color(0xFFE57373),
          onPressed: (){
            DialogSetting(context);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => AddTournamentPage()));
          }
      ),
      body:
      data.length == 0?Center(
        child: Text('No Teams Found'),
      ):
      ListView(
        children: [
          for(var i in data)
            Card(
              elevation: 0.5,
              child: InkWell(
                borderRadius: BorderRadius.circular(4.0),
                onTap: (){
                  Dialog(i, context);
                  // var len = (i['number_of_teams']) - (i['registered'].length);
                  // if(len > 0)
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => TournamentPage(i)));
                  // else{
                  //   moreService().toaster('Registration Closed', Colors.red);
                  // }
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
                                    i['name'],
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
                                    text: "Mobile Number: " + i['phone_number'],
                                  ),
                                ],
                              ),
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Time: "+ i['time'].toString()),
                                // _buildTag(context, i, 'seats')
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }


  Container _buildThumbnail() {
    return Container(
      height: 100,
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


  Container _buildTag(BuildContext context, item, type) {
    // var len = (item['number_of_teams']) - (item['registered'].length);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: type == 'Requested'?Colors.blue:Colors.red),
      child: Column(
        children: [
          Text(
            type == 'Requested'?'Active':'Cancelled',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
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
                        (list['current_status'] == 'Active') ? RaisedButton(
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
                          // for(var i in list['slot'])
                          ListTile(
                            title: Text('Time: ' + list['time'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('No of ${list['category']} (S): ' + list['no_of_s_${list['category']}'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          // for(var i in list['slot'])
                          ListTile(
                            title: Text('No of ${list['category']} (M): ' + list['no_of_m_${list['category']}'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('No of ${list['category']} (L): ' + list['no_of_l_${list['category']}'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          // ListTile(
                          //   title: Text('Current Status: ' +
                          //       list['current_status'], style: TextStyle(
                          //       color: Colors.black87),),
                          // ),
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




  void DialogSetting(context){

    var slot = {};

    // getSlot(setState);
    setState((){
      slot = json.decode(json.encode(total));
    });
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
                       RaisedButton(
                            child: Text('Apply'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              print(total);
                              print(slot);
                              CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('settings');
                              collectionsReference1.doc('available_jersey').update({"jersey_m": slot['jersey_m'], "jersey_l": slot['jersey_l'], "shoes_l": slot['shoes_l'], "shoes_m": slot['shoes_m'], "jersey_s": slot['jersey_s'], "shoes_s": slot['shoes_s']});
                              Navigator.pop(context);
                            }
                        )
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
                          Divider(),
                          Text('No of Shoes (S)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(text: 'ss'),
                            initialValue: slot['shoes_s'],
                            min: 0,
                            // max: 3,
                            onDecrement: (val){
                              setState((){
                                slot['shoes_s'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['shoes_s'] = val;
                              });
                            },
                          ),
                          SizedBox(height: 20,),
                          Text('No of Shoes (M)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(),
                            initialValue: slot['shoes_m'],
                            min: 0,
                            onDecrement: (val){
                              setState((){
                                slot['shoes_m'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['shoes_m'] = val;
                              });
                            },
                            // max: 3,
                          ),
                          SizedBox(height: 20,),
                          Text('No of Shoes (L)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(text: 'sl'),
                            initialValue: slot['shoes_l'],
                            min: 0,
                            onDecrement: (val){
                              setState((){
                                slot['shoes_l'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['shoes_l'] = val;
                              });
                            },
                            // max: 3,
                          ),
                          SizedBox(height: 20,),
                          Text('No of Jersey (S)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(text: 'js'),
                            initialValue: slot['jersey_s'],
                            min: 0,
                            onDecrement: (val){
                              setState((){
                                slot['jersey_s'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['jersey_s'] = val;
                              });
                            },
                            // max: 3,
                          ),
                          SizedBox(height: 20,),
                          Text('No of Jersey (M)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(text: 'jm'),
                            initialValue: slot['jersey_m'],
                            min: 0,
                            onDecrement: (val){
                              setState((){
                                slot['jersey_m'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['jersey_m'] = val;
                              });
                            },
                            // max: 3,
                          ),
                          SizedBox(height: 20,),
                          Text('No of Jersey (L)'),
                          NumberInputWithIncrementDecrement(
                            controller: TextEditingController(text: 'jm'),
                            initialValue: slot['jersey_l'],
                            min: 0,
                            onDecrement: (val){
                              setState((){
                                slot['jersey_l'] = val;
                              });
                            },
                            onIncrement: (val){
                              setState((){
                                slot['jersey_l'] = val;
                              });
                            },
                            // max: 3,
                          ),
                          SizedBox(height: 20,),
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
