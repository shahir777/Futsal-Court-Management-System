import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:futsaladmin/screen/tournament_list.dart';
import 'package:futsaladmin/service/extraService.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;



class AddTournamentPage extends StatefulWidget {
  AddTournamentPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddTournamentPageState createState() => _AddTournamentPageState();
}

class _AddTournamentPageState extends State<AddTournamentPage> {


  var data = [];
  String title = '';
  String body = '';
  Map<String, String> message = {};
  var tokenList = [];
  var name = '';
  var noOfTeams = '';
  var firstPrice = '';
  var entryFee = '';
  var contactNumber = '';
  var date = '';
  var selectedDate;


  getData() async {

    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      print('event');
      print(event.docs.first.data());
    });


    var data = await FirebaseFirestore.instance.collection('users').get();

    var t1 = (data.docs.map((e) => e.data()['token'])).toList();

    tokenList = (t1.where((element) => element != null).toList());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var now = (DateTime.now());
    getData();
    // displayDate = DateFormat('d/M/yyyy').format(now);
  }



  addTournament(){
    var id = DateTime.now().millisecondsSinceEpoch;
    Map<String,dynamic> data = {
      "date_of_match":date,
      "register_on":id,
      "fees":entryFee,
      "first_price": firstPrice,
      "id": id.toString(),
      "name": name,
      "number_of_teams": int.parse(noOfTeams),
      "phone_number": contactNumber,
      "status": "open",
      "registered": [],
    };
    CollectionReference collectionsReference = FirebaseFirestore.instance.collection('tournament');
    collectionsReference.doc(id.toString()).set(data);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => TournamentListPage()),
            (route) => false);
    moreService().toaster('New Tournament Successfully Added', Colors.green);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Turf Booking'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                TextField(
                  onChanged: (val){
                    name = val;
                  },
                  controller: TextEditingController(text: name.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "Tournament Name",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                ),
                SizedBox(height: 10,),
                TextField(
                  onChanged: (val){
                    noOfTeams = val;
                  },
                  controller: TextEditingController(text: noOfTeams.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "Number of Teams",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                TextField(
                  onChanged: (val){
                    firstPrice = val;
                  },
                  controller: TextEditingController(text: firstPrice.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "First Price",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                TextField(
                  onChanged: (val){
                    entryFee = val;
                  },
                  controller: TextEditingController(text: entryFee.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "Entry Fee",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                TextField(
                  onChanged: (val){
                    contactNumber = val;
                  },
                  controller: TextEditingController(text: contactNumber.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "Contact Number",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10,),
                TextField(
                  onTap: (){
                    // Select Date and Check for Available Slot
                    if(selectedDate.toString() == 'null'){
                      selectedDate = DateTime.now().add(Duration(days: 1));
                    };
                    _selectDate(context);
                    print(selectedDate.toString());
                  },
                  readOnly: true,
                  controller: TextEditingController(text: date.toString()),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 2.0),
                      ),
                      labelText: "Date of Match",
                      labelStyle: TextStyle(color: Colors.black45)
                  ),
                ),
                SizedBox(height: 10,),
                RaisedButton(
                    child: Text('Add Tournament'),
                    color: Colors.green,
                    textColor: Colors.white, // foreground
                    onPressed: () async {
                      if(name == '' || noOfTeams == '' || firstPrice == '' || entryFee == '' || contactNumber == '' || date == ''){
                        moreService().toaster('Please fill all field', Colors.red);
                      }
                      else{
                        addTournament();
                      }
                    }
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    var date1 = DateTime.now();
    selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: date1.add(Duration(days: 1)),
      lastDate: date1.add(new Duration(days: 30)),
    );
    setState(() {
      selectedDate = selectedDate;
      date = (selectedDate.day.toString() +'-'+ selectedDate.month.toString() + "-"+selectedDate.year.toString());
    });
    // setDate(displayDate);
  }
}