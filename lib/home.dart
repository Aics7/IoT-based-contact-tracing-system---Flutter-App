import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/geolocation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';

var userId = "";
List<String> profileDetails = ["-", "-", "-", "-", "-", "images/male.jpg"];

class Homepage extends StatefulWidget {
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  //list to save location details
  String lat = '0.0', long = '0.0';
  LocationResult location;
  StreamSubscription<LocationResult> streamSubscription;
  bool trackLocation = false;

  @override
  initState() {
    super.initState();
    getUserId();
    checkGps();
  }

  getUserId() async {
    if (userId == "") {
      userId = await _getId();
    }
  }

//gets current location from gps
  getLocations() async {
    final GeolocationResult result = await Geolocation.isLocationOperational();
    if (result.isSuccessful) {
      streamSubscription = Geolocation.locationUpdates(
        accuracy: LocationAccuracy.best,
        displacementFilter: 0.0,
        inBackground: true,
      ).listen((result) {
        location = result;
        if (mounted) {
          setState(() {
            lat = "${result.location.latitude}";
            long = "${result.location.longitude}";
          });
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Please turn on device location!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 24,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey[300],
          textColor: Color.fromRGBO(115, 15, 15, 0.9));
    }
  }

  checkGps() async {
    PermissionStatus permission =
        await LocationPermissions().requestPermissions();
    final GeolocationResult result = await Geolocation.isLocationOperational();
    if (result.isSuccessful) {
      print("Success");
    } else {
      print("Failed");
    }
  }

  Future sendLocation() async {
    if (userId != "") {
      var url = 'https://norgence.com/ascot/updateLocation.php';
      var data = {'user_id': userId, 'latitude': lat, 'longitude': long};
      var res = await http.post(url, body: data);
      print(res.body);
    } else {
      getUserId();
    }

    // if (res.statusCode == 200) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: new Text("Done"),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: new Text("OK"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
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

  Future getProfile() async {
    if (userId != "") {
      //contactDetails = [];
      var url = 'https://norgence.com/ascot/getProfile.php';
      var data = {'user_id': userId};
      var res = await http.post(url, body: data);
      var profile = res.body.split("|");
      if (profile.length >= 6) {
        for (int i = 0; i < 6; i++) {
          profileDetails[i] = profile[i];
        }
      }

      //print(profile);
      if (mounted) {
        setState(() {});
      }
    } else {
      getUserId();
    }
  }

  @override
  Widget build(BuildContext context) {
    //getLocations();
    //print(profileDetails);
    if (lat == '0.0' || long == '0.0') {
      getLocations();
    }
    if (lat != '0.0' && long != '0.0') {
      sendLocation();
    }
    if (profileDetails[0] == "-") {
      getProfile();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: const Color.fromRGBO(115, 15, 15, 0.9),
            leading: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            actions: <Widget>[
              FlatButton(
                // color: Color.fromRGBO(115, 15, 15, 0.9),
                onPressed: () {
                  profileDetails = ["-", "-", "-", "-", "-", "images/male.jpg"];
                  getProfile();
                },
                child: Text("Refresh", style: TextStyle(fontSize: 20)),
                textColor: Colors.white,
              )
            ]),
        body: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              painter: HeaderCurvedContainer(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 35.0,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage(profileDetails[5]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      profileDetails[4],
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color.fromRGBO(115, 15, 15, 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(top: 25),
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              ProfileInfoBigCard(
                                firstText: profileDetails[0],
                                secondText: "Risk Index",
                                icon: Icon(
                                  Icons.warning_rounded,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                              ProfileInfoBigCard(
                                firstText: profileDetails[1],
                                secondText: "Status",
                                icon: Icon(
                                  Icons.attribution_rounded,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              ProfileInfoBigCard(
                                firstText: profileDetails[2],
                                secondText: "Un-infected Contacts",
                                icon: Icon(
                                  Icons.account_tree_outlined,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                              ProfileInfoBigCard(
                                firstText: profileDetails[3],
                                secondText: "Infected contacts",
                                icon: Icon(
                                  Icons.account_tree_sharp,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              ProfileInfoBigCard(
                                firstText: lat,
                                secondText: "Latitude",
                                icon: Icon(
                                  Icons.location_on,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                              ProfileInfoBigCard(
                                firstText: long,
                                secondText: "Longitude",
                                icon: Icon(
                                  Icons.location_on,
                                  size: 32,
                                  color: Color.fromRGBO(115, 15, 15, 0.9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter class to for the header curved-container
class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color.fromRGBO(115, 15, 15, 0.9);
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 250.0, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ProfileInfoBigCard extends StatelessWidget {
  final String firstText, secondText;
  final Widget icon;

  const ProfileInfoBigCard(
      {Key key,
      @required this.firstText,
      @required this.secondText,
      @required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 16,
          bottom: 24,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: icon,
            ),
            Text(secondText,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Color(0xFF8391A0),
                  fontWeight: FontWeight.w300,
                )),
            Text(firstText,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Color(0xFF1A1316),
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
