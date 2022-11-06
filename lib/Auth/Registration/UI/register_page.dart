import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/entry_field.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';

import '../../login_navigator.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kMainTextColor),
        title: Text(
          'Sign Up',
          style: TextStyle(
              fontSize: 18, color: kMainTextColor, fontWeight: FontWeight.w600),
        ),
      ),
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referalController = TextEditingController();
  var fullNameError = "";

  bool showDialogBox = false;
  dynamic token = '';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
   // firebaseMessagingListner();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Divider(
          color: kCardBackgroundColor,
          thickness: 8.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 10.0,
                left: 2.0,
                right: 2.0,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Create New Account',
                            style: TextStyle(
                                color: kMainTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 25),
                          )),
    Padding(
      padding: EdgeInsets.all(12),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    borderSide: BorderSide(color:kMainColor, width: 1),
                                  ),
                              hintText: "Name"),

                      ),
    ),
            Padding(
              padding: EdgeInsets.all(12),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color:kMainColor, width: 1),
                            ),
                            hintText: "Email Address"),

                      ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: _referalController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              borderSide: BorderSide(color:kMainColor, width: 1),
                            ),
                            hintText: "Apply Referral Code (Optional)"),

                      ),
            ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "By siging up you accept the",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: kMainTextColor,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w500,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                      ' Terms of service and Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: appbar_color,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w500,
                                      ))
                                ])),
                      ),
                      SizedBox(height: 10.0),
                      Visibility(
                          visible: showDialogBox,
                          child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 20,
                right: 20.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showDialogBox = true;
                    });
                    if (_nameController.text.isEmpty) {
                      Toast.show("Enter your full name",duration: Toast.lengthShort, gravity:  Toast.bottom);
                      setState(() {
                        showDialogBox = false;
                      });
                    } else if (_emailController.text.isEmpty ||
                        !_emailController.text.contains('@') ||
                        !_emailController.text.contains('.')) {
                      setState(() {
                        showDialogBox = false;
                      });
                      Toast.show("Enter valied Email address!",duration: Toast.lengthShort, gravity:  Toast.bottom);
                    } else {
                      Navigator.pushNamed(context, LoginRoutes.verification);

                      hitService(_nameController.text, _emailController.text,
                          _referalController.text, context);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: kMainColor),
                    child: Text(
                      'Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  void hitService(
      String name, String email, String referal, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (token != null && token.toString().length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phoneNumber = prefs.getString('user_phone');
      String url = registerApi;
      Uri myUri = Uri.parse(url);
      http.post(myUri, body: {
        'user_name': name,
        'user_email': email,
        'user_phone': phoneNumber,
        'user_password': 'no',
        'device_id': '${token}',
        'user_image': 'usre.png'
      }).then((value) {
        print('Response Body: - ${value.body.toString()}');
        print('Response Body: - ${value.statusCode.toString()}');
        if (value.statusCode == 200) {
          setState(() {
            showDialogBox = false;
          });

          Navigator.pushNamed(context, LoginRoutes.verification);
        }
      });
    } else {
      firebaseMessaging.getToken().then((value) {
        setState(() {
          token = value;
        });
        print('${value}');
        hitService(name, email, referal, context);
       //// Navigator.pushNamed(context, LoginRoutes.verification);

      });

    }
  }

  void firebaseMessagingListner() async {
    if (Platform.isIOS) iosPermission();
    firebaseMessaging.getToken().then((value) {
      setState(() {
        token = value;
      });
    });
  }

  void iosPermission() {
    // firebaseMessaging.requestNotificationPermissions(
    //     IosNotificationSettings(sound: true, badge: true, alert: true));
    // firebaseMessaging.onIosSettingsRegistered.listen((event) {});
  }

}
