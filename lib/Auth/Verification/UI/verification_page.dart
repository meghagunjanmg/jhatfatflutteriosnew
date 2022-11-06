import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/currencybean.dart';

import '../../../Routes/routes.dart';

class VerificationPage extends StatelessWidget {
  final VoidCallback onVerificationDone;

  VerificationPage(this.onVerificationDone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Verification',
          style: headingStyle,
        ),
      ),
      body: OtpVerify(onVerificationDone),
    );
  }
}

//otp verification class
class OtpVerify extends StatefulWidget {
  final VoidCallback onVerificationDone;

  OtpVerify(this.onVerificationDone);

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController _controller = TextEditingController();
  late FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  late String phoneNo;
  late String smsOTP="";
  String verificationId="";
  String errorMessage = '';
  String contact = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Timer _timer;

  @override
  void initState() {
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      token = value;
    });


    super.initState();
    getd();


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void getd() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    contact = pref.getString("user_phone")!;

    print(contact);

    generateOtp('+91$contact');
  }
  @override
  Widget build(BuildContext context) {
//    MobileNumberArg mobileNumberArg = ModalRoute.of(context).settings.arguments;

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 5, right: 80, left: 80),
                      child: Center(
                        child: Text(
                          'Verify your phone number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kMainTextColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "Enter your otp code here.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.copyWith(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          PinCodeTextField(
                            autofocus: false,
                            controller: _controller,
                            hideCharacter: false,
                            highlight: true,
                            highlightColor: kHintColor,
                            defaultBorderColor: kMainColor,
                            hasTextBorderColor: kMainColor,
                            maxLength: 6,
                            pinBoxRadius: 20,
                            onDone: (text) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              verificaitonPin = text;
                              smsOTP = text as String;
                            },
                            pinBoxWidth: 40,
                            pinBoxHeight: 40,
                            hasUnderline: false,
                            wrapAlignment: WrapAlignment.spaceAround,
                            pinBoxDecoration: ProvidedPinBoxDecoration
                                .roundedPinBoxDecoration,
                            pinTextStyle: TextStyle(fontSize: 22.0),
                            pinTextAnimatedSwitcherTransition:
                                ProvidedPinBoxTextAnimation.scalingTransition,
                            pinTextAnimatedSwitcherDuration:
                                Duration(milliseconds: 300),
                            highlightAnimationBeginColor: Colors.black,
                            highlightAnimationEndColor: Colors.white12,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15.0),
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Didn't you receive any code?",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 10.0),
                      InkWell(
                        onTap: () {
                          generateOtp('+91$contact');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Resend Code"),
                        ),
                      ),
                          const SizedBox(height: 10.0),

                          Visibility(
                              visible: showDialogBox,
                              child: const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                )),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20.0,
              child: InkWell(
                onTap: () {
                  if (!showDialogBox) {
                    setState(() {
                      showDialogBox = true;
                    });
                  }
                  /////hitService("123456", context);

                  verifyOtp();
                  },
                child: Container(
                  alignment: Alignment.center,
                  height: 52,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: kMainColor),

                  child: Text(
                    'Verify',
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
      ),
    );
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    if (token != null && token.toString().length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String url = verifyPhone;
      Uri myUri = Uri.parse(url);
      await http.post(myUri, body: {
        'phone': prefs.getString('user_phone'),
        'otp': verificaitonPin,
        'device_id': '${token}'
      }).then((response) {
        print('Response Body: *-*- ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body: *-*- ${response.body}');
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 1) {
            var userId = int.parse('${jsonData['data']['user_id']}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", jsonData['data']['user_name']);
            prefs.setString("user_email", jsonData['data']['user_email']);
            prefs.setString("user_image", jsonData['data']['user_image']);
            prefs.setString("user_phone", jsonData['data']['user_phone']);
            prefs.setString("user_password", jsonData['data']['user_password']);
            prefs.setString("id_proof", (jsonData['data']['id_proof']));

            prefs.setString(
                "wallet_credits", jsonData['data']['wallet_credits'].toString());
            prefs.setString("first_recharge_coupon",
                jsonData['data']['first_recharge_coupon'].toString());
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString("refferal_code", jsonData['data']['referral_code'].toString());
            if (jsonData['currency'] != null) {
              CurrencyData currencyData =
                  CurrencyData.fromJson(jsonData['currency']);
              print('${currencyData.toString()}');
              prefs.setString("curency", '${currencyData.currency_sign}');
            }
           ///// widget.onVerificationDone();

            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            widget.onVerificationDone();

          } else {
            prefs.setBool("phoneverifed", false);
            prefs.setBool("islogin", false);
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      }).catchError((e) {
        print(e);
        setState(() {
          showDialogBox = false;
        });
      });
    } else {
      messaging.getToken().then((value) {
        token = value;
           hitService(verificaitonPin, context);
      });
    }
  }


  //Method for generate otp from firebase
  Future<void> generateOtp(String contact) async {
    var smsOTPSent = (String verId, [int? forceCodeResend]) {
      verificationId = verId;
      print("** "+verificationId);
    };
    try {
      _auth.verifyPhoneNumber(
          phoneNumber: contact,
          codeAutoRetrievalTimeout: (String verId) {
            verificationId = verId;
          },
          codeSent: smsOTPSent,
          timeout: const Duration(seconds: 120),
          verificationCompleted: (AuthCredential phoneAuthCredential) {

          },
          verificationFailed: (Exception exception) {
            print("ERROR  "+exception.toString());
            handleError(exception);
            // Navigator.pop(context, exception.message);
          });

    } catch (e) {
      // Navigator.pop(context, (e as PlatformException).message);
    }
  }

  //Method for verify otp entered by user
  Future<void> verifyOtp() async {
    if (smsOTP == null || smsOTP == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      print("ERROR**  "+credential.toString());

      _auth.signInWithCredential(credential);

      print(smsOTP);
      hitService(smsOTP, context);

    } catch (e) {
      print("ERROR***  "+ e.toString());
      handleError(e);
    }
  }

  //Method for handle the errors
  void handleError(error) {
     FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = error.toString();
        });
        showAlertDialog(context, 'Something went wrong');
  }

  //Basic alert dialogue for alert errors and confirmations
  void showAlertDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop("Discard");
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
