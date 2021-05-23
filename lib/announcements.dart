import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'dart:io';

var userId = "";
List<String> notifications = [];
int notificationCount = 0;

class Announcement extends StatefulWidget {
  @override
  AnnouncementState createState() => AnnouncementState();
}

class AnnouncementState extends State<Announcement> {
  VoiceController _voiceController;

  @override
  initState() {
    _voiceController = FlutterTextToSpeech.instance.voiceController();
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

  Future getAnnouncements() async {
    if (userId != "") {
      //contactDetails = [];
      var url = 'https://norgence.com/ascot/getAnnouncements.php';
      var data = {'user_id': userId};
      var res = await http.post(url, body: data);
      var announcements = res.body.split("#");
      //print(announcements);

      if (mounted && notifications.length == 0 && announcements[0] != "error") {
        setState(() {
          for (int i = 0; i < announcements.length - 1; i++) {
            notifications.add(announcements[i]);
          }
        });
      }
    } else {
      getUserId();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _voiceController.stop();
  }

  _stopVoice() {
    _voiceController.stop();
  }

  @override
  Widget build(BuildContext context) {
    getAnnouncements();
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color.fromRGBO(166, 66, 66, 0.9),
              ledColor: Colors.white)
        ]);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    if (notificationCount < notifications.length) {
      notificationCount = notifications.length;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: notifications[notificationCount - 1].split('|')[0],
              body: notifications[notificationCount - 1].split('|')[1]));
    }

    return Scaffold(
      appBar: AppBar(
          leading: Icon(
            Icons.notifications,
            color: Colors.white,
            size: 35,
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 35.0,
              letterSpacing: 1.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Color.fromRGBO(115, 15, 15, 0.9),
          toolbarHeight: 100.0,
          shape: CustomShapeBorder(),
          actions: <Widget>[
            FlatButton(
              // color: Color.fromRGBO(115, 15, 15, 0.9),
              onPressed: () {
                notifications = [];
                notificationCount = 0;
                getAnnouncements();
              },
              child: Text("Refresh", style: TextStyle(fontSize: 20)),
              textColor: Colors.white,
            )
          ]),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.0),
          child: ListView.builder(
            itemBuilder: (context, index) {
              //splits list item by |
              return Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: ListTile(
                    leading: Icon(Icons.bubble_chart),
                    trailing: Icon(Icons.volume_up),
                    title: Text(
                      notifications[index].split('|')[0],
                      style: TextStyle(
                        color: Color.fromRGBO(115, 15, 15, 0.9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notifications[index].split('|')[1]),
                    onTap: () {
                      setState(() {
                        _voiceController.init().then((_) {
                          _voiceController.speak(
                            notifications[index].split('|')[1],
                            VoiceControllerOptions(),
                          );
                        });
                      });
                    },
                  ));
            },
            itemCount: notifications.length,
          ),
        ),
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
