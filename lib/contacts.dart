import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';

var userId = "";
List<String> contactDetails = []; //stores contact details retrieved from DB

class Contacts extends StatefulWidget {
  @override
  ContactState createState() => ContactState();
}

class ContactState extends State<Contacts> {
  List<String> temp = []; //to store splitted data of current contact

  @override
  initState() {
    super.initState();
    getUserId();
  }

  getUserId() async {
    if (userId == "") {
      userId = await _getId();
    }
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future getContacts() async {
    if (userId != "") {
      //contactDetails = [];
      var url = 'https://norgence.com/ascot/getContacts.php';
      var data = {'user_id': userId};
      var res = await http.post(url, body: data);
      var contacts = res.body.split("#");
      print(contacts);

      if (mounted && contactDetails.length == 0 && contacts[0] != "error") {
        setState(() {
          for (int i = 0; i < contacts.length - 1; i++) {
            contactDetails.add(contacts[i]);
          }
        });
      }
    } else {
      getUserId();
    }
  }

  @override
  Widget build(BuildContext context) {
    getContacts();
    if (contactDetails.length <= 0) {
      getContacts();
    }
    //adding to list for testing sake
    // contactDetails.add(
    //     'images/me.jpg|aics@ashesi.edu.gh|Not-Infected|Yakubu Bauer|2021-01-27 19:46:26|CTU');

    return Scaffold(
      appBar: AppBar(
          leading: Icon(
            Icons.people_alt,
            color: Colors.white,
            size: 35,
          ),
          title: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 35.0,
              letterSpacing: 1.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color.fromRGBO(115, 15, 15, 0.9),
          toolbarHeight: 115.0,
          shape: CustomShapeBorder(),
          actions: <Widget>[
            FlatButton(
              // color: Color.fromRGBO(115, 15, 15, 0.9),
              onPressed: () {
                contactDetails = [];
                getContacts();
              },
              child: Text("Refresh", style: TextStyle(fontSize: 20)),
              textColor: Colors.white,
            )
          ]),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              //splits list item by |
              temp = contactDetails[index].split('|');
              //create and display contact card
              return ContactCard(
                name: temp[0],
                gender: temp[1],
                phoneNumber: temp[2],
                email: temp[3],
                status: temp[4],
                profilePicture: temp[5],
                contactLocation: temp[6],
                distance: temp[7],
                contactTime: temp[8],
                frequency: temp[9],
              );
            },
            itemCount: contactDetails.length,
          ),
        ),
      ),
    );
  }
}

//formats text to be displayed when a contact is tapped
class BottomSheetText extends StatelessWidget {
  const BottomSheetText({
    this.question,
    this.result,
  });

  final String question;
  final String result;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
              text: '$question: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                  color: Color.fromRGBO(115, 15, 15, 0.9))),
          TextSpan(
            text: '$result',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}

//formats contact card based on details
class ContactCard extends StatelessWidget {
  ContactCard(
      {this.name,
      this.gender,
      this.phoneNumber,
      this.email,
      this.status,
      this.profilePicture,
      this.contactLocation,
      this.distance,
      this.contactTime,
      this.frequency});

  final String name;
  final String gender;
  final String phoneNumber;
  final String email;
  final String status;
  final String profilePicture;
  final String contactLocation;
  final String distance;
  final String contactTime;
  final String frequency;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(profilePicture),
        ),
        trailing: Icon(Icons.more_horiz),
        title: Text(
          name,
          style: TextStyle(
            color: Color.fromRGBO(115, 15, 15, 0.9),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          status,
          textScaleFactor: 2,
        ),
        onTap: () => showModalBottomSheet<dynamic>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            context: context,
            builder: (builder) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
                child: Wrap(
                  children: <Widget>[
                    BottomSheetText(question: ' Name', result: name),
                    SizedBox(height: 5.0),
                    BottomSheetText(question: ' Gender', result: gender),
                    SizedBox(height: 5.0),
                    BottomSheetText(
                        question: ' Phone number', result: phoneNumber),
                    SizedBox(height: 5.0),
                    BottomSheetText(question: ' Email', result: email),
                    SizedBox(height: 5.0),
                    BottomSheetText(question: ' Status', result: status),
                    SizedBox(height: 5.0),
                    BottomSheetText(
                        question: ' Contact frequency ', result: frequency),
                    SizedBox(height: 5.0),
                    BottomSheetText(
                        question: ' Last contact location',
                        result: contactLocation),
                    SizedBox(height: 5.0),
                    BottomSheetText(
                        question: ' Last contact distance', result: distance),
                    SizedBox(height: 5.0),
                    BottomSheetText(
                        question: ' Last contact time', result: contactTime),
                    SizedBox(height: 5.0),
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path path = Path();
    path.lineTo(0, rect.height - 30);
    path.quadraticBezierTo(
        rect.width / 2, rect.height, rect.width, rect.height - 30);
    path.lineTo(rect.width, 0);
    path.close();

    return path;
  }
}
