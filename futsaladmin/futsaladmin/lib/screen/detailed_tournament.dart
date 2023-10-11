
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'add_tournament.dart';
// import 'package:futsal/screen/tournament.dart';
// import 'package:futsal/service/Other_Service.dart';



class TournamentDetailPage extends StatefulWidget {
  TournamentDetailPage(this.item, {Key key, this.title}) : super(key: key);
  final String title;
  var item;
  @override
  _TournamentDetailPageState createState() => _TournamentDetailPageState(item);
}



class _TournamentDetailPageState extends State<TournamentDetailPage> {

  var imageRight = true;
  var data = [];
  var item;
  _TournamentDetailPageState(this.item);


  getData() async {
    await Firebase.initializeApp();
    // DocumentSnapshot ds = await FirebaseFirestore.instance.collection("date").doc(iid.toString()).get();
    FirebaseFirestore.instance.collection('mybooking').where('type', isEqualTo: 'Tournament').where('current_status', isEqualTo: 'Requested').where('tournament_id', isEqualTo: item['id']).snapshots().listen((event) {
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
  }


  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Teams'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
        // elevation: 0,
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
                                    i['team_name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18.0),
                                    softWrap: true,
                                  ),
                                ),
                                // _buildTag(context, i, 'price')
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
                                Text("Address: "+ i['address'].toString()),
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
    var len = (item['number_of_teams']) - (item['registered'].length);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 8.0,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: type == 'price'?Colors.blue:len > 0?Colors.green:Colors.red),
      child: Column(
        children: [
          Text(
            type == 'price'?'1st price: '+item['first_price'].toString():len > 0?'Available seats: '+ len.toString():'Registration Closed',
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
                        (list['current_status'] == 'Upcoming') ? RaisedButton(
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
                            title: Text('Team Name: ' + list['team_name'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Phone Number: ' + list['phone_number'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Registered Player: ' + list['player_name'].toString(),
                              style: TextStyle(color: Colors.black87),),
                          ),
                          ListTile(
                            title: Text('Address: ' + list['address'],
                              style: TextStyle(color: Colors.black87),),
                          ),
                          // // for(var i in list['slot'])
                          // ListTile(
                          //   title: Text('Time: ' + list['time'],
                          //     style: TextStyle(color: Colors.black87),),
                          // ),
                          // ListTile(
                          //   title: Text('No of ${list['category']} (S): ' + list['no_of_s_Shoes'].toString(),
                          //     style: TextStyle(color: Colors.black87),),
                          // ),
                          // // for(var i in list['slot'])
                          // ListTile(
                          //   title: Text('No of ${list['category']} (M): ' + list['no_of_m_Shoes'].toString(),
                          //     style: TextStyle(color: Colors.black87),),
                          // ),
                          // ListTile(
                          //   title: Text('No of ${list['category']} (L): ' + list['no_of_l_Shoes'].toString(),
                          //     style: TextStyle(color: Colors.black87),),
                          // ),
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
