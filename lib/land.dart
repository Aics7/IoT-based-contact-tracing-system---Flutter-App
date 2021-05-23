import 'package:ashesi_contact_tracing/announcements.dart';
import 'package:ashesi_contact_tracing/contacts.dart';
import 'package:ashesi_contact_tracing/home.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Land extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ashesi Contact Tracing',
      theme: ThemeData.light(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  //variables to add screen selection from bottom navigation
  int selectedPage = 0;
  final _pageOptions = [Homepage(), Contacts(), Announcement()];

  //creating and listening to bottom navigation icons
  @override
  Widget build(BuildContext context) {
    //for notifications
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pageOptions[selectedPage],
      bottomNavigationBar: CurvedNavigationBar(
        color: Color.fromRGBO(115, 15, 15, 0.9),
        backgroundColor: Colors.white,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.group,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.announcement,
            size: 30,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedPage = index;
          });
        },
      ),
    );
  }
}
