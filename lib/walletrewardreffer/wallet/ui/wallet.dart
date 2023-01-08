import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/rewardvalue.dart';

class Wallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletState();
  }
}

class WalletState extends State<Wallet> {
  bool three_expandtrue = false;
  int style_selectedValue = 0;
  bool visible = false;
  int rs_selected = -1;
  String email = '';
  dynamic walletAmount = 0.0;
  dynamic currency = '';
  List<WalletHistory> history = [];
  bool isFetchStore = false;

  @override
  void initState() {
    super.initState();
    getData();
    getWalletAmount();
    getWalletHistory();
  }

  void getWalletAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    setState(() {
      isFetchStore = true;
      currency = prefs.getString('curency');
    });
    var client = http.Client();
    var url = showWalletAmount;
    Uri myUri = Uri.parse(url);
    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          walletAmount = dataList[0]['wallet_credits'];
        });
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  void getWalletHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var client = http.Client();
    var url = creditHistroy;
    Uri myUri = Uri.parse(url);
    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['data'] as List;
          List<WalletHistory> tagObjs = tagObjsJson
              .map((tagJson) => WalletHistory.fromJson(tagJson))
              .toList();
          setState(() {
            history.clear();
            history = tagObjs;
          });
        } else {
          Toast.show(jsonData['message'], duration: Toast.lengthShort, gravity:  Toast.bottom);

        }
      } else {
        Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
    });
  }

  String message = '';
  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      message = pref.getString("message")!;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: kWhiteColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'My Wallet',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: kMainTextColor),
              ),
            ],
          ),
        ),
      ),
      body: (!isFetchStore)
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                    color: kWhiteColor,
                    elevation: 10,
                    child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 20,
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text('Wallet Balance',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: kDisabledColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        letterSpacing: 0.67)),
                            Text('$currency ${walletAmount}/-'),
                            Text(
                                'Minimum wallet balance $currency ${walletAmount}/-',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: kDisabledColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 0.67)),
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: kMainColor,
                        border: Border.all(color: kMainColor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'S No.',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kWhiteColor),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Type',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kWhiteColor),
                            ),
                          ],
                        ),
                        Text(
                          'Wallet Amount',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kWhiteColor),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: kMainTextColor),
                                  ),
                                  SizedBox(
                                    width: 35,
                                  ),
                                  Text(
                                    '${history[index].type}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: kMainTextColor),
                                  ),
                                ],
                              ),
                              Text(
                                '$currency ${history[index].amount}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kMainTextColor),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 2,
                          color: kCardBackgroundColor,
                        );
                      },
                      itemCount: history.length),

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
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Fetching wallet amount',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
    );
  }
}
