import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Auth/login_navigator.dart';
import 'package:jhatfat/Locale/locales.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';

class PhoneNumber_New extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneNumber(),
    );
  }
}

class PhoneNumber extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhoneNumberState();
  }
}

class PhoneNumberState extends State<PhoneNumber> {
  static const String id = 'phone_number';
  final TextEditingController _controller = TextEditingController();
  String isoCode = '+91';
int numberLimit = 10;
  var showDialogBox = false;

  @override
  void initState() {
    super.initState();
    getCountryCode();
  }

  void getCountryCode() async{
    setState(() {
      showDialogBox = true;
    });

    String url = country_code;
    Uri myUri = Uri.parse(url);
    http.get(myUri).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['Data'] as List;
          if (tagObjsJson.isNotEmpty) {
            setState(() {
              showDialogBox = false;
              numberLimit = int.parse('${tagObjsJson[0]['number_limit']}');
              isoCode = tagObjsJson[0]['country_code'];
            });
          } else {
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
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

    setState(() {
      showDialogBox = false;
      numberLimit = 10;
      isoCode = '+91';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: (){
          return _handlePopBack();
        },
        child: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            "images/logos/logo_user.png", //gomarketdelivery logo
                            height: 130.0,
                            width: 99.7,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: Text(
                              '${appname}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //text on page
                          Text(AppLocalizations.of(context)!.bodyText1.toString(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1),
                          Text(
                            AppLocalizations.of(context)!.bodyText2.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontWeight: FontWeight.normal),
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
                    bottom: 52.0,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "images/logos/Delivery.gif",
                      width: MediaQuery.of(context).size.width, //footer image
                    ),
                  ),
                  PositionedDirectional(
                      bottom: 0.0,
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // CountryCodePicker(
                            //   onChanged: (value) {
                            //     isoCode = value.code;
                            //   },
                            //   builder: (value) => buildButton(value),
                            //   initialSelection: '+91',
                            //   textStyle: Theme.of(context).textTheme.caption,
                            //   showFlag: false,
                            //   showFlagDialog: true,
                            //   favorite: ['+91', 'IN'],
                            // ),
                            Text('${isoCode}'),
                            SizedBox(
                              width: 5.0,
                            ),
                            //takes phone number as input
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                child:
                                TextFormField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  readOnly: false,
                                  textAlign: TextAlign.left,
                                  enabled: !showDialogBox,
                                  decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(context)!.mobileText.toString(),
                                    border: InputBorder.none,
                                    counter: Offstage(),
                                    contentPadding: EdgeInsets.only(left: 30),
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: kHintColor,
                                        fontSize: 16),
                                  ),
                                  maxLength: numberLimit,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kMainColor,
                                  foregroundColor : kMainColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  primary: Colors.purple,
                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                  textStyle:TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400)),

                              onPressed: () {
                                if(!showDialogBox){
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                  setState(() {
                                    showDialogBox = true;
                                  });
                                  if (_controller.text.length < 10) {
                                    setState(() {
                                      showDialogBox = false;
                                    });
                                    Toast.show("Enter valid mobile number!", duration: Toast.lengthShort, gravity:  Toast.bottom);
                                  } else {
                                            store(_controller.text);
                                    hitService(isoCode, _controller.text, context);
                                  }
                                }
                              },
                                child: Text(
                                  AppLocalizations.of(context)!.continueText.toString(),
                                  style: TextStyle(
                                      color: kWhiteColor,
                                      fontWeight: FontWeight.w400),
                                ),
                            ),
                          ],
                        ),
                      )),
                ],
              )),
        ),
      ),
    );
  }

  void hitService(String isoCode, String phoneNumber, BuildContext context) async {
    String url = userRegistration;
    var client = http.Client();
    Uri myUri = Uri.parse(url);
    client.post(myUri, body: {'user_phone': '${phoneNumber}'}).then((response) async{
      print('Response Body 1: - ${response.body} - ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("user_phone", '${phoneNumber}');
        prefs.setInt("number_limit", numberLimit);
        if (jsonData['status'] == 1) {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.verification);

        } else {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.registration);
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e){
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  buildButton(CountryCode isoCode) {
    return Row(
      children: <Widget>[
        Text(
          '$isoCode',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Future<bool> _handlePopBack() async{
    bool isVal = false;
    if(showDialogBox){
      setState(() {
        showDialogBox = false;
      });
    }else{
      isVal = true;
    }
    return isVal;
  }

  Future<void> store(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user_phone", '${phoneNumber}');
  }


}
