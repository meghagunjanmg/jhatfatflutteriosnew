import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/customprogresscircle.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/rewardvalue.dart';

class Reward extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RewardState();
  }
}

class RewardState extends State<Reward> {
  dynamic rewardPoint = 0;
  dynamic rewardValues = 0.0;

  var isRedeem = false;

  progressView() {
    return CustomPaint(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${rewardPoint}',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: kMainTextColor),
          ),
          Text(
            'Total Earned',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: kHintColor),
          ),
        ],
      )),
      foregroundPainter: ProgressPainter(Colors.amber, kMainColor, 100, 10.0),
    );
  }

  List<RewardHistory> history = [];
  bool isFetchStore = false;

  @override
  void initState() {
    super.initState();
    getRewardValue();
    getHistory();
  }

  void getRewardValue() async {
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    var client = http.Client();
    var url = rewardvalues;
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        setState(() {
          rewardPoint = jsonData['data']['rewards'];
          if (double.parse(rewardPoint) == 0.0) {
            isRedeem = false;
          } else {
            isRedeem = true;
          }
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

  void getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    var client = http.Client();
    var url = rewardhistory;
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['data'] as List;
          List<RewardHistory> tagObjs = tagObjsJson
              .map((tagJson) => RewardHistory.fromJson(tagJson))
              .toList();
          setState(() {
            history.clear();
            history = tagObjs;
          });
        } else {
          Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      } else {
        Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
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
                'Reward Points',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: kMainTextColor),
              ),
            ],
          ),
          actions: [
            Visibility(
              visible: isRedeem ? true : false,
              child: Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child:  ElevatedButton(
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
                    redeemPoints();
                  },
                  child: Text(
                    'Redeem',
                    style: TextStyle(
                        color: kWhiteColor, fontWeight: FontWeight.w400),
                  ),
                  // color: kMainColor,
                  // highlightColor: kMainColor,
                  // focusColor: kMainColor,
                  // splashColor: kMainColor,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                ),
              ),
            )
          ],
        ),
      ),
      body: (!isFetchStore)
          ? Column(
              children: <Widget>[
                Card(
                  elevation: 3,
                  margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Center(
                    widthFactor: MediaQuery.of(context).size.width - 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 150.0,
                          width: 150.0,
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(top: 5, bottom: 20.0),
                          child: progressView(),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${rewardPoint}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: kMainTextColor),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Earned',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kHintColor),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '0',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: kMainTextColor),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Spent',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kHintColor),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${rewardPoint}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: kMainTextColor),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Have',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kHintColor),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: kMainColor, border: Border.all(color: kMainColor)),
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
                            'Order Id',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kWhiteColor),
                          ),
                        ],
                      ),
                      Text(
                        'Reward Point',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                  '#${history[index].cart_id}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: kMainTextColor),
                                ),
                              ],
                            ),
                            Text(
                              '${history[index].reward_points}',
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
              ],
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
                    'Fetching reward points',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kMainTextColor),
                  )
                ],
              ),
            ),
    );
  }

  void redeemPoints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    var url = redeem;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var redemData = jsonDecode(value.body);
        if (redemData['status'] == "1") {
          print('${value.body}');
          setState(() {
            isRedeem = false;
            rewardPoint = 0.0;
          });
          Toast.show(redemData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      }
    }).catchError((e) {});
  }
}
