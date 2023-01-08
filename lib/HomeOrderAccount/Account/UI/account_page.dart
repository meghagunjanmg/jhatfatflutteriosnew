import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Auth/login_navigator.dart';
import 'package:jhatfat/Components/list_tile.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/saved_addresses_page.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:http/http.dart' as http;

import '../../../baseurlp/baseurl.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account', style: Theme.of(context).textTheme.bodyText1),
        centerTitle: true,
      ),
      body: Account(),
    );
  }
}

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  late String number = "";
  var userName = '';
  var phoneNumber = '';
  var emailId = '';
  var message = '';

  @override
  void initState() {
    super.initState();
    getName();
    getData();
  }

  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('user_name');
    var phone = prefs.getString('user_phone');
    var email = prefs.getString('user_email');

    setState(() {
      if (name != null && name != '') {
        userName = name;
      } else {
        userName = '';
      }

      if (phone != null && phone != '') {
        phoneNumber = phone;
      } else {
        phoneNumber = '';
      }

      if (email != null && email != '') {
        emailId = email;
      } else {
        emailId = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        UserDetails(userName, phoneNumber, emailId),
        Divider(
          color: kCardBackgroundColor,
          thickness: 8.0,
        ),
        AddressTile(),
        BuildListTile(
            image: 'images/account/ic_orders.png',
            text: 'Orders',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.orderPage);
            }
        ),
        BuildListTile(
            image: 'images/account/ic_menu_wallet.png',
            text: 'Wallet',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.wallet);
            }
        ),
        BuildListTile(
            image: 'images/account/reward.png',
            text: 'Rewards',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.reward);
            }
        ),
        BuildListTile(
            image: 'images/account/ic_notification.png',
            text: 'Notification',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.offers);
            }
        ),



        BuildListTile(
            image: 'images/account/reffernearn.png',
            text: 'Refer n earn',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.reffernearn);
            }
        ),        BuildListTile(
            image: 'images/account/ic_menu_tncact.png',
            text: 'Terms & Conditions',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.tncPage);
            }
        ),        BuildListTile(
            image: 'images/account/ic_menu_supportact.png',
            text: 'Support',
            onTap: () async { Navigator.pushNamed(context, PageRoutes.supportPage,
                arguments: number);}
        ),
        BuildListTile(
            image: 'images/account/ic_menu_aboutact.png',
            text: 'About us',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.aboutUsPage);
            }        ),
        BuildListTile(
            image: 'images/account/ic_menu_aboutact.png',
            text: 'Settings',
            onTap: () async {
              Navigator.pushNamed(context, PageRoutes.settings);
            }        ),
        DeleteTile(phoneNumber),

        LogoutTile(),


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
    );
  }


  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      message = prefs.getString("message")!;
    });
  }
}

class AddressTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BuildListTile(
        image: 'images/account/ic_menu_addressact.png',
        text: 'Saved Addresses',

        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return SavedAddressesPage("");
          }));
          return null;
        });
  }
}

class LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BuildListTile(
      image: 'images/account/ic_menu_logoutact.png',
      text: 'Logout',
      onTap: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Logging out'),
                content: Text('Are you sure?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('No'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                      child: Text('Yes'),
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        prefs.clear();
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                              return LoginNavigator();
                            }), (Route<dynamic> route) => false);
                      })
                ],
              );
            });
      },
    );
  }
}


class DeleteTile extends StatelessWidget {
  String phoneNumber;

  DeleteTile(this.phoneNumber);

  @override
  Widget build(BuildContext context) {
    return BuildListTile(
      image: 'images/account/ic_menu_logoutact.png',
      text: 'Delete Profile',
      onTap: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Delete Profile'),
                content: Text('Are you sure?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('No'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                      child: Text('Yes'),
                      onPressed: () async {
                        hitService(phoneNumber,context);

                      })
                ],
              );
            });
      },
    );
  }
}
void hitService(phoneNumber,context) async {
  String url = deleteaccount;
  Uri myUri = Uri.parse(url);
  await http.post(myUri, body: {
    'user_phone': phoneNumber,
  }).then((response) async {
    print('Response Body: *-*- ${response.body}');
    if (response.statusCode == 200) {
      print('Response Body: *-*- ${response.body}');
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == "1") {
        SharedPreferences prefs =
        await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return LoginNavigator();
            }), (Route<dynamic> route) => false);
      }
    } else {
    }
  }).catchError((e) {
    print(e);
  });
}



class UserDetailsState extends State<UserDetails> {
  var userName = '';
  var phoneNumber = '';
  var emailId = '';

  UserDetailsState(this.userName, this.phoneNumber, this.emailId);

  Future<void> getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name = prefs.getString('user_name');
    var phone = prefs.getString('user_phone');
    var email = prefs.getString('user_email');
    setState(() {
      if (name != null && name != '') {
        userName = name;
      } else {
        userName = '';
      }
      if (phone != null && phone != '') {
        phoneNumber = phone;
      } else {
        phoneNumber = '';
      }
      if (email != null && email != '') {
        emailId = email;
      } else {
        emailId = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('\n' + userName, style: Theme.of(context).textTheme.bodyText1),
          Text('\n' + phoneNumber,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: Color(0xff9a9a9a))),
          SizedBox(
            height: 5.0,
          ),
          Text(emailId,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(color: Color(0xff9a9a9a))),
        ],
      ),
    );
  }
}

class UserDetails extends StatefulWidget {
  var userName = '';
  var phoneNumber = '';
  var emailId = '';

  UserDetails(this.userName, this.phoneNumber, this.emailId);

  @override
  State<StatefulWidget> createState() {
    return UserDetailsState(userName, phoneNumber, emailId);
  }
}