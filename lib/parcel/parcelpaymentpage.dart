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

class PaymentParcelPage extends StatefulWidget {
  final dynamic vendor_ids;
  final dynamic cart_id;
  final double totalAmount;
  final List<PaymentViaParcel> tagObjs;

  PaymentParcelPage(this.vendor_ids, this.cart_id, this.totalAmount, this.tagObjs);

  @override
  State<StatefulWidget> createState() {
    return PaymentParcelPageState(cart_id, totalAmount, tagObjs);
  }
}

class PaymentParcelPageState extends State<PaymentParcelPage> {
  PaystackPlugin paystackPlugin = new PaystackPlugin();
  late Razorpay _razorpay;

  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  List<PaymentViaParcel> paymentVia;
  dynamic currency = '';
  bool visiblity = false;
  String promocode = '';
  final dynamic cart_id;
  bool razor = false;
  bool paystack = false;
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  String _cardNumber = "";
  String _cvv="";
  int _expiryMonth = 0;
  int _expiryYear = 0;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  var _inProgress = false;

  var walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  var newtotalAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;


  List<CouponList> couponL = [];

  PaymentParcelPageState(this.cart_id,this.totalAmount, this.paymentVia);

  @override
  void initState() {
    newtotalAmount = double.parse('${totalAmount}');
    super.initState();

    
    openCheckout(
        "${paymentVia[0].payment_key}",
        totalAmount * 100);

    // getCouponList();
    // getWalletAmount();
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
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          walletAmount = double.parse('${dataList[0]['wallet_credits']}');
          if (totalAmount > walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = totalAmount - walletAmount;
            walletUsedAmount = walletAmount;
          } else if (totalAmount < walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = 0.0;
            walletUsedAmount = newtotalAmount;
          } else {
            iswallet = false;
            walletUsedAmount = 0.0;
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
    paystackPlugin.initialize(publicKey: key);
  }

  void getCouponList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? vendorId = preferences.getString('vendor_id');
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = couponList;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'cart_id': '$cart_id',
      'vendor_id': '${vendorId}'
    }).then((value) {
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
     body: Container(
              alignment: Alignment.center,
              child: Text(
                'Proceeding to Payment...',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: kMainTextColor),
              ),
      ),
    );
  }
  void placedOrder(paymentStatus, paymentMethod) {
    var url = parcel_orderplaced;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'payment_method': '${paymentMethod}',
      'wallet': iswallet ? 'yes' : 'no',
      'payment_status': paymentStatus,
      'cart_id': '${cart_id}',
      'total_price':'${totalAmount}'
    }).then((value) {
      print("ORDERPLACED"+ value.body.toString());

      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          hitNavigator(cart_id, '${paymentMethod}', '${paymentStatus}', cart_id,
              '${totalAmount}');
        } else {
          setState(() {
            showDialogBox = false;
          });
          // Toast.show(jsonData['message'], context,
          //     duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        // Toast.show('Something went wrong!', context,
        //     duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      print('error - $e');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitNavigator(
      cart_id, payment_method, payment_status, order_id, rem_price) async {
    var url = parcel_after_order_reward_msg;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'cart_id': '${cart_id}',
    }).then((value) async {
      setState(() {
        showDialogBox = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OrderPlaced(
            payment_method, payment_status, cart_id, rem_price, currency, "4");
      }));

      SharedPreferences prefs =
          await SharedPreferences.getInstance();

      prefs.remove("pickupLocation");
      prefs.remove("dropLocation");
      prefs.remove("dlt");
      prefs.remove("dln");
      prefs.remove("plt");
      prefs.remove("pln");

    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void appCoupon(couponCode) {
    var url = applyCoupon;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'coupon_code': '$couponCode',
      'cart_id': cart_id.toString()
    }).then((value) {
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
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
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount - coupAmount;
            } else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        } else if (jsonData['status'] == "2") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
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
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            } else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        } else {
          // Toast.show(jsonData['message'], context,
          //     duration: Toast.LENGTH_SHORT);
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
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            } else {
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
          } else if (totalAmount < walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = 0.0;
            walletUsedAmount = newtotalAmount;
          } else {
            iswallet = false;
            walletUsedAmount = 0.0;
          }
          isCoupon = false;
          showDialogBox = false;
        });
        // Toast.show('Something went wrong!', context,
        //     duration: Toast.LENGTH_SHORT);
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
        } else if (totalAmount < walletAmount) {
          if (walletAmount > 0.0) {
            iswallet = true;
          } else {
            iswallet = false;
          }
          totalAmount = 0.0;
          walletUsedAmount = newtotalAmount;
        } else {
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


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placedOrder("success", "RazorPay");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}
}