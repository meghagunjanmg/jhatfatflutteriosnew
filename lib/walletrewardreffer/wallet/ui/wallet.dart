import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/rewardvalue.dart';

import '../../../bean/couponlist.dart';
import '../../../bean/paymentstatus.dart';
import '../../../bean/subscriptionlist.dart';

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
  TextEditingController _textFieldController = TextEditingController();
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  List<PaymentVia> paymentVia = [];

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;


  List<CouponList> couponL = [];
  List<PaymentVia> tagObjs =[];
  List<subscriptionlist> planlist=[];

  @override
  void initState() {
    super.initState();
    getData();
    getWalletAmount();
    getWalletHistory();
    getVendorPayment();
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
          //Toast.show(jsonData['message'], duration: Toast.lengthShort, gravity:  Toast.bottom);

        }
      } else {
        //Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      //Toast.show('No history found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
    });
  }

  String message = '';
  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      message = pref.getString("message")!;
    });
  }
  void getVendorPayment() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;

          setState((){
            tagObjs = tagObjsJson
                .map((tagJson) => PaymentVia.fromJson(tagJson))
                .toList();

          });

        }
      }
    }).catchError((e) {
      print(e);
    });
  }


  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount * 100,
        'name': '${prefs.getString('user_name')}',
        'description': 'Subscription',
        'prefill': {
          'contact': '${prefs.getString('user_phone')}',
          'email': '${prefs.getString('user_email')}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }


  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    CallAPI();
  }

  void _handlePaymentError(PaymentFailureResponse response) {

    Fluttertoast.showToast(
        msg: "ERROR: " + response.message.toString());

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.toString());
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
          actions: [
            TextButton(onPressed:(){
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Add Money To Wallet'),
                      content: TextField(
                        controller: _textFieldController,
                        decoration: InputDecoration(hintText: "Enter Amount"),
                      ),
                      actions: [
                        new TextButton(
                          child: new Text('Add Money'),
                          onPressed: () {
                            openCheckout(tagObjs[0].payment_key,int.parse(_textFieldController.text.toString()));
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  }
              );
            }, child: Text("Add Money",
                style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: kMainColor)))
          ],
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

  Future<void> CallAPI() async {
    var url = addwallet;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
      'addwallet': _textFieldController.text.toString(),
    }).then((value) {
      var jsonData = jsonDecode(value.body);
      if (jsonData['status'] == "1") {
        getWalletAmount();
        setState(() {
          setState(() {
            _textFieldController.clear();
          });
        });
      }
      else{
        setState(() {
        });
      }
    });
  }
}
