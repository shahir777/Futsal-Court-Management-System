
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:futsal/screen/tournament.dart';
import 'package:futsal/service/Other_Service.dart';



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
    FirebaseFirestore.instance.collection('tournament').where('status', isEqualTo: 'open').snapshots().listen((event) {
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
        title: Text('TOURNAMENT'),
        centerTitle: true,
        backgroundColor: Colors.green[500],
        // elevation: 0,
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
                var len = (i['number_of_teams']) - (i['registered'].length);
                if(len > 0)
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TournamentPage(i)));
                else{
                  moreService().toaster('Registration Closed', Colors.red);
                }
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
}
