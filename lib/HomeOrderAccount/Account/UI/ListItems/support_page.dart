import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/entry_field.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';

class SupportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SupportPageState();
  }
}

class SupportPageState extends State<SupportPage> {
  static const String id = 'support_page';
  var number = '';
  dynamic userIds;
  bool _inProgress = false;
  var messageController = TextEditingController();
  var numberController = TextEditingController();
  int number_limit = 0;

  @override
  void initState() {
    super.initState();
    getPrefValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('Support', style: Theme.of(context).textTheme.bodyText1),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: kCardBackgroundColor,
                child: Image(
                  image: AssetImage("images/logos/logo_user.png"),
                  centerSlice: Rect.largest,
                  fit: BoxFit.fill,
                  height: 220,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 16.0),
                      child: Text(
                        'Or Write us your queries',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                      child: Text(
                        'Your words means a lot to us.',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(12),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: numberController,
                        maxLength: number_limit,
                        maxLines: 1,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color:kMainColor, width: 1),
                            ),
                            label: Text("PHONE NUMBER")),

                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: messageController,
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color:kMainColor, width: 1),
                            ),
                            label: Text('YOUR MESSAGE'),
                            hintText: 'Enter your message here'),

                      ),
                    ),
                    // EntryField(
                    //   image: 'images/icons/ic_mail.png',
                    //   label: 'YOUR MESSAGE',
                    //   hint: 'Enter your message here',
                    //   controller: messageController,
                    //   maxLines: 5,
                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: _inProgress
                          ? Container(
                              alignment: Alignment.center,
                              height: 50.0,
                              child: Platform.isIOS
                                  ? new CupertinoActivityIndicator()
                                  : new CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kMainColor,
                            foregroundColor : kMainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            primary: Colors.purple,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            textStyle:TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400)),

                        child: Text(
                                'Submit',
                                style: TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              ),

                              onPressed: () {
                                setState(() {
                                  _inProgress = true;
                                });
                                handleSubmit();
                              },
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getPrefValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? user_phone = prefs.getString('user_phone');
    setState(() {
      number_limit = prefs.getInt('number_limit')!;
      number_limit = number_limit+(user_phone!.length);
      userIds = userId;
      number = user_phone;
      numberController.text = user_phone;
    });
  }

  void handleSubmit() {
    if (numberController.text.length > 9 &&
        messageController.text.length > 50) {
      var url = support;
      var client = http.Client();
      Uri myUri = Uri.parse(url);

      client.post(myUri, body: {
        'user_id': '${userIds}',
        'user_number': '${numberController.text}',
        'message': '${messageController.text}',
      }).then((value) {
        if (value.statusCode == 200) {
          var jsonData = jsonDecode(value.body);
          if (jsonData['status'] == "1") {
            setState(() {
              _inProgress = false;
              messageController.clear();
              Navigator.pop(context);
              Toast.show("Submitted", duration: Toast.lengthShort, gravity:  Toast.bottom);
            });
          } else {
            setState(() {
              _inProgress = false;
              Toast.show('Please try again!', duration: Toast.lengthShort, gravity:  Toast.bottom);
            });
          }
        } else {
          setState(() {
            _inProgress = false;
            Toast.show('Please try again!', duration: Toast.lengthShort, gravity:  Toast.bottom);
          });
        }
      }).catchError((e) {
        setState(() {
          _inProgress = false;
        });
      });
    } else {
      setState(() {
        _inProgress = false;
      });
      Toast.show(
          'Please enter valid mobile no. and message is not less then 100 words',
          duration: Toast.lengthShort, gravity:  Toast.bottom);
    }
  }
}
