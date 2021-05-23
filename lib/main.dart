import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ashesi_contact_tracing/pallete.dart';
import 'package:ashesi_contact_tracing/widgets/background-image.dart';
import 'package:ashesi_contact_tracing/land.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/geolocation.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:location_permissions/location_permissions.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';

void main() => runApp(new MyApp());

var userId = "";
var firstName = "";
var lastName = "";
var gender = "";
var phoneNumber = "";
var email = "";
var profilePicture = "";
String lat = "", long = "";
var signUpResult = "";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ashesi Contact Tracing',
      //theme: ThemeData.light(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  LocationResult location;
  StreamSubscription<LocationResult> streamSubscription;
  bool trackLocation = false;

  @override
  initState() {
    super.initState();
    getUserId();
    checkGps();
    getLocations();
    checkUser();
  }

  getUserId() async {
    if (userId == "") {
      userId = await _getId();
    }
    checkUser();
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

        lat = "${result.location.latitude}";
        long = "${result.location.longitude}";
      });
    } else {
      Fluttertoast.showToast(
          msg: 'Please turn on device location and allow permission',
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
      //print("Success");
    } else {
      print("Failed");
    }
  }

  Future checkUser() async {
    if (userId != "") {
      var url = 'https://norgence.com/ascot/checkUser.php';
      var data = {'user_id': userId};
      var res = await http.post(url, body: data);
      print(res.body);
      if (res.body == "exists") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Land()),
        );
      }
    } else {
      getUserId();
    }
  }

  Future signUp() async {
    if (userId != "") {
      var url = 'https://norgence.com/ascot/signUp.php';
      var data = {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'phone_number': phoneNumber,
        'email': email,
        'profile_picture': profilePicture,
        'latitude': lat,
        'longitude': long
      };
      var res = await http.post(url, body: data);
      signUpResult = res.body;
    } else {
      getUserId();
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

  final fnController = TextEditingController();
  final lnController = TextEditingController();
  final gController = TextEditingController();
  final pnController = TextEditingController();
  final eController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fnController.dispose();
    lnController.dispose();
    gController.dispose();
    pnController.dispose();
    eController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lat == "" || long == "") {
      getLocations();
    }

    if (userId == "") {
      getUserId();
    }
    checkUser();

    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackgroundImage(image: 'images/register_bg.png'),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.width * 0.1,
                ),
                Stack(
                  children: [
                    Center(
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: CircleAvatar(
                            radius: size.width * 0.14,
                            backgroundColor: Colors.grey[400].withOpacity(
                              0.4,
                            ),
                            child: Icon(
                              FontAwesomeIcons.user,
                              color: kWhite,
                              size: size.width * 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.08,
                      left: size.width * 0.56,
                      child: Container(
                        height: size.width * 0.1,
                        width: size.width * 0.1,
                        decoration: BoxDecoration(
                          color: kBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: kWhite, width: 2),
                        ),
                        child: Icon(
                          FontAwesomeIcons.arrowUp,
                          color: kWhite,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.width * 0.1,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 70.0,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[900].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TextField(
                            controller: fnController,
                            //maxLength: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  size: 28,
                                  color: kWhite,
                                ),
                              ),
                              hintText: 'First Name',
                              hintStyle: kBodyText,
                            ),
                            style: kBodyText,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 70.0,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[900].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TextField(
                            controller: lnController,
                            //maxLength: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  size: 28,
                                  color: kWhite,
                                ),
                              ),
                              hintText: 'Last Name',
                              hintStyle: kBodyText,
                            ),
                            style: kBodyText,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 70.0,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[900].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TextField(
                            controller: gController,
                            //maxLength: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.transgender,
                                  size: 28,
                                  color: kWhite,
                                ),
                              ),
                              hintText: 'Gender',
                              hintStyle: kBodyText,
                            ),
                            style: kBodyText,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 70.0,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[900].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TextField(
                            controller: pnController,
                            maxLength: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.phone,
                                  size: 28,
                                  color: kWhite,
                                ),
                              ),
                              hintText: 'Phone Number',
                              hintStyle: kBodyText,
                            ),
                            style: kBodyText,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Container(
                        height: 70.0,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.grey[900].withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: TextField(
                            controller: eController,
                            //maxLength: 10,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.envelope,
                                  size: 28,
                                  color: kWhite,
                                ),
                              ),
                              hintText: 'Email',
                              hintStyle: kBodyText,
                            ),
                            style: kBodyText,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Color.fromRGBO(115, 15, 15, 0.9))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(children: [
                            Text(
                              '\nUSER AGREEMENT\n',
                              style: kBodyText,
                              textAlign: TextAlign.center,
                            ),
                          ]),
                          Text(
                            'This is Ashesi\'s contact tracing System. This Application is mandated to be used by Ashesi\'s board of directors, Faculty (permanent and adjunct), Staff, Students, temporary workers, guests, and all persons with access to Ashesi\'s campus. This agreement must be accepted before you will be granted access to Ashesi\'s campus and campus resources. By downloading the Ashesi Contact Tracing application, installing and clicking on the sign up button, you consent to sharing:',
                            style: kBodyText,
                            textAlign: TextAlign.left,
                          ),
                          Row(children: [
                            Text(
                              '\n⦁ Your device\'s unique ID',
                              style: kBodyText,
                              textAlign: TextAlign.left,
                            ),
                          ]),
                          Row(children: [
                            Text(
                              '\n⦁ Registration details (for this Application)',
                              style: kBodyText,
                              textAlign: TextAlign.left,
                            ),
                          ]),
                          Row(children: [
                            Text(
                              '\n⦁ GPS location',
                              style: kBodyText,
                              textAlign: TextAlign.left,
                            ),
                          ]),
                          Row(children: [
                            Text(
                              '\n⦁ Bluetooth',
                              style: kBodyText,
                              textAlign: TextAlign.left,
                            ),
                          ]),
                          Row(children: [
                            Text(
                              '\n⦁ Internet bandwidth',
                              style: kBodyText,
                              textAlign: TextAlign.left,
                            ),
                          ]),
                          Text(
                              '\nThis application will periodically send data from your device to a central server for analysis to aid in contact tracing should a contagious infection be recorded on campus. You also agree that, data gathered from this application can be shared with internal offices/departments in Ashesi such as the Health Centre and can be the basis for making health recommendations such as testing for a particular infection and quarantining/isolation. If you agree to these terms, please click on the "agree" button to continue.',
                              style: kBodyText,
                              textAlign: TextAlign.left),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 70.0,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kBlue,
                      ),
                      child: FlatButton(
                        onPressed: () {
                          firstName = fnController.text;
                          lastName = lnController.text;
                          gender = gController.text.toLowerCase();
                          phoneNumber = pnController.text;
                          email = eController.text;

                          if (firstName == "" ||
                              lastName == "" ||
                              gender == "" ||
                              phoneNumber == "" ||
                              email == "") {
                            //toast that some fields are empty.
                            //print("some fields are empty");
                            Fluttertoast.showToast(
                                msg: 'some fields are empty',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));
                          } else if (gender != "male" && gender != "female") {
                            //toast that gender should either be 'male' or 'female'
                            //print("Gender should either be \'male\' or \'female\'");
                            Fluttertoast.showToast(
                                msg:
                                    'Gender should either be \'male\' or \'female\'',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));
                          } else if (phoneNumber.length < 10) {
                            //toast that phone number must be 10 digits
                            //print("phone number must be 10 digits");
                            Fluttertoast.showToast(
                                msg: 'Phone number must be 10 digits',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));
                          } else if (userId == "") {
                            //toast that trying to get device ID
                            //print("trying to get device ID");
                            Fluttertoast.showToast(
                                msg: 'Trying to get device ID',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));

                            getUserId();
                          } else if (lat == "" || long == "") {
                            //toast that trying to get device location
                            //print("trying to get device location");
                            Fluttertoast.showToast(
                                msg: 'Trying to get device location',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));

                            getLocations();
                          } else {
                            if (gender == "male") {
                              profilePicture = "images/male.jpg";
                            } else if (gender == "female") {
                              profilePicture = "images/female.jpg";
                            }
                            //push data to database
                            signUp();
                          }
                          if (signUpResult == "success") {
                            //toast that sign up successful
                            //print("sign up successful");
                            Fluttertoast.showToast(
                                msg: 'Sign up successful',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Land()),
                            );
                          } else {
                            //toast that sign up unsuccessful. Try again.
                            //print("sign up unsuccessful. Try again");
                            Fluttertoast.showToast(
                                msg: 'Sign up unsuccessful. Try again',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 24,
                                timeInSecForIos: 1,
                                backgroundColor: Colors.grey[300],
                                textColor: Color.fromRGBO(115, 15, 15, 0.9));
                          }
                          print(signUpResult);
                        },
                        child: Text(
                          'Sign Up',
                          style:
                              kBodyText.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
