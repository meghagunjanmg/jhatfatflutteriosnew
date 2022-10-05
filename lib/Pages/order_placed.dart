
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../HomeOrderAccount/Home/UI/order_placed_map.dart';
import '../baseurlp/baseurl.dart';
import '../bean/orderbean.dart';
import '../bean/resturantbean/orderhistorybean.dart';
import '../parcel/ordermappageparcel.dart';
import '../parcel/pharmacybean/parcelorderhistorybean.dart';
import '../restaturantui/pages/ordermaprestaurant.dart';

class OrderPlaced extends StatelessWidget {
  final dynamic payment_method;
  final dynamic payment_status;
  final dynamic order_id;
  final dynamic rem_price;
  final dynamic currency;
  final dynamic uiType;
  List<String> VendorName=[];

  OrderPlaced(this.payment_method, this.payment_status, this.order_id,
      this.rem_price, this.currency, this.uiType) {
    deleteProducts(uiType);
  }

  void deleteProducts(uiType) async {
    DatabaseHelper db = DatabaseHelper.instance;
    if (uiType == "1") {
      db.deleteAll();
    } else if (uiType == "2") {
      db.deleteAllRestProdcut();
      db.deleteAllAddOns();
    } else if (uiType == "5") {
      clearCart(db);
    }
  }

  void clearCart(db) async {
    db.deleteAllPharma().then((value) {
      db.deleteAllAddonPharma();
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return HomeOrderAccount(0);
            }), (Route<dynamic> route) => true);
        return true; //
      },

      child: Scaffold(
          body: Column(
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.all(60.0),
                child: Image.asset(
                  'images/order_placed.png',

                  alignment: Alignment.center,
                ),
              ),
              Text(
                'Order id - $order_id has been Placed \n Please keep $currency $rem_price!!',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 24, color: kMainTextColor),
              ),
              Text(
                '\n\nThanks for choosing us for delivering your needs.\n\nYou can check your order status in my order section.',
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: kDisabledColor),
              ),
              Spacer(
                flex: 2,
              ),
        Row(
            children: <Widget>[

              Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      primary: kMainColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: TextStyle(
                          color: kWhiteColor, fontWeight: FontWeight.w400)),
                  onPressed: () {
                        CallAPI('$order_id',context);
                    },

                  child: Text("Start Tracking")
              ),
        ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        primary: kMainColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        textStyle: TextStyle(
                            color: kWhiteColor, fontWeight: FontWeight.w400)),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) {
                            return HomeOrderAccount(0);
                          }), (Route<dynamic> route) => false);},

                    child: Text("Go To Home")
                ),
              )
        ]
        ),
            ],
          ),
        ),
      );
  }

  void CallAPI(String orderid,BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userId =  preferences.getInt('user_id');

    if(uiType=="4") {
      var url = parceldetails;
      Uri myUri = Uri.parse(url);
      http.post(myUri, body: {'user_id': '$userId', 'cart_id': '$orderid'})
          .then((value) {
        if (value.statusCode == 200 && value.body != null) {
          {
            var tagObjsJson = jsonDecode(value.body) as List;
            List<TodayOrderParcel> orders = tagObjsJson
                .map((tagJson) => TodayOrderParcel.fromJson(tagJson))
                .toList();
            Navigator.pushReplacement(context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderMapParcelPage(
                          pageTitle:
                          orders[0].vendorName,
                          ongoingOrders:
                          orders[0],
                          currency: currency,
                          user_id: orders[0].cartId.toString()
                      ),
                ));

          }
        }
      });
    }

    else {
          var url = orderdetails;
          Uri myUri = Uri.parse(url);
          http.post(myUri, body: {'user_id': '$userId', 'cart_id': '$orderid'})
              .then((value) {
            if (value.statusCode == 200 && value.body != null) {
              {
                if (uiType == "1") {
                  var tagObjsJson = jsonDecode(value.body) as List;
                  List<OngoingOrders> orders = tagObjsJson
                      .map((tagJson) => OngoingOrders.fromJson(tagJson))
                      .toList();
                  String vendor = '';

                  for (int i = 0; i < orders.length; i++) {
                    for (int j = 0; j < orders[i].data.length; j++) {
                      if (orders[i].data[j].order_cart_id ==
                          orders[i].cart_id) {
                        vendor = vendor + "," + orders[i].data[j].vendor_name;
                      }
                    }
                    VendorName.add(vendor);
                    vendor = '';
                    print("NAME " + i.toString() + " " + vendor);
                  }
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderMapPage(
                              pageTitle:
                              VendorName[0],
                              ongoingOrders:
                              orders.elementAt(0),
                              currency: currency,
                              user_id: orders
                                  .elementAt(0)
                                  .cart_id
                                  .toString(),
                            ),
                      ));

                }
                if (uiType == "2") {
                  var tagObjsJson = jsonDecode(value.body) as List;
                  List<OrderHistoryRestaurant> orders = tagObjsJson
                      .map((tagJson) =>
                      OrderHistoryRestaurant.fromJson(tagJson))
                      .toList();

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderMapRestPage(
                              pageTitle:
                              orders[0].vendor_name,
                              ongoingOrders:
                              orders[0],
                              currency: currency,
                              user_id: orders[0].cart_id.toString(),
                            ),
                      ));

                }
              }
            }
          });
        }
    }
}

