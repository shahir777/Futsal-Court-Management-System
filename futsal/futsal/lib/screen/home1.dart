import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:futsal/screen/tournament_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Booking.dart';
import 'fixture.dart';
import 'login.dart';

class Home1Page extends StatefulWidget {
  Home1Page({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _Home1PageState createState() => _Home1PageState();
}



class _Home1PageState extends State<Home1Page> {


  var item = [];

  final List categories = [
    {"id":"1","name":"Book Your Turf", "icon":Icons.event},
    {"id":"2","name":"Book a Tournament", "icon":Icons.event_available},
    {"id":"3","name":"Fixture Generator", "icon":Icons.list},
    {"id":"4","name":"Logout", "icon":Icons.power_settings_new},
  ];
  var isScoreAvailable = false;
  var scoreCard = [];
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    getData();
  }

  getScore() async{
    // await Firebase.initializeApp();
    // Get Score Card Details
    FirebaseFirestore.instance.collection('settings').doc('score_card').snapshots().listen((event) {
      print('score_card');
      setState(() {
        var item = event.data();
        isScoreAvailable = item['isAvailable'];
        scoreCard = item['match'];
        print(item);
      });
    });
  }

  // Get Time/Rate Details
  getData() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection('futsal_time').snapshots().listen((event) {
      print('event');
      setState(() {
        item = event.docs.first.data()['time'];
        print(item[0]);
      });
    });
    getScore();
  }

  final TextStyle stats = TextStyle(
      fontWeight: FontWeight.bold, fontSize: 15.0, color: Colors.white);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ProfileHeader(
                avatar: NetworkImage('https://i2-prod.football.london/incoming/article17909924.ece/ALTERNATES/s810/0_GettyImages-1210995196.jpg'),
                coverImage: NetworkImage('https://images.financialexpress.com/2020/11/football.jpg'),
                title: "Hilltop Arena",
                subtitle: "Kasaragod",

              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  if(isScoreAvailable)
                    Container(
                    width: MediaQuery.of(context).size.width * .9,
                    // height: 70,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Live Score Card',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: Text(scoreCard[0]['team'], textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                            Expanded(child: Text('VS', textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                            Expanded(child: Text(scoreCard[1]['team'], textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: Text(scoreCard[0]['score'], textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                            Expanded(child: Text(':', textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                            Expanded(child: Text(scoreCard[1]['score'], textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),)),
                          ],
                        ),
                        const SizedBox(height: 15.0),
                      ],
                    ),
                  ),
                  if(isScoreAvailable)
                    SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.27,
                        height: 70,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lightGreen,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              item.isEmpty?'':'₹'+item[0]['cost'],
                              style: stats,
                            ),
                            const SizedBox(height: 5.0),
                            Text(item.isEmpty?'':item[0]['time'])
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.27,
                        height: 70,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lightGreen,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              item.isEmpty?'':'₹'+item[1]['cost'],
                              style: stats,
                            ),
                            const SizedBox(height: 5.0),
                            Text(item.isEmpty?'':item[1]['time'])
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.27,
                        height: 70,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.lightGreen,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              item.isEmpty?'':'₹'+item[2]['cost'],
                              style: stats,
                            ),
                            const SizedBox(height: 5.0),
                            Text(item.isEmpty?'':item[2]['time'])
                          ],
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 30,),
                ],
              ),
              Container(
                height: 400,
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0
                          ),
                          delegate: SliverChildBuilderDelegate(
                            _buildCategoryItem,
                            childCount: categories.length,

                          )

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    // var category = categories[index];
    return MaterialButton(
      elevation: 1.0,
      highlightElevation: 1.0,

      onPressed: () async {
        if(categories[index]['id'] == '1'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookingPage()));
        }
        if(categories[index]['id'] == '2'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TournamentListPage()));
        }
        if(categories[index]['id'] == '3'){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FixturePage()));
        }
        if(categories[index]['id'] == '4'){
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => LoginPage(title: '')),
                  (route) => false);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.green,
      textColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(categories[index]['icon'], size: 50,),
          SizedBox(height: 5.0),
          Text(
            categories[index]['name'],
            textAlign: TextAlign.center,
            maxLines: 3,),
        ],
      ),
    );
  }

}



class ProfileHeader extends StatelessWidget {
  final ImageProvider<dynamic> coverImage;
  final ImageProvider<dynamic> avatar;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const ProfileHeader(
      {Key key,
        @required this.coverImage,
        @required this.avatar,
        @required this.title,
        this.subtitle,
        this.actions})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Ink(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(image: coverImage, fit: BoxFit.cover),
          ),
        ),
        Ink(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black38,
          ),
        ),
        if (actions != null)
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.only(bottom: 0.0, right: 0.0),
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 160),
          child: Column(
            children: <Widget>[
              Avatar(
                image: avatar,
                radius: 40,
                backgroundColor: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 4.0,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.title,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ]
            ],
          ),
        )
      ],
    );
  }
}


class Avatar extends StatelessWidget {
  final ImageProvider<dynamic> image;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final double borderWidth;

  const Avatar(
      {Key key,
        @required this.image,
        this.borderColor = Colors.grey,
        this.backgroundColor,
        this.radius = 30,
        this.borderWidth = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius + borderWidth,
      backgroundColor: borderColor,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor != null
            ? backgroundColor
            : Theme.of(context).primaryColor,
        child: CircleAvatar(
          radius: radius - borderWidth,
          backgroundImage: image,
        ),
      ),
    );
  }
}