import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'detailed.dart';
// import 'package:url_launcher/url_launcher.dart';


class Rental extends StatefulWidget {
  Rental({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _RentalState createState() => _RentalState();
}

class _RentalState extends State<Rental> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: ListView(
        children: [
          GestureDetector(
              onTap: () => _openDestinationPage(context, 'Shoes', 'https://www.thesun.co.uk/wp-content/uploads/2018/09/NINTCHDBPICT000434934054.jpg?w=670'),
              child: _buildFeaturedItem(
                  image: 'https://www.thesun.co.uk/wp-content/uploads/2018/09/NINTCHDBPICT000434934054.jpg?w=670',
                  title: "Shoes",
                  subtitle: "Book Shoes for play")),
          GestureDetector(
              onTap: () => _openDestinationPage(context, "Jersey", 'https://s3-us-west-1.amazonaws.com/urbanpitch/wp-content/uploads/2019/05/18113917/3-mufc-home-19-20-shirt.jpg'),
              child: _buildFeaturedItem(
                  image: 'https://s3-us-west-1.amazonaws.com/urbanpitch/wp-content/uploads/2019/05/18113917/3-mufc-home-19-20-shirt.jpg',
                  title: "Jersey",
                  subtitle: "Book Jersey for play")),
          // Card(
          //   child: Image.network('https://pickvisa.com/storage/public/articles/football-shoes-waterbottle.jpg'),
          // )
        ],
      ),
    );
  }
  Container _buildFeaturedItem({String image, String title, String subtitle}) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
      child: Material(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
                    Text(title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.white))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _openDestinationPage(BuildContext context, type, image) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => DetailedPage(type, image)));
  }
}