import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/Components/list_tile.dart';
import 'package:jhatfat/Pages/order_placed.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/cartdetails.dart';
import 'package:jhatfat/bean/couponlist.dart';
import 'package:jhatfat/bean/paymentstatus.dart';
import 'package:jhatfat/bean/subscriptionlist.dart';

import '../HomeOrderAccount/home_order_account.dart';

class Subscription extends StatefulWidget {

  Subscription();

  @override
  State<StatefulWidget> createState() {
    return SubscritionState();
  }
}

class SubscritionState extends State<Subscription> {
  String subsid="0";
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  List<PaymentVia> paymentVia = [];
  dynamic currency = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletAmount = 0.0;
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
    getVendorPayment();
    getplanlist();
    newtotalAmount = double.parse('${totalAmount}');
  }
  void getplanlist() async {
    var url = subscriptionList;
    var client = http.Client();
    Uri myUri = Uri.parse(url);
    client.get(myUri).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<subscriptionlist> p = tagObjsJson
              .map((tagJson) => subscriptionlist.fromJson(tagJson))
              .toList();
          setState(() {
            planlist = p;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void SubscriptionAPI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userId = preferences.getInt('user_id');
    var url = subscribe;
    var client = http.Client();
    Uri myUri = Uri.parse(url);
    client.post(myUri,body: {
      "user_id":userId.toString(),
      "subs_id":subsid,
    }).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          Fluttertoast.showToast(
              msg: "Subscription Applied",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {
                return HomeOrderAccount(0,1);
              }), (Route<dynamic> route) => false);
        }

        else{
          Fluttertoast.showToast(
              msg: jsonData['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
    }).catchError((e) {
      print(e);
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
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

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
        'amount': amount,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(64.0),
          child: AppBar(
            automaticallyImplyLeading: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Subscription',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: kMainTextColor),
                ),
              ],
            ),
          ),
        ),
        body:
        ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: planlist.length,
            itemBuilder: (context, i) {
    return(
    Container(
    child: Card(
    shadowColor: kMainColor,
    margin:EdgeInsets.all(20),
    child:Container(
    height: 380,
    color: Colors.white,
    child: Row(
    children: [
    Expanded(
    child:Container(
    alignment: Alignment.topLeft,
    child: Column(
    children: [
    ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
    title: Text(planlist[i].plans.toString(),
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black),),
    ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Image.network(imageBaseUrl+planlist[i].banner,
            height: 100,
            fit:BoxFit.fill
        ),
      ),
    ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
    title: Text(planlist[i].description.toString(),
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black),),
    ),

    ListTile(
    title: Text("For "+planlist[i].days.toString()+" Days @ "+"${currency}"+planlist[i].amount.toString(),
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black),),
    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
    ),

      Padding(padding: EdgeInsets.all(10),
      child : ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            primary: kMainColor,
            padding:EdgeInsets.symmetric(
                horizontal: 50, vertical: 20),
            textStyle: TextStyle(
                color: kWhiteColor, fontWeight: FontWeight.w400)),
        onPressed: () {
          setState(() {
            subsid = planlist[i].planId.toString();
          });
          openCheckout(tagObjs[0].payment_key, double.parse(planlist[i].amount.toString()) * 100);
        },
        child: Text("Payment")
    ),
      ),
    ]
    )
    )
    )
    ]
    )
    )
    )
    )
    );
    }));
  }




  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    SubscriptionAPI();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
    Fluttertoast.showToast(
        msg: "ERROR: " + response.message.toString());

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.toString());
  }
}