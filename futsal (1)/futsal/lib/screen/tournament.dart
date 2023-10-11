// import 'dart:convert';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:futsal/service/Other_Service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';



class TournamentPage extends StatefulWidget {
  TournamentPage(this.i, {Key key, this.title}) : super(key: key);
  final String title;
  var i;
  @override
  _TournamentPageState createState() => _TournamentPageState(this.i);
}



class _TournamentPageState extends State<TournamentPage> {

  var team = '';
  var player = '';
  var address = '';
  var phone = '';
  var i;
  var alocated = [];
  _TournamentPageState(this.i);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
  }
  getId() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = (json.decode(prefs.getString('user')));
    phone = user['phone'];
    DocumentSnapshot ds = await FirebaseFirestore.instance.collection("tournament").doc(i['register_on'].toString()).get();
    if(ds.exists){
      var dt = jsonDecode(jsonEncode(ds.data()))['registered'];
      alocated = dt;
    }
    print(phone);
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
              height: 250,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Image.network(
                      'https://images.financialexpress.com/2020/11/football.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: team.toString()),
                    decoration: InputDecoration(
                      labelText: "Team Name",
                    ),
                    onChanged: (val){
                      team = val;
                    },
                    style: TextStyle(
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: TextEditingController(text: player.toString()),
                    decoration: InputDecoration(
                      labelText: "Player Name",
                    ),
                    onChanged: (val){
                      player = val;
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
                  const SizedBox(height: 20.0),
                  MaterialButton(
                    child: Text("Register"),
                    color: Colors.pink,
                    onPressed: () {
                      if(team.isEmpty || player.isEmpty || address.isEmpty){
                        moreService().toaster('Please Fill all the Data', Colors.red);
                      }
                      else{
                        var id = DateTime.now().millisecondsSinceEpoch;
                        Map<String,dynamic> data = {
                          "team_name": team,
                          "player_name": player,
                          "address": address,
                          "register_on": id,
                          "phone_number": phone,
                          "current_status": "Requested",
                          "paid_status": false,
                          "type": "Tournament",
                          "amount": 0,
                          "tournament_id": this.i['id'],
                          "tournament_name":this.i['name'],
                          "first_price":this.i['first_price']
                        };
                        CollectionReference collectionsReference = FirebaseFirestore.instance.collection('mybooking');
                        collectionsReference.doc(id.toString()).set(data);
                        alocated.add(id.toString());
                        CollectionReference collectionsReference1 = FirebaseFirestore.instance.collection('tournament');
                        collectionsReference1.doc(i['register_on'].toString()).update({"registered": alocated});
                        setState(() {
                          team = '';
                          player = '';
                          address = '';
                        });
                        moreService().toaster('Successfully Registered', Colors.green);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (builder) => HomePage()),
                                (route) => false);
                      }
                      FocusScope.of(context).unfocus();
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
}