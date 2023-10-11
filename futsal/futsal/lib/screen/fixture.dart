import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:quiver/iterables.dart';



class FixturePage extends StatefulWidget {
  FixturePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _FixturePageState createState() => _FixturePageState();
}



class _FixturePageState extends State<FixturePage> {
  var iArray = ['Team 1','Team 2','Team 3','Team 4','Team 5','Team 6'];
  var jArray = [];
  var kArray;
  var isGenerate = false;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fixture'),
        backgroundColor: Colors.green[500],
      ),
      body: ListView(
        children: [
          SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [
                Text('Select Total Team', textAlign: TextAlign.center,),
                Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: CupertinoSpinBox(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    min: 0,
                    max: 20,
                    step: 2,
                    value: iArray.length.toDouble(),
                    // direction: Axis.vertical,
                    onChanged: (value) {
                      if(value > iArray.length){
                        setState(() {
                          iArray.add('Team ${iArray.length + 1}');
                          iArray.add('Team ${iArray.length + 2}');
                        });
                      }else{
                        setState(() {
                          iArray.removeLast();
                          iArray.removeLast();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                // width: 150,
                child: RaisedButton(
                  color: Colors.green,
                  textColor: Colors.white, // foreground
                  onPressed: () {
                    setState(() {
                      isGenerate = !isGenerate;
                      var kArray = json.decode(json.encode(iArray));
                      kArray = (kArray..shuffle());
                      print(kArray);
                      print(partition(kArray, 2));
                      print(kArray);
                      this.kArray = partition(kArray, 2).toList();
                      print(this.kArray[0][0]);
                    });
                    // iArray.add('Team ${iArray.length + 1}');
                  },
                  child: !isGenerate?Text('Generate'):Text('Reset'),
                ),
              ),
            ],
          ),
          if(isGenerate)
          for(var i=0;kArray.length >i;i++)
          ListTile(
            title:
            Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'W${i+1}: ',
                      style: TextStyle(color: Colors.red[300],fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                        text: '${kArray[i][0]}',
                        style: TextStyle(color: Colors.blue[300], fontSize: 15),
                    ),
                    TextSpan(
                      text: ' VS ',
                      style: TextStyle(color: Colors.green[300],fontWeight: FontWeight.bold,fontSize: 16),
                    ),
                    TextSpan(
                      text: '${kArray[i][1]}',
                      style: TextStyle(color: Colors.blue[300], fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          ),
          if(!isGenerate)
            Wrap(
            children: [
              for(var j = 0; iArray.length > j; j++)
                Container(
                  width: MediaQuery.of(context).size.width * .5,
                  child: ListTile(
                    title: Center(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            hintText: "Team ${j+1}",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                        ),
                        onChanged: (val){
                          setState(() {
                            iArray[j] = val == ''? 'Team ${j + 1}':val;
                          });
                        },
                      )
                      // Text('WC${j}'),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}