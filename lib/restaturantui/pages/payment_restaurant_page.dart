import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/list_tile.dart';
import 'package:jhatfat/Pages/order_placed.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/cartdetails.dart';
import 'package:jhatfat/bean/couponlist.dart';
import 'package:jhatfat/bean/paymentstatus.dart';

class PaymentRestPage extends StatefulWidget {
  final dynamic vendor_ids;
  final dynamic order_id;
  final dynamic cart_id;
  final double totalAmount;
  final List<PaymentVia> tagObjs;

  PaymentRestPage(this.vendor_ids, this.order_id, this.cart_id, this.totalAmount, this.tagObjs);

  @override
  State<StatefulWidget> createState() {
    return PaymentRestPageState(order_id, cart_id, totalAmount,tagObjs);
  }
}

class PaymentRestPageState extends State<PaymentRestPage> {
  late Razorpay _razorpay;

  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  late List<PaymentVia> paymentVia;
  dynamic currency = '';
  PaystackPlugin p = new PaystackPlugin();
  bool visiblity = false;
  String promocode = '';
  late final dynamic order_id;
  late final dynamic cart_id;

  bool razor = false;
  bool paystack = false;

  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  late String _cardNumber;
  late String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  var _inProgress = false;

  var walletAmount = 0.0;
  bool isFetch = false;
  double walletUsedAmount = 0.0;
  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;


  List<CouponList> couponL = [];

  PaymentRestPageState(this.order_id,this.cart_id,this.totalAmount, this.paymentVia);

  @override
  void initState() {
    newtotalAmount = double.parse('${totalAmount}');
    super.initState();
    getCouponList();
    getWalletAmount();
  }


  void getWalletAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    setState(() {
      isFetch = true;
      currency = prefs.getString('curency');
    });
    var client = http.Client();
    var url = showWalletAmount;
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          walletAmount = double.parse('${dataList[0]['wallet_credits']}');
          if(totalAmount>walletAmount){
            if(walletAmount>0.0){
              iswallet = true;
            }else{
              iswallet = false;
            }
            totalAmount = totalAmount-walletAmount;
          }else if(totalAmount<walletAmount){
            if(walletAmount>0.0){
              iswallet = true;
            }else{
              iswallet = false;
            }
            totalAmount = 0.0;
          }else{
            iswallet = false;
          }

        });
      }
      setState(() {
        isFetch = false;
      });
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
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
        'description': 'Grocery Shopping',
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

  void payStatck(String key) async {

    p.initialize(publicKey: key);
  }

  void getCouponList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? vendorId = preferences.getString('res_vendor_id');
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = couponList;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {'cart_id': '$cart_id','vendor_id':'${vendorId}'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CouponList> tagObjs = tagObjsJson
              .map((tagJson) => CouponList.fromJson(tagJson))
              .toList();
          setState(() {
            couponL.clear();
            couponL = tagObjs;
          });
        }
      }
    }).catchError((e) {
      print(e);
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
                'Select Payment Method',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: kMainTextColor),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                'Amount to Pay $currency $totalAmount',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: kDisabledColor),
              ),
            ],
          ),
        ),
      ),
      body: isFetch
          ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 64,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 64,
          child: Stack(
            children: [
              SingleChildScrollView(
                primary: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Visibility(
                      visible: (iswallet || isCoupon) ? true : false,
                      //(iswallet||isCoupon)?true:false
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: kCardBackgroundColor,
                            child: Text(
                              'WALLET',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: kDisabledColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.67),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: iswallet, //iswallet
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'images/payment/wallet.png',
                                            height: 20.3,
                                          ),
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Text(
                                            'Wallet Amount',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${currency} ${walletAmount}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Visibility(
                                  visible: iswallet, //iswallet
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'images/payment/wallet.png',
                                            height: 20.3,
                                          ),
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Text(
                                            'Wallet Used Amount',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '- ${currency} ${walletUsedAmount}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Visibility(
                                  visible: isCoupon, //isCoupon
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'images/payment/coupon_amount.png',
                                            height: 20.3,
                                          ),
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Text(
                                            'Coupon Amount',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '- ${currency} ${coupAmount}',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'images/payment/amount.png',
                                          height: 20.3,
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Text(
                                          'Order Amount',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${currency} ${newtotalAmount}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (totalAmount > 0.0) ? true : false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: kCardBackgroundColor,
                            child: Text(
                              'CASH',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: kDisabledColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.67),
                            ),
                          ),
                          BuildListTile(
                              image: 'images/payment/amount.png',
                              text: 'Cash on Delivery',
                              onTap: () async{
                                setState(() {
                                  setProgressText =
                                  'Proceeding to placed order please wait!....';
                                  showDialogBox = true;
                                });
                                placedOrder("success", "COD");
                              }
//                    Navigator.popAndPushNamed(context, PageRoutes.orderPlaced),
                          ),
                          (totalAmount > 0.0 &&
                              paymentVia != null &&
                              paymentVia.length > 0)
                              ? Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: kCardBackgroundColor,
                            child: Text(
                              'ONLINE PAYMENT',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: kDisabledColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.67),
                            ),
                          )
                              : Container(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: (totalAmount > 0.0 &&
                                paymentVia != null &&
                                paymentVia.length > 0)
                                ? ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemBuilder: (context, index) {
                                  return BuildListTile(
                                    image:
                                    'images/payment/credit_card.png',
                                    text:
                                    'Card/UPI/NetBanking',
                                    onTap: () async{
                                      setState(() {
                                        setProgressText =
                                        'Proceeding to placed order please wait!....';
                                        showDialogBox = true;
                                      });
                                      if (paymentVia[index]
                                          .payment_mode ==
                                          "Razor Pay") {
                                        openCheckout(
                                            "${paymentVia[index].payment_key}",
                                            totalAmount * 100);
                                      } else if (paymentVia[index]
                                          .payment_mode ==
                                          "Paystack") {
                                        setState(() {
                                          payStatck(
                                              "${paymentVia[index].payment_key}");
                                          showPaymentDialog = true;
                                        });
                                      }
                                      if (paymentVia[index]
                                          .payment_mode ==
                                          "Paypal") {}
                                    },
                                  );
                                },
                                // separatorBuilder: (context, index) {
                                //   return Divider(
                                //     color: Colors.transparent,
                                //     thickness: 0.1,
                                //   );
                                // },
                                itemCount: paymentVia.length)
                                : Container(),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            color: kCardBackgroundColor,
                            child: Text(
                              'Promo Code',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: kDisabledColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.67),
                            ),
                          ),
                          Divider(
                            color: kCardBackgroundColor,
                            thickness: 6.7,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.55,
                                        height: 45,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: TextFormField(
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText:
                                            "Enter Your promo code",
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              borderSide: BorderSide(
                                                  color: kMainColor,
                                                  width: 1),
                                            ),
                                            focusedBorder:
                                            OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              borderSide: BorderSide(
                                                  color: kMainColor,
                                                  width: 1),
                                            ),
                                            enabledBorder:
                                            OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                              borderSide: BorderSide(
                                                  color: kMainColor,
                                                  width: 1),
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13),
                                          cursorColor: kMainColor,
                                          showCursor: false,
                                          keyboardType: TextInputType.text,
                                          onChanged: (val) {
                                            setState(() => promocode = val);
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (totalAmount != 0.0) {
                                              visiblity = !visiblity;
                                              setProgressText =
                                              'Applying coupon please wait!....';
                                              showDialogBox = true;
                                              appCoupon(promocode);
                                            } else {
                                              Toast.show(
                                                  'coupon code not applicable!', duration: Toast.lengthShort, gravity:  Toast.bottom);
                                            }
                                          });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.28,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(40),
                                              color: kMainColor),
                                          child: Text(
                                            'Apply',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15,
                                                color: kWhiteColor),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(
                            color: kCardBackgroundColor,
                            thickness: 6.7,
                          ),
                          // Container(
                          //   margin: EdgeInsets.symmetric(horizontal: 20),
                          //   alignment: Alignment.topCenter,
                          //   child: Column(
                          //     children: <Widget>[
                          //       // Container(
                          //       //   height: 52,
                          //       //   child: Row(
                          //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       //     children: <Widget>[
                          //       //       Text(
                          //       //         'Promo Code',
                          //       //         textAlign: TextAlign.start,
                          //       //         style: TextStyle(
                          //       //             fontWeight: FontWeight.w600,
                          //       //             fontSize: 18,
                          //       //             color: kMainTextColor),
                          //       //       ),
                          //       //       InkWell(
                          //       //         onTap: () {
                          //       //           setState(() {
                          //       //             visiblity = !visiblity;
                          //       //           });
                          //       //         },
                          //       //         child: Icon(visiblity
                          //       //             ? Icons.keyboard_arrow_down
                          //       //             : Icons.keyboard_arrow_right),
                          //       //       )
                          //       //     ],
                          //       //   ),
                          //       // ),
                          //       // Visibility(
                          //       //   visible: visiblity,
                          //       //   child: Column(
                          //       //     children: <Widget>[
                          //       //       Divider(
                          //       //         color: kCardBackgroundColor,
                          //       //         thickness: 6.7,
                          //       //       ),
                          //       //       Container(
                          //       //         width: MediaQuery
                          //       //             .of(context)
                          //       //             .size
                          //       //             .width,
                          //       //         child: Row(
                          //       //           mainAxisAlignment:
                          //       //           MainAxisAlignment.spaceBetween,
                          //       //           children: <Widget>[
                          //       //             Container(
                          //       //               width:
                          //       //               MediaQuery
                          //       //                   .of(context)
                          //       //                   .size
                          //       //                   .width *
                          //       //                   0.55,
                          //       //               height: 45,
                          //       //               alignment: Alignment.centerLeft,
                          //       //               margin: EdgeInsets.only(
                          //       //                   left: 5,
                          //       //                   right: 5,
                          //       //                   top: 5,
                          //       //                   bottom: 5),
                          //       //               padding:
                          //       //               EdgeInsets.symmetric(vertical: 2.0),
                          //       //               child: TextFormField(
                          //       //                 textAlign: TextAlign.center,
                          //       //                 decoration: InputDecoration(
                          //       //                   hintText: "Enter Your promo code",
                          //       //                   fillColor: Colors.white,
                          //       //                   border: OutlineInputBorder(
                          //       //                     borderRadius:
                          //       //                     BorderRadius.circular(10.0),
                          //       //                     borderSide: BorderSide(
                          //       //                         color: kMainColor, width: 1),
                          //       //                   ),
                          //       //                   focusedBorder: OutlineInputBorder(
                          //       //                     borderRadius:
                          //       //                     BorderRadius.circular(10.0),
                          //       //                     borderSide: BorderSide(
                          //       //                         color: kMainColor, width: 1),
                          //       //                   ),
                          //       //                   enabledBorder: OutlineInputBorder(
                          //       //                     borderRadius:
                          //       //                     BorderRadius.circular(10.0),
                          //       //                     borderSide: BorderSide(
                          //       //                         color: kMainColor, width: 1),
                          //       //                   ),
                          //       //                 ),
                          //       //                 style: TextStyle(
                          //       //                     color: Colors.black,
                          //       //                     fontSize: 14),
                          //       //                 cursorColor: kMainColor,
                          //       //                 showCursor: false,
                          //       //                 keyboardType: TextInputType.text,
                          //       //                 onChanged: (val) {
                          //       //                   setState(() => promocode = val);
                          //       //                 },
                          //       //               ),
                          //       //             ),
                          //       //             GestureDetector(
                          //       //               onTap: () {
                          //       //                 setState(() {
                          //       //                   visiblity = !visiblity;
                          //       //                   setProgressText =
                          //       //                   'Applying coupon please wait!....';
                          //       //                   showDialogBox = true;
                          //       //                   appCoupon(promocode);
                          //       //                 });
                          //       //               },
                          //       //               child: Container(
                          //       //                 alignment: Alignment.center,
                          //       //                 width: MediaQuery
                          //       //                     .of(context)
                          //       //                     .size
                          //       //                     .width *
                          //       //                     0.28,
                          //       //                 height: 40,
                          //       //                 decoration: BoxDecoration(
                          //       //                     borderRadius:
                          //       //                     BorderRadius.circular(40),
                          //       //                     color: kMainColor),
                          //       //                 child: Text(
                          //       //                   'Apply',
                          //       //                   textAlign: TextAlign.start,
                          //       //                   style: TextStyle(
                          //       //                       fontWeight: FontWeight.w300,
                          //       //                       fontSize: 15,
                          //       //                       color: kWhiteColor),
                          //       //                 ),
                          //       //               ),
                          //       //             )
                          //       //           ],
                          //       //         ),
                          //       //       )
                          //       //     ],
                          //       //   ),
                          //       // ),
                          //
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   padding:
                          //   EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          //   color: kCardBackgroundColor,
                          //   child: Text(
                          //     'Promo Code List',
                          //     style: Theme
                          //         .of(context)
                          //         .textTheme
                          //         .caption
                          //         .copyWith(
                          //         color: kDisabledColor,
                          //         fontWeight: FontWeight.bold,
                          //         letterSpacing: 0.67),
                          //   ),
                          // ),
                          // Divider(
                          //   color: kCardBackgroundColor,
                          //   thickness: 6.7,
                          // ),
                          Visibility(
                            visible: (couponL != null && couponL.length > 0)
                                ? true
                                : false,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: (couponL != null && couponL.length > 0)
                                  ? ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: couponL.length,
                                  itemBuilder: (context, t) {
                                    return Column(
                                      children: [
                                        Divider(
                                          color: kCardBackgroundColor,
                                          thickness: 2.3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                                    '${couponL[t].coupon_code}\n${couponL[t].coupon_description}')),
                                            Radio(
                                                value: t,
                                                groupValue: radioId,
                                                toggleable: true,
                                                onChanged: (val) {
                                                  print('${val}');
                                                  print(
                                                      '${radioId} - ${t}');
                                                  if (radioId != t ||
                                                      radioId == -1) {
                                                    setState(() {
                                                      if (totalAmount !=
                                                          0.0) {
                                                        radioId = t;
                                                        print(
                                                            '${radioId} - ${t}');
                                                        setProgressText =
                                                        'Applying coupon please wait!....';
                                                        showDialogBox =
                                                        true;
                                                        appCoupon(couponL[
                                                        t]
                                                            .coupon_code);
                                                      } else {
                                                        Toast.show(
                                                            'coupon code not applicable!', duration: Toast.lengthShort, gravity:  Toast.bottom);
                                                      }
                                                    });
                                                  } else {
                                                    setState(() {
                                                      radioId = -1;
                                                      showDialogBox =
                                                      true;
                                                      appCoupon(couponL[
                                                      t]
                                                          .coupon_code);
                                                    });
                                                  }
                                                })
                                          ],
                                        ),
                                        Divider(
                                          color: kCardBackgroundColor,
                                          thickness: 2.3,
                                        ),
                                      ],
                                    );
                                  })
                                  : Container(),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                        visible: (totalAmount > 0.0) ? false : true,
                        child: Container(
                          height: 250,
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            height: 40,
                            width: 150,
                            child: ElevatedButton(
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
                                if (!showDialogBox) {
                                  setState(() {
                                    showDialogBox = true;
                                  });
                                  placedOrder('success', 'wallet');
                                }
                              },
                              child: Text(
                                'Place Order',
                                style: TextStyle(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w400),
                              ),

                            ),
                          ),
                        ))
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Visibility(
                    visible: showPaymentDialog,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        color: black_color.withOpacity(0.6),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Material(
                          borderRadius: BorderRadius.circular(10),
                          elevation: 5,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 60,
                            padding: const EdgeInsets.all(20.0),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border:
                                        const UnderlineInputBorder(),
                                        labelText: 'Card number',
                                      ),
                                      onChanged: (String value) =>
                                    _cardNumber = value,
                                      //onSaved: (String value!) =>_cardNumber = value,
                                    ),
                                    _verticalSizeBox,
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType:
                                            TextInputType.number,
                                            decoration:
                                            const InputDecoration(
                                              border:
                                              const UnderlineInputBorder(),
                                              labelText: 'CVV',
                                            ),
                                            onChanged: (String value) =>
                                            _cvv = value,
                                          ),
                                        ),
                                        _horizontalSizeBox,
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType:
                                            TextInputType.number,
                                            decoration:
                                            const InputDecoration(
                                              border:
                                              const UnderlineInputBorder(),
                                              labelText: 'Expiry Month',
                                            ),
                                            onChanged: (String value) =>
                                            _expiryMonth =
                                                int.tryParse(value)!,
                                          ),
                                        ),
                                        _horizontalSizeBox,
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType:
                                            TextInputType.number,
                                            decoration:
                                            const InputDecoration(
                                              border:
                                              const UnderlineInputBorder(),
                                              labelText: 'Expiry Year',
                                            ),
                                            onChanged:(String value) =>
                                            _expiryYear = int.tryParse(value)!,
                                          ),
                                        )
                                      ],
                                    ),
                                    _verticalSizeBox,
                                    _inProgress
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
                                        'Proceed to payment',
                                        style: TextStyle(
                                            color: kWhiteColor,
                                            fontSize: 17,
                                            fontWeight:
                                            FontWeight.w400),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _inProgress = true;
                                        });
                                        _startAfreshCharge();
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
              Positioned.fill(
                  child: Visibility(
                    visible: showDialogBox,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        // color: black_color.withOpacity(0.6),
                        height: MediaQuery.of(context).size.height - 100,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )),
            ],
          )),
    );
  }

  void placedOrder(paymentStatus, paymentMethod) {
    var url = orderplaced;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'payment_method': '${paymentMethod}',
      'wallet': iswallet?'yes':'no',
      'payment_status': paymentStatus,
      'cart_id': cart_id.toString()
    }).then((value) {
      print('deta - ${value.body}');
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          hitNavigator(cart_id, details.payment_method, details.payment_status,
              details.order_id, details.rem_price);
        } else {
          setState(() {
            showDialogBox = false;
          });
          Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        Toast.show('Something went wrong!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      print('error - $e');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitNavigator(cart_id, payment_method, payment_status, order_id,
      rem_price) async {
    var url = after_order_reward_msg;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'cart_id': '${cart_id}',
      'order_array': '',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      setState(() {
        showDialogBox = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OrderPlaced(payment_method, payment_status, cart_id, rem_price,currency,"2");
      }));
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OrderPlaced(payment_method, payment_status, order_id, rem_price,currency,"2");
      }));
    });
  }

  void appCoupon(couponCode) {
    var url = applyCoupon;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'coupon_code': '$couponCode',
      'cart_id': cart_id.toString()
    }).then((value) {
      print('deta - ${value.body}');
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          setState(() {
            isCoupon = true;
            totalAmount = double.parse(details.rem_price.toString());
            coupAmount = double.parse('${details.coupon_discount}');
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            }
            else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount-coupAmount;
            }
            else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        }else if (jsonData['status'] == "2") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          setState(() {
            isCoupon = false;
            totalAmount = double.parse(details.total_price.toString());
            coupAmount = 0.0;
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            }
            else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            }
            else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        } else {
          Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
          setState(() {
            radioId = -1;
            totalAmount = newtotalAmount;
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            }
            else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            }
            else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            isCoupon = false;
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          totalAmount = newtotalAmount;
          radioId = -1;
          if (totalAmount > walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = totalAmount - walletAmount;
            walletUsedAmount = walletAmount;
          }
          else if (totalAmount < walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = 0.0;
            walletUsedAmount = newtotalAmount;
          }
          else {
            iswallet = false;
            walletUsedAmount = 0.0;
          }
          isCoupon = false;
          showDialogBox = false;
        });
        Toast.show('Something went wrong!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      print('error - $e');
      setState(() {
        totalAmount = newtotalAmount;
        radioId = -1;
        if (totalAmount > walletAmount) {
          if (walletAmount > 0.0) {
            iswallet = true;
          } else {
            iswallet = false;
          }
          totalAmount = totalAmount - walletAmount;
          walletUsedAmount = walletAmount;
        }
        else if (totalAmount < walletAmount) {
          if (walletAmount > 0.0) {
            iswallet = true;
          } else {
            iswallet = false;
          }
          totalAmount = 0.0;
          walletUsedAmount = newtotalAmount;
        }
        else {
          iswallet = false;
          walletUsedAmount = 0.0;
        }
        isCoupon = false;
        showDialogBox = false;
      });
    });
  }

  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  _startAfreshCharge() async {
    _formKey.currentState!.save();

    Charge charge = Charge()
      ..amount = 100 // In base currency
      ..email = 'customer@email.com'
      ..currency = 'NGN'
      ..card = _getCardFromUI()
      ..reference = _getReference();

    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    p.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.toString()}');
      print('${value.card}');
      if (value.status && value.message == "Success") {
        setState(() {
          showPaymentDialog = false;
          _inProgress = false;
          showDialogBox = true;
        });
        placedOrder("success", "RazorPay");
      }
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime
        .now()
        .millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placedOrder("success", "RazorPay");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
  }
}