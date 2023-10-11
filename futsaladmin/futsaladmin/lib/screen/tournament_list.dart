
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'add_tournament.dart';
import 'detailed_tournament.dart';
// import 'package:futsal/screen/tournament.dart';
// import 'package:futsal/service/Other_Service.dart';



class TournamentListPage extends StatefulWidget {
  TournamentListPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _TournamentListPageState createState() => _TournamentListPageState();
}



class _TournamentListPageState extends State<TournamentListPage> {

  var imageRight = true;
  var data = [];


  getData() async {
    await Firebase.initializeApp();
    // DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(iid.toString()).get();
    FirebaseFirestore.instance.collection('tournament').snapshots().listen((event) {
      var item = [];
      print('event');
      setState(() {
        data = event.docs.map((a)=>a.data()).toList();
        print(data);
      });

    });
  }


  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    getData();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tournament'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
        // elevation: 0,
      ),
      floatingActionButton: new FloatingActionButton(
          // elevation: 0.0,
          child: new Icon(Icons.add),
          // backgroundColor: new Color(0xFFE57373),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTournamentPage()));
          }
      ),
      body:
      data.length == 0?Center(
        child: Text('No Tournament Found'),
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
                  //       MaterialPageRoute(builder: (context) => TournamentDetailPage(i)));
                  // else{
                  //   moreService().toaster('Registration Closed', Colors.red);
                  // }
                },
                child: Row(
                  children: <Widget>[
                    // _buildThumbnail(),
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
                                _buildTag(context, i, 'price')
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Date: " + i['date_of_match'],
                                  ),
                                ],
                              ),
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Entry Fees: "+ i['fees'].toString()),
                                _buildTag(context, i, 'seats')
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
      height: 120,
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
    var len = (item['number_of_teams']) - (item['registered'].length);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: type == 'price'?Colors.blue:item['status'] == 'open'?len > 0?Colors.green:Colors.red:Colors.red),
      child: Column(
        children: [
          Text(
            type == 'price'?'1st price: '+item['first_price'].toString():item['status'] == 'open'?len > 0?'Available seats: '+ len.toString():'Registration Closed':'Registration Closed',
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
                        if(list['status'] == 'open')
                        RaisedButton(
                            child: Text('Close Tournament'),
                            color: Colors.red,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              CollectionReference collectionsReference =
                              FirebaseFirestore.instance.collection(
                                  'tournament');
                              collectionsReference.doc(list['register_on'].toString()).update(
                                  {
                                    "status":'closed',
                                  });
                              Navigator.pop(context);
                            }
                        ),
                        SizedBox(width: 10,),
                        RaisedButton(
                            child: Text('Go to Teams'),
                            color: Colors.green,
                            textColor: Colors.white, // foreground
                            onPressed: () async {
                              // print('aaaaaaaaaaaaaaaaaaaaaaa');
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TournamentDetailPage(list)));
                              // print('aaaaaaaaaaaaaaaaaaaaaaa');
                            }
                        )
                      ],
                    ),
                  ],
                  contentPadding: EdgeInsets.all(10),
                  title: new Text('Tournament'),
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
                            title: Text('Status: ' + list['status'].toString(),
                              style: TextStyle(color: list['status'] == 'open'?Colors.green:Colors.red,
                                fontWeight: FontWeight.w900,
                                fontSize: 18
                              ),),
                          ),
                          ListTile(
                            title: Text('Tournament Name: ' + list['name'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Phone Number: ' + list['phone_number'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Date of Match: ' + list['date_of_match'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Ground Fees: ' + list['fees'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          // for(var i in list['slot'])
                          ListTile(
                            title: Text('First Price: ' + list['first_price'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Total Teams: ' + list['number_of_teams'].toString(),
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
}
