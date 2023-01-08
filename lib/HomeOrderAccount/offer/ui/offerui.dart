import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/notification_bean.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class OfferScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OfferScreenState();
  }
}

class OfferScreenState extends State<OfferScreen> {
  List<Notificationd> notificationList = [];

  @override
  void initState() {
    setNotificationListner();
    super.initState();
    getData();
    getNotificationList();
  }
  String message = '';
  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      message = pref.getString("message")!;
    });
  }

  void setNotificationListner() async {
    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // var initializationSettingsAndroid =
    //     const AndroidInitializationSettings('logo_user');
    // var initializationSettingsIOS =  IOSInitializationSettings(
    //     onDidReceiveLocalNotification : onDidReceiveLocalNotification);
    // var initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    //     onSelectNotification: selectNotification);
    // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    // firebaseMessagingListner(firebaseMessaging);
  }

  void firebaseMessagingListner(firebaseMessaging) async {
    // firebaseMessaging.configure(
    //     onMessage: (Map<String, dynamic> message) async {
    //   print('fcm 1 ${message.toString()}');
    //   _showNotification(
    //       flutterLocalNotificationsPlugin,
    //       '${message['notification']['title']}',
    //       '${message['notification']['body']}');
    //   getNotificationList();
    // }, onResume: (Map<String, dynamic> message) async {
    //   print('fcm - 2 ${message.toString()}');
    // }, onLaunch: (Map<String, dynamic> message) async {
    //   _showNotification(
    //       flutterLocalNotificationsPlugin,
    //       '${message['notification']['title']}',
    //       '${message['notification']['body']}');
    //   print('fcm -  3 ${message.toString()}');
    // });
  }

  void getNotificationList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    var url = notificationlist;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<Notificationd> tagObjs = tagObjsJson
              .map((tagJson) => Notificationd.fromJson(tagJson))
              .toList();
          setState(() {
            notificationList.clear();
            notificationList = tagObjs;
          });
        } else {
          Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      } else {
        Toast.show('No Notification found!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      body: (notificationList != null && notificationList.length > 0)
          ? SingleChildScrollView(
              primary: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: white_color,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${notificationList[index].noti_title}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kMainTextColor),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                '${notificationList[index].noti_message}',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: kHintColor),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              (notificationList[index].image != null &&
                                      notificationList[index].image != 'N/A')
                                  ? Image.network(
                                      '${imageBaseUrl + notificationList[index].image}',
                                      height: 150,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Container(
                                      height: 0.0,
                                    )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 8,
                          color: Colors.transparent,
                        );
                      },
                      itemCount: notificationList.length)

,


                  Container(
                    margin: EdgeInsets.all(12),
                    alignment: Alignment.bottomCenter,
                    child:    Text(
                      message.toString(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    )
                    ,
                  )


                ],
              ),
            )
          : Column(
              children:[
                Text(
                'No offer available....',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    color: kMainTextColor),
              ),
          Container(
            margin: EdgeInsets.all(12),
            alignment: Alignment.bottomCenter,
            child:    Text(
              message.toString(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            )
            ,
          )
        ]

      ),
    );
  }
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {}

// Future<void> _showNotification(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//     dynamic title,
//     dynamic body) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails('7458', 'Notify', 'Notify On Shopping',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker');
//   const IOSNotificationDetails iOSPlatformChannelSpecifics =
//       IOSNotificationDetails(presentSound: false);
//   IOSNotificationDetails iosDetail = const IOSNotificationDetails(presentAlert: true);
//
//   const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, '${title}', '${body}', platformChannelSpecifics,
//       payload: 'item x');
// }

Future selectNotification(String payload) async {
  if (payload != null) {}
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  debugPrint('ob notification payload:');
  // _showNotification(
  //     flutterLocalNotificationsPlugin,
  //     '${message['notification']['title']}',
  //     '${message['notification']['body']}');
}
