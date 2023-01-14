import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horizontal_calendar_view_widget/date_helper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/saved_addresses_page.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Pages/payment_method.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/address.dart';
import 'package:jhatfat/bean/cartdetails.dart';
import 'package:jhatfat/bean/cartitem.dart';
import 'package:jhatfat/bean/orderarray.dart';
import 'package:jhatfat/bean/paymentstatus.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../bean/couponlist.dart';
import '../bean/orderarray.dart';
import '../bean/resturantbean/restaurantcartitem.dart';
import '../restaturantui/pages/payment_restaurant_page.dart';

class oneViewCart extends StatefulWidget {
  @override
  _oneViewCartState createState() => _oneViewCartState();
}

class _oneViewCartState extends State<oneViewCart> {
  String storeName = '';
  dynamic packcharge = 0.0;
  String vendorCatId = '';
  String uiType = '';
  dynamic vendorId = '';

  static String id = 'exploreScreen';

  List<CartItem> cartListI = [];
  List<RestaurantCartItem> cartListII = [];

  var totalAmount = 0.0;
  var couponAmount = 0.0;
  dynamic deliveryCharge = 0.0;
  dynamic storedeliveryCharge = 0.0;

  var showDialogBox = false;

  late DateTime firstDate;
  late DateTime lastDate;
  List<DateTime> dateList = [];
  String dateTimeSt = '';
  String currency = '';
  List<dynamic> radioList = [];
  bool isCartFetch = false;
  late ShowAddressNew? addressDelivery = null;
  bool isFetchingTime = false;
  int idd = 0;
  int idd1 = 0;
  bool basketvalue = false;
  List<instructionbean> instruction = [];
  String Errormessage = '';
  String message = '';
  int is_id_req = 0;
  int is_pres_req = 0;
  int is_basket_req = 0;

  String? iduploaded = null;
  String? iduploadedALready = null;
  String? presuploaded = null;


  bool isCoupon = false;
  double coupAmount = 0.0;

  int surge_charges = 0;
  int night_charges = 0;
  int conv_charges = 0;
  int maxincash = 0;


  int radioId = -1;
  List<CouponList> couponL = [];
  CouponList? selectedcoupon;
  bool visiblity = false;
  String promocode = '';

  void getResStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storename = prefs.getString('store_resturant_name');
    String? vendor_cat_id = prefs.getString('vendor_cat_id');
    String? ui_type = prefs.getString('ui_type');
    dynamic vendor_id = prefs.getString('res_vendor_id');

    dynamic package_charge = prefs.getString('res_pack_charge');
    setState(() {
      packcharge = double.parse(package_charge);
      currency = prefs.getString('curency')!;
      if (storename != null && storename.length > 0) {
        storeName = storename;
      }
      if (vendorCatId.length > 0) {
        vendorCatId = vendor_cat_id!;
      }
      if (uiType.length > 0) {
        uiType = ui_type!;
      }
      if (vendor_id != null && vendor_id.length > 0) {
        vendorId = vendor_id;
      }
    });
  }

  void getStoreName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storename = prefs.getString('store_name');
    setState(() {
      storeName = storename!;
    });
  }
  void getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id_proof = prefs.getString('id_proof');
    setState((){
      message = prefs.getString("message")!;

      iduploadedALready = id_proof.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getAddress(context);
    getCouponList();
    getResCartItem();
    getCartItem();
    getResStoreName();
    getStoreName();
    getid();
    ordercharg();
    servicecharge();

    firstDate = toDateMonthYear(DateTime.now());
    prepareData(firstDate);
    dateTimeSt =
    '${firstDate.year}-${(firstDate.month
        .toString()
        .length == 1) ? '0' + firstDate.month.toString() : firstDate
        .month}-${firstDate.day}';
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));

    dynamic date =
        '${firstDate.day}-${(firstDate.month
        .toString()
        .length == 1) ? '0' + firstDate.month.toString() : firstDate
        .month}-${firstDate.year}';

    hitDateCounter(date);


    getCatC();




  }

  void getResCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getResturantOrderList().then((value) {
      List<RestaurantCartItem> tagObjs =
      value.map((tagJson) => RestaurantCartItem.fromJson(tagJson)).toList();
      setState(() {
        cartListII = List.from(tagObjs);
        isCartFetch = true;
      });
      for (int i = 0; i < cartListII.length; i++) {
        print("RESTCART: "+'${cartListII[i].varient_id}');
        db
            .getAddOnListWithPrice(int.parse('${cartListII[i].varient_id}'))
            .then((values) {
          List<AddonCartItem> tagObjsd =
          values.map((tagJson) => AddonCartItem.fromJson(tagJson)).toList();
          setState(() {
            cartListII[i].addon = tagObjsd;
          });
        });
      }
      setState(() {
        isCartFetch = false;
      });
    });

    getCatC();
  }

  void prepareData(firstDate) {
    lastDate = toDateMonthYear(firstDate.add(Duration(days: 9)));
    dateList = getDateList(firstDate, lastDate);
  }

  void dispose() {
    super.dispose();
  }

  List<DateTime> feedInitialSelectedDates(int target, int calendarDays) {
    List<DateTime> selectedDates = [];

    for (int i = 0; i < calendarDays; i++) {
      if (selectedDates.length == target) {
        break;
      }
      DateTime date = firstDate.add(Duration(days: i));
      if (date.weekday != DateTime.sunday) {
        selectedDates.add(date);
      }
    }

    return selectedDates;
  }

  void getCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryAllRows().then((value) {
      List<CartItem> tagObjs =
      value.map((tagJson) => CartItem.fromJson(tagJson)).toList();

      if (tagObjs.isEmpty) {
        setState(() {});
      }
      else {
        setState(() {
          isCartFetch = false;
          cartListI.clear();
          cartListI = tagObjs;
        });
      }
    });


    print("CART: "+cartListI.toString());
  }


  void getAddress(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCartFetch = true;
      currency = prefs.getString('curency')!;
    });
    int? userId = prefs.getInt('user_id');
    var url = address_selection;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = json.decode(value.body);
        if (jsonData['status'] == "1" &&
            jsonData['data'] != null &&
            jsonData['data'] != 'null') {
          AddressSelected addressWelcome = AddressSelected.fromJson(jsonData);
          setState(() {
            isCartFetch = false;
            addressDelivery = addressWelcome.data!;
          });
        } else {
          setState(() {
            isCartFetch = false;
            //addressDelivery = null;
          });
          // Toast.show("Address not found!", context,
          //     duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          isCartFetch = false;
          //addressDelivery = null;
        });

        // Toast.show('No Address found!', context, duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      setState(() {
        isCartFetch = false;
        //addressDelivery = null;
      });
    });
  }

  void addOrMinusProduct2( product_id, product_name, unit, price,
      quantity, itemCount,
      varient_id, index, price_d) async {
    DatabaseHelper db = DatabaseHelper.instance;
    Future<int?> existing = db.getRestProductcount(int.parse(varient_id));
    existing.then((value) {
      var vae = {
        DatabaseHelper.productId: product_id,
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: price,
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.varientId: varient_id
      };

      if (value == 0) {
        db.insertRaturantOrder(vae);
        getResCartItem();
        getCatC();
      }
      else {
        if (itemCount==0) {
          db.deleteResProduct(varient_id).then((value) {
            db.deleteAddOn(varient_id);
          });
          getResCartItem();
          getCatC();
        }

        else {
          db.updateRestProductData(vae, varient_id);
          getResCartItem();
          getCatC();
        }
      }
      if (itemCount == 0) {
        getResCartItem();
        getCatC();
      }
    });

    getCatC();
    getCouponList();

  }

  Widget timewidget(BuildContext context, double itemHeight, double itemWidth) {
    return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(10.0),
            color: kCardBackgroundColor,
            child: Text('Order will be delivered instantly, given below is the maximum time',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    color: Color(0xff616161),
                    letterSpacing: 0.67)),
          ),
          Divider(
            color: kCardBackgroundColor,
            thickness: 6.7,
          ),
          (!isFetchingTime && radioList.length > 0)
              ? Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.only(right: 5, left: 5),
            child: GridView.builder(
              itemCount: radioList.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio:
                (itemWidth / itemHeight),
              ),
              controller: ScrollController(
                  keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      idd1 = index;
                    });
                  },
                  child: SizedBox(
                    height: 100,
                    child: Container(
                      margin: EdgeInsets.only(
                          right: 5,
                          left: 5,
                          top: 5,
                          bottom: 5),
                      height: 30,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: (idd1 == index)
                              ? kMainColor
                              : kWhiteColor,
                          shape: BoxShape.rectangle,
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color: (idd1 == index)
                                  ? kMainColor
                                  : kMainColor)),
                      child: Text(
                        '${radioList[index].toString()}',
                        style: TextStyle(
                            color: (idd1 == index)
                                ? kWhiteColor
                                : kMainTextColor,
                            fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              :
          Container(
            height: 120,
            width: MediaQuery
                .of(context)
                .size
                .width,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                isFetchingTime
                    ? CircularProgressIndicator()
                    : Container(
                  width: 0.5,
                ),
                isFetchingTime
                    ? SizedBox(
                  width: 10,
                )
                    : Container(
                  width: 0.5,
                ),
                Text(
                  (isFetchingTime)
                      ? 'Fetching time slot'
                      : 'No time slot present now check other date..',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kMainTextColor),
                )
              ],
            ),
          )
        ]
    );
  }

  Widget cartOrderItemListTile(BuildContext context,
      String title,
      dynamic price,
      int itemCount,
      dynamic qnty,
      dynamic unit,
      dynamic index,
      List<AddonCartItem> addon,) {
    String selected;
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 7.0, top: 10.3),
            child: ListTile(
              // contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),
                  // SizedBox(width: 30,),
                  Text(
                    '${currency} ${price}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),
                  Container(
                    height: 30.0,
                    //width: 76.7,
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: kMainColor),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            int addQ = int.parse(
                                '${cartListII[index].add_qnty}');
                            var price_d = double.parse(
                                '${cartListII[index].price}') /
                                addQ;
                            addQ--;
                            cartListII[index].price =
                            (price_d * addQ);
                            cartListII[index].add_qnty = addQ;

                            addOrMinusProduct2(
                            cartListII[index].varient_id,
                                cartListII[index].product_name,
                                cartListII[index].unit,
                                cartListII[index].price,
                                cartListII[index].qnty,
                                cartListII[index].add_qnty,
                                cartListII[index].varient_id,
                                index,
                                price_d);
                          }
                          ,
                          child: Icon(
                            Icons.remove,
                            color: kMainColor,
                            size: 20.0,
                            //size: 23.3,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text('$itemCount',
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption),
                        SizedBox(width: 8.0),
                        InkWell(
                          onTap: () {
                            int addQ = int.parse(
                                '${cartListII[index].add_qnty}');
                            var price_d = double.parse(
                                '${cartListII[index].price}') /
                                addQ;
                            addQ++;
                            cartListII[index].price =
                            (price_d * addQ);
                            cartListII[index].add_qnty = addQ;
                            addOrMinusProduct2(
                                cartListII[index].varient_id,
                                cartListII[index].product_name,
                                cartListII[index].unit,
                                cartListII[index].price,
                                cartListII[index].qnty,
                                cartListII[index].add_qnty,
                                cartListII[index].varient_id,
                                index,
                                price_d);
                          },
                          child: Icon(
                            Icons.add,
                            color: kMainColor,
                            size: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 14.2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          '${qnty} ${unit}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption,
                        ),
                      ),
                      // Spacer(),

                    ]),
              ),
            )),
        Visibility(
            visible: (addon.length > 0),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemBuilder: (context, indexd) {
                return Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${addon[indexd].addonName} ($currency ${addon[indexd]
                              .price})',
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(color: kMainTextColor),
                        ),
                        IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 15,
                            onPressed: () async {
                              deleteAddOn(addon[indexd].addonid);
                            })
                      ],
                    ),
                  ),
                );
              },
              itemCount: addon.length,
            ))
      ],
    );
  }


  void deleteAddOn(addonid) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAddOnId(int.parse(addonid)).then((value) {
      getResCartItem();
    });
  }
  void getCatC() async {


    if (cartListI.isNotEmpty) {
      DatabaseHelper db = DatabaseHelper.instance;
      db.calculateTotal().then((value) {
        var tagObjsJson = value as List;
        setState(() {
          if (value.isNotEmpty) {
            dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                totalAmount = totalAmount_1;
          } else {}
        });
      });
    }


    if (cartListII.isNotEmpty) {
      DatabaseHelper db = DatabaseHelper.instance;
      db.calculateTotalRest().then((value) {
        db.calculateTotalRestAdon().then((valued) {
          var tagObjsJson = value as List;
          var tagObjsJsond = valued as List;

          print("RESTCARTCAL:: "+tagObjsJson.toString());

          setState(() {
            dynamic totalAmount_1 = tagObjsJson[0]['Total'];
            dynamic totalAmount_2 = tagObjsJsond[0]['Total'];
            if(value.isEmpty){} else totalAmount = totalAmount_1;
              if(valued.isEmpty){} else totalAmount = totalAmount+totalAmount_2;
          });
        });
      });
    }

    if(radioId!=-1){
      if(couponL[radioId].type=='percentage') {
        setState(() {
          couponAmount = ((double.parse(couponL[radioId].amount)/100)*totalAmount);
        });
      }
      else{
        setState(() {
          couponAmount = double.parse(couponL[radioId].amount);
        });
      }
    }

  }

  void callThisMethod(bool isVisible) {
    getCouponList();
    getid();
    getCartItem();
    getResCartItem();
    setidpres(cartListI);
    getCatC();
    ordercharg();
    servicecharge();
    getAddress(context);


  }
  _showDialog() async{
    List<CartItem> cartbasket=[];
    for(int i=0;i<cartListI.length;i++){
      if(cartListI[i].isBasket==1) cartbasket.add(cartListI[i]);
    }


    await showDialog<String>(
      context: context,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          title:  Text('Please select'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: (){Navigator.of(context).pop('Cancel');},
              child:  Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: (){

                Navigator.of(context).pop('Accept');},
              child:  Text('Accept'),
            ),
          ],
          content: SingleChildScrollView(
            child: Material(
              child:  MyDialogContent(cart: cartbasket),
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
  }
  @override
  Widget build(BuildContext context) {


    getCatC();


    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 7;
    final double itemWidth = size.width / 2;
    return
      VisibilityDetector(
        key: Key(_oneViewCartState.id),
        onVisibilityChanged: (VisibilityInfo info) {
          bool isVisible = info.visibleFraction != 0;
          callThisMethod(isVisible);
        },
        child:
        Scaffold(
          appBar: AppBar(
            title:
            Text('Confirm Order', style: Theme
                .of(context)
                .textTheme
                .bodyText1),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, PageRoutes.instruction);
                  },
                  child: Text(
                    'Add Instructions',
                    style:
                    TextStyle(color: kMainColor, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: TextButton(
                  onPressed: () {
                    if (!showDialogBox) {
                      clearCart();
                    }
                  },
                  child: Text(
                    'Clear Cart',
                    style:
                    TextStyle(color: kMainColor, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
          body: (!isCartFetch && cartListI.isNotEmpty || cartListII.isNotEmpty)

              ?
          Stack(
            children: <Widget>[
              Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView(
                      shrinkWrap: true,
                      primary: true,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(20.0),
                          color: kCardBackgroundColor,
                        ),
                        Column(
                            children: <Widget>[ (cartListI.length > 0)
                                ? ListView.separated(
                                primary: false,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return cartOrderItemListTile1(
                                    context,
                                    currency,
                                    cartListI[index].isBasket,
                                    '${cartListI[index].product_name}',
                                    (cartListI[index].price /
                                        cartListI[index].add_qnty),
                                    cartListI[index].add_qnty,
                                    cartListI[index].qnty,
                                    cartListI[index].unit,
                                    cartListI[index].store_name,
                                    cartListI[index].is_id,
                                    cartListI[index].is_pres,
                                    index,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    color: kCardBackgroundColor,
                                    thickness: 1.0,
                                  );
                                },
                                itemCount: cartListI.length) : Container(),

                              (is_id_req == 1) ?
                              (iduploadedALready!.isNotEmpty)?

                              GestureDetector(
                                  onTap: () {
                                    __settingModalBottomSheet(context);
                                  },
                                  child:
                                  (iduploaded!=null)
                                      ?
                                  Container(
                                    height: 30.0,
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kCardBackgroundColor,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      'Id proof uploaded',
                                      style: TextStyle(color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),

                                  )
                                      :
                                  Container(
                                    height: 30.0,
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kCardBackgroundColor,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      'Upload ID Proof',
                                      style: TextStyle(color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),

                                  )
                              )
                                  :
                              Container()
                :
            Container(),
                              (is_pres_req == 1) ?
                              new GestureDetector(
                                  onTap: () {
                                    _settingModalBottomSheet(context);
                                  },
                                  child:
                                  (presuploaded != null) ?
                                  Container(
                                    height: 30.0,
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kCardBackgroundColor,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      'Prescription uploaded',
                                      style: TextStyle(color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  )
                                      :
                                  Container(
                                    height: 30.0,
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kCardBackgroundColor,
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: Text(
                                      'Upload Prescription',
                                      style: TextStyle(color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  )

                              )
                                  :
                              Container(
                              ),

                            ]
                        ),

                        (is_basket_req == 1) ?
                        new GestureDetector(
                            onTap: () {
                              _showDialog();
                            },
                            child:
                            Container(
                              height: 30.0,
                              padding: EdgeInsets.all(4),
                              margin: EdgeInsets.all(12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: kCardBackgroundColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                'Special Basket',
                                style: TextStyle(color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300),
                              ),
                            )
                        )
                            :
                        Container(
                        ),

                        (cartListII.isNotEmpty)
                            ?
                        ListView.separated(
                            primary: false,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return cartOrderItemListTile(
                                context,
                                '${cartListII[index].product_name}',
                                (double.parse(
                                    '${cartListII[index].price}') /
                                    int.parse(
                                        '${cartListII[index].add_qnty}')),
                                int.parse('${cartListII[index].add_qnty}'),
                                cartListII[index].qnty,
                                cartListII[index].unit,
                                index,
                                // plus(index),
                                cartListII[index].addon,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: kCardBackgroundColor,
                                thickness: 1.0,
                              );
                            },
                            itemCount: cartListII.length)
                            : Container(),

                        // Divider(
                        //   color: kCardBackgroundColor,
                        //   thickness: 6.7,
                        // ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(10.0),
                          color: kCardBackgroundColor,
                          child: Text('Order will be delivered instantly, given below is the maximum time',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                  color: Color(0xff616161),
                                  letterSpacing: 0.67)),
                        ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10.0),
              color: kCardBackgroundColor,
              child: Text('1) Order will be delivered within 30-60 mins.\n2) Order from 2-3 different shops will be delivered in 1-2 hour.\n3) Restraunt orders will be delivered instantly.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6!
                      .copyWith(
                      color: Color(0xff616161),
                      letterSpacing: 0.67)),
            ),

                        (cartListI.isNotEmpty)
                            ?
                        //timewidget(context, itemHeight, itemWidth)
                        Container()
                            :
                        Container(),
                        Container(
                          height: 15.0,
                          color: kCardBackgroundColor,
                        ),
                        ExpansionTile(
                          title: Text('Promo Code'),
                          children: [
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
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

                                                    (couponL[t].cart_value<=totalAmount)?
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                                '${couponL[t].coupon_code}\n${couponL[t].coupon_description}\nmin cart value: ${couponL[t].cart_value}')),
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

                                                                    selectedcoupon = couponL[t];
                                                                    // setProgressText =
                                                                    // 'Applying coupon please wait!....';
                                                                    //showDialogBox =true;
                                                                    //appCoupon(couponL[t].coupon_code);
                                                                  } else {
                                                                  }
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  radioId = -1;
                                                                  selectedcoupon=null;
                                                                  couponAmount = 0.0;
                                                                  // showDialogBox =
                                                                  // true;
                                                                  //appCoupon(couponL[t].coupon_code);
                                                                });
                                                              }
                                                            })
                                                      ],
                                                    )
                                                        :
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                            child: Text(
                                                              '${couponL[t].coupon_code}\n${couponL[t].coupon_description}\nmin cart value: ${couponL[t].cart_value}',
                                                              style: TextStyle(color: Colors.red),
                                                            )),
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

                                      (couponL != null && couponL.length > 0)?
                                          Text(""):Text("No Coupon available"),
                                      SizedBox(
                                        height: 100,
                                      ),
                                    ])),
                          ],
                        ),

                        Divider(
                          color: kCardBackgroundColor,
                          thickness: 6.7,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20.0),
                          child: Text('PAYMENT INFO',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: kDisabledColor)),
                          color: Colors.white,
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Sub Total',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${totalAmount.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ),

                        (surge_charges>0)?
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Surge Charge',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${surge_charges.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ): Container(),
                        (night_charges>0)?
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Night Charge',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${night_charges.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ): Container(),
                        (conv_charges>0)?
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Convenience Charge',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${conv_charges}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ): Container(),
                        (couponAmount>0)?
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Coupon Discount',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '- $currency ${couponAmount.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ): Container(),

                        (storedeliveryCharge==0.0)?
                        Container(): Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Delivery Charges',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${storedeliveryCharge.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                )
                              ]),
                        ),

                        (cartListII.isNotEmpty && packcharge>0)?
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Packaging Charges',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                                Text(
                                  '$currency ${packcharge.toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        )
                            :
                        Container(),

                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 20.0),
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Amount to Pay',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$currency '
                                      '${((totalAmount - couponAmount) + deliveryCharge + storedeliveryCharge + packcharge + surge_charges + night_charges + conv_charges).toStringAsFixed(2)}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ]),
                        ),

                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                top: 13.0,
                                bottom: 13.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color: Color(0xffc4c8c1),
                                      size: 13.3,
                                    ),
                                    SizedBox(
                                      width: 11.0,
                                    ),
                                    Text('Deliver to',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                            color: kDisabledColor,
                                            fontWeight: FontWeight.bold)),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                                  return SavedAddressesPage(
                                                      "");
                                                })).then((value) {
                                          getAddress(context);
                                        });
                                      },
                                      child: Text('CHANGE',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                              color: kMainColor,
                                              fontWeight:
                                              FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 13.0,
                                ),
                                Text(
                                    '${addressDelivery?.address != null
                                        ? '${addressDelivery?.address}'
                                        : '' }'
                                    ,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                        fontSize: 11.7,
                                        color: Color(0xffb7b7b7))),

                                Text(
                                    '${Errormessage != ''
                                        ? '${Errormessage}'
                                        : '' }'
                                    ,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                        fontSize: 11.7,
                                        color: Colors.red))
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                primary: kMainColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 150, vertical: 20),
                                textStyle: TextStyle(color: kWhiteColor,
                                    fontWeight: FontWeight.w400)),

                            onPressed: () {
                              if(addressDelivery!=null) {
                                if (cartListI.isNotEmpty) {
                                  if (is_id_req == 1 &&
                                      iduploaded != null) createCart(context);
                                  else if(is_id_req == 1 &&
                                      iduploaded == null) {
                                    Fluttertoast.showToast(
                                      msg: "Upload Id Proof",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  }

                                  if (is_pres_req == 1 &&
                                      presuploaded != null) createCart(context);
                                  else if(is_pres_req == 1 &&
                                      presuploaded == null) {
                                    Fluttertoast.showToast(
                                      msg: "Upload Prescription",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                  }

                                  if (is_pres_req == 0 &&
                                      is_id_req == 0) createCart(context);
                                  if (is_pres_req == 0 && is_id_req == 1 &&
                                      iduploaded != null) createCart(context);
                                  if (is_id_req == 0 && is_pres_req == 1 &&
                                      presuploaded != null) createCart(context);
                                }
                                else if (cartListII.isNotEmpty) {
                                  createResCart(context);
                                }
                              }
                              else{
                                Fluttertoast.showToast(
                                    msg: "Select Delivery Address",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              }
                            },
                            child: Text("Pay $currency "+
                                '${((totalAmount - couponAmount) + deliveryCharge + storedeliveryCharge + packcharge + surge_charges + night_charges + conv_charges).toStringAsFixed(2)}',
                            ),
                        )
                      ],
                    ),
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
              Positioned.fill(
                  child: Visibility(
                    visible: showDialogBox,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height - 100,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )),


            ],
          )
              :
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height - 64,
            alignment: Alignment.center,
            child: isCartFetch
                ? CircularProgressIndicator()
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'No item in cart\nClick to shop now',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    )),
                ElevatedButton(
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
                    // clearCart();
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                          return HomeOrderAccount(0,1);
                        }), (Route<dynamic> route) => true);
                  },
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.w400),
                  ),
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
        ),
      );
  }

  void createResCart(BuildContext context) async {

    iduploaded = null;
    presuploaded = null;

    if (cartListII.length > 0) {
      if (totalAmount > 0.0 && addressDelivery != null) {
        var url = returant_order;
        SharedPreferences pref = await SharedPreferences.getInstance();
        int? userId = pref.getInt('user_id');
        String? vendorId = pref.getString('res_vendor_id');
        String? ui_type = "2";
        String? instruction = pref.getString("r_instructions");

        List<OrderArray> orderArray = [];
        List<OrderAdonArray> orderAddonArray = [];
        for (RestaurantCartItem item in cartListII) {
          orderArray.add(OrderArray(
              int.parse('${item.add_qnty}'), int.parse('${item.varient_id}')));
          if (item.addon.length > 0) {
            for (AddonCartItem addItem in item.addon) {
              orderAddonArray
                  .add(OrderAdonArray(int.parse('${addItem.addonid}')));
            }
          }
        }

        print(
            '$userId $vendorId ${orderArray.toString()} ${orderAddonArray
                .toString()}');

        Uri myUri = Uri.parse(url);
        http.post(myUri, body: {
          'user_id': '${userId}',
          'vendor_id': vendorId,
          'order_array': orderArray.toString(),
          'instruction':instruction.toString(),
          'order_array1':
          (orderAddonArray.length > 0) ? orderAddonArray.toString() : '',
          'ui_type': ui_type
        }).then((value) {
          print('${value.statusCode} ${value.body}');
          if (value.statusCode == 200) {
            var jsonData = jsonDecode(value.body);
            if (jsonData['status'] == "1") {
              // Toast.show(jsonData['message'], context,
              //     duration: Toast.LENGTH_SHORT);
              CartDetail details = CartDetail.fromJson(jsonData['data']);

              pref.remove("r_instructions");
              if(radioId!=-1){
                appCoupon( selectedcoupon!.coupon_code , details.cart_id);
              }


              getVendorPayment(vendorId!, details,((totalAmount - couponAmount) + deliveryCharge + storedeliveryCharge + packcharge + surge_charges + night_charges + conv_charges).toStringAsFixed(2));
            } else {
              // Toast.show(jsonData['message'], context,
              //     duration: Toast.LENGTH_SHORT);
              setState(() {
                showDialogBox = false;
              });
            }
//        print('resp value - ${value.body}');

          } else {
            setState(() {
              showDialogBox = false;
            });
          }
        }).catchError((_) {
          setState(() {
            showDialogBox = false;
          });
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
        if (addressDelivery != null) {
          // Toast.show('Please add something in your cart to proceed!', context,
          //     duration: Toast.LENGTH_SHORT);
        } else {
          // Toast.show('Please add your delivery address to continue shopping..',
          //     context,
          //     duration: Toast.LENGTH_SHORT);
        }
      }
    } else {
      setState(() {
        showDialogBox = false;
      });
      // Toast.show('Please add some items into cart!', context,
      //     duration: Toast.LENGTH_SHORT);
    }
  }

  void getVendorPayment(String vendorId, CartDetail details,totalAmount) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency')!;
    });
    print("object**"+maxincash.toString());

    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<PaymentVia> tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PaymentRestPage(vendorId, details.order_id, details.cart_id,
                double.parse(totalAmount.toString()), tagObjs , maxincash);
          }));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void uploadid(BuildContext context) async {
    var url = idupload;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
       'id_proof': iduploaded
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == 1) {
                    pref.setString("id_proof", iduploaded.toString());
                    print(iduploaded.toString());

                    setState((){
                      iduploadedALready = iduploaded.toString();
                      iduploaded = null;
                    });
        } else {}
      } else {
      }
    }).catchError((_) {});
  }

  void createCart(BuildContext context) async {
   if(iduploaded!=null) uploadid(context);

    if (cartListI.length > 0) {
      if (radioList.length > 0) {
        if (totalAmount > 0.0) {
          var url = addToCart;

          SharedPreferences pref = await SharedPreferences.getInstance();
          int? userId = pref.getInt('user_id');
          String? vendorId = pref.getString('vendor_id');
          String? ui_type = "1";
          String? instruction = pref.getString("instructions");

          List<OrderArrayGrocery> orderArray = [];
           for (CartItem item in cartListI) {
             orderArray.add(OrderArrayGrocery(int.parse('${item.add_qnty}'),
                 int.parse('${item.varient_id}'),int.parse('${item.addedBasket}')));
           }


          print("ins:    "+instruction.toString());
          Uri myUri = Uri.parse(url);
          http.post(myUri, body: {
            'user_id': userId.toString(),
            'order_array': orderArray.toString(),
            'delivery_date': dateTimeSt,
            'instruction':instruction.toString(),
            'time_slot': '${radioList[idd1]}',
            'ui_type': ui_type,
            if(presuploaded!=null)  'pres':presuploaded

          }).then((value) {
            print('order' + value.body);
            if (value.statusCode == 200) {
              var jsonData = jsonDecode(value.body);
              if (jsonData['status'] == "1")
              {
                // Toast.show(jsonData['message'], context,
                //     duration: Toast.LENGTH_SHORT);
                CartDetail details = CartDetail.fromJson(jsonData['data']);

                if(radioId!=-1){
                  appCoupon( selectedcoupon!.coupon_code , details.cart_id);
                }


                getVendorPayment2(vendorId!, details, orderArray.toString(),((totalAmount - couponAmount) + deliveryCharge + storedeliveryCharge + packcharge + surge_charges + night_charges + conv_charges).toStringAsFixed(2));

                pref.remove("instructions");
                setState(() {
                  iduploaded = null;
                  presuploaded = null;
                });


              }
              else if(jsonData['status'] == "0"){
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
              else {
                // Toast.show(jsonData['message'], context,
                //     duration: Toast.LENGTH_SHORT);
                Fluttertoast.showToast(
                    msg: jsonData['message'],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                setState(() {
                  showDialogBox = false;
                });
              }
            } else {
              setState(() {
                showDialogBox = false;
              });
            }
          }).catchError((_) {
            setState(() {
              showDialogBox = false;
            });
          });
        } else {
          setState(() {
            showDialogBox = false;
          });
          if (addressDelivery != null) {
            // Toast.show('Please add something in your cart to proceed!', context,
            //     duration: Toast.LENGTH_SHORT);
          } else {
            // Toast.show(
            //     'Please add your delivery address to continue shopping..',
            //     context,
            //     duration: Toast.LENGTH_SHORT);
          }
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        // Toast.show('Please select a delivery time to continue!', context,
        //     duration: Toast.LENGTH_SHORT);
      }
    } else {
      setState(() {
        showDialogBox = false;
      });
      // Toast.show('Please add some items into cart!', context,
      //     duration: Toast.LENGTH_SHORT);
    }
  }

  void getVendorPayment2(String vendorId, CartDetail details,
      String orderArray,totalAmount) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency')!;
    });


    var url = paymentvia;
    var client = http.Client();
    Uri myUri = Uri.parse(url);

    client.post(myUri, body: {'vendor_id': '${vendorId}'}).then((value) {
      print('${value.statusCode} - ${value.body}');
      if (value.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<PaymentVia> tagObjs = tagObjsJson
              .map((tagJson) => PaymentVia.fromJson(tagJson))
              .toList();

          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PaymentPage(
                vendorId,
                details.order_id,
                details.cart_id,
                double.parse(totalAmount.toString()),
                tagObjs,
                orderArray,
                maxincash
            );
          }));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void addOrMinusProduct(is_id, is_pres, isBasket,addedbas, product_name, unit, price,
      quantity, itemCount,
      varient_image, varient_id, vendorid,storename) async {
    DatabaseHelper db = DatabaseHelper.instance;

    db.getcount(varient_id).then((value) {
      print('value d - $value');
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.storeName: storename,
        DatabaseHelper.vendor_id: vendorid,
        DatabaseHelper.price: price,
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.is_id: is_id,
        DatabaseHelper.is_pres: is_pres,
        DatabaseHelper.isBasket: isBasket,
        DatabaseHelper.addedBasket: addedbas,
        DatabaseHelper.varientId: varient_id
      };
      if (value == 0) {
        db.getCountVendor()
            .then((value) {
          if (value != null && value < 3) {
            db.insert(vae);
            getCartItem();
            getCatC();
          }
        }
        );
      } else {
        if (itemCount == 0) {
          print('Delete - $varient_id');

          db.delete(varient_id);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeOrderAccount(3,1)),
                  (Route<dynamic> route) => false,
            );
          getCartItem();
          getCatC();

        } else {
          db.updateData(vae, int.parse('${varient_id}')).then((vay) {
            print('vay - $vay');
          });
          getCartItem();
          getCatC();
        }
      }
    }).catchError((e) {
      print(e);
    });

    getCatC();
    getCouponList();

  }

  Widget cartOrderItemListTile1(BuildContext context,
      currency,
      isbasket,
  String title,
      dynamic price,
      int itemCount,
      int qnty,
      dynamic unit,
      dynamic store_name,
      dynamic is_id,
      dynamic is_pres,
      dynamic index) {

    String selected;
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 7.0, top: 13.3),
            child: ListTile(
              title: 
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    store_name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: kMainTextColor),
                  ),

                  Text(
                    title,
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: kMainTextColor),
                  ),

                  Text(
                    '${currency} ${price}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: kMainTextColor),
                  ),
                ],
              ),

             ]
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 14.2),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[

                      Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 18.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          '${qnty} ${unit}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .caption,
                        ),

                      ),
                      Container(
                        height: 30.0,
                        //width: 76.7,
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: kMainColor),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  var price_d = cartListI[index].price /
                                      cartListI[index].add_qnty;
                                  cartListI[index].add_qnty--;
                                  cartListI[index].price = (price_d *
                                      cartListI[index].add_qnty);
                                  addOrMinusProduct(
                                    cartListI[index].is_id,
                                    cartListI[index].is_pres,
                                    cartListI[index].isBasket,
                                  cartListI[index].addedBasket,
                                  cartListI[index].product_name,
                                      cartListI[index].unit,
                                      cartListI[index].price,
                                      cartListI[index].qnty,
                                      cartListI[index].add_qnty,
                                      cartListI[index].product_img,
                                      cartListI[index].varient_id,
                                    cartListI[index].vendor_id,
                                    cartListI[index].store_name
                                  );
                                });
                              },
                              child: Icon(
                                Icons.remove,
                                color: kMainColor,
                                size: 20.0,
                                //size: 23.3,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text('$itemCount',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption),
                            SizedBox(width: 8.0),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  var price_d = cartListI[index].price /
                                      cartListI[index].add_qnty;
                                  cartListI[index].add_qnty++;
                                  cartListI[index].price = (price_d *
                                      cartListI[index].add_qnty);
                                  addOrMinusProduct(
                                      cartListI[index].is_id,
                                      cartListI[index].is_pres,
                                      cartListI[index].isBasket,
                                      cartListI[index].addedBasket,
                                      cartListI[index].product_name,
                                      cartListI[index].unit,
                                      cartListI[index].price,
                                      cartListI[index].qnty,
                                      cartListI[index].add_qnty,
                                      cartListI[index].product_img,
                                      cartListI[index].varient_id,
                                      cartListI[index].vendor_id,
                                      cartListI[index].store_name
                                  );
                                });
                              },
                              child: Icon(
                                Icons.add,
                                color: kMainColor,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Spacer(),
                    ]),
              ),
            )),
              SizedBox(height: 16,),

      ],
    );
  }
  //********************** IMAGE PICKER
  Future imageSelector(BuildContext context, String pickerType) async {
    XFile? imageFile = null;
    ImagePicker picker = new ImagePicker();
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        imageFile = (await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90));
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = (await picker.pickImage(
            source: ImageSource.camera, imageQuality: 90));
        break;
    }

    if (imageFile != null) {
      presuploaded=imageFile.path;
      List<int> imageBytes = await imageFile.readAsBytes();

      dynamic imageS = base64Encode(imageBytes);
      presuploaded = imageS;

      print("You selected  image : " + imageFile.path);
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });

    } else {
      print("You have not taken image");
    }
  }

  Future imageSelector1(BuildContext context, String pickerType) async {
    XFile? imageFile = null;
    ImagePicker picker = new ImagePicker();
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        imageFile = (await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 90));
        break;

      case "camera": // CAMERA CAPTURE CODE
        imageFile = (await picker.pickImage(
            source: ImageSource.camera, imageQuality: 90));
        break;
    }

    if (imageFile != null) {
      iduploaded=imageFile.path;
      List<int> imageBytes = await imageFile.readAsBytes();

      dynamic imageS = base64Encode(imageBytes);
      iduploaded = imageS;

      print("You selected  image : " + imageFile.path);
      setState(() {
        debugPrint("SELECTED IMAGE PICK   $imageFile");
      });
    } else {
      print("You have not taken image");
    }
  }

  // Image picker
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    title: new Text('Gallery'),
                    onTap: () => {
                      imageSelector(context, "gallery"),
                      Navigator.pop(context),
                    }),
                new ListTile(
                  title: new Text('Camera'),
                  onTap: () => {
                    imageSelector(context, "camera"),
                    Navigator.pop(context)
                  },
                ),
              ],
            ),
          );
        });
  }


  void __settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    title: new Text('Gallery'),
                    onTap: () => {
                      imageSelector1(context, "gallery"),
                      Navigator.pop(context),
                    }),
                new ListTile(
                  title: new Text('Camera'),
                  onTap: () => {
                    imageSelector1(context, "camera"),
                    Navigator.pop(context)
                  },
                ),
              ],
            ),
          );
        });
  }


  void hitDateCounter(date) async {
    setState(() {
      isFetchingTime = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? vendorId = pref.getString('vendor_id');
    var url = timeSlots;
    Uri myUri = Uri.parse(url);
    http.post(myUri,
        body: {'vendor_id': vendorId, 'selected_date': '$date'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var rdlist = jsonData['data'] as List;
          print('list $rdlist');
          setState(() {
            radioList.clear();
            radioList = rdlist;
          });
        } else {
          setState(() {
            radioList = [];
          });
          // Toast.show(jsonData['message'], context,
          //     duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          radioList = [];
          // radioList = rdlist;
        });
      }
      setState(() {
        isFetchingTime = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchingTime = false;
      });
      print(e);
    });
  }

  void clearCart() async {
    setState(() {
      isCartFetch = true;
    });
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll().then((value) {
      cartListI.clear();
      getCartItem();
    });

    db.deleteAllRestProdcut().then((value) {
      db.deleteAllAddOns().then((values) {
        cartListII.clear();
        getResCartItem();
      });
    });
  }

  void setidpres(List<CartItem> cartListI) {
    setState(() {
      is_id_req=0;
      is_pres_req=0;
    });
    if(cartListI.isNotEmpty) {
      for (int i = 0; i < cartListI.length; i++) {
        if (cartListI[i].is_pres == 1) {
          setState(() {
            is_pres_req = 1;
          });
        }
        if (cartListI[i].is_id == 1) {
          checkId();
        }
      }
    }

    if(cartListI.isNotEmpty) {
      outerloop:
      for (var i = 0; i < cartListI.length; i++) {
        if (cartListI[i].isBasket == 1) {
          setState(() {
            is_basket_req = 1;
          });
          break outerloop;
        }
      }
    }
  }

  void getCouponList() async {
    getCartItem();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? vendorId ="";
    if(cartListI.isNotEmpty) {
      vendorId = '54';
    }
    else {
      vendorId = preferences.getString('vendor_id');
    }
    List<OrderArrayGrocery> orderArray = [];
    for (CartItem item in cartListI) {
      orderArray.add(OrderArrayGrocery(int.parse('${item.add_qnty}'),
          int.parse('${item.varient_id}'),int.parse('${item.addedBasket}')));
    }


    setState(() {
      currency = preferences.getString('curency')!;
    });
      var url = couponList;
      Uri myUri = Uri.parse(url);
      http.post(myUri, body: {
        'cart_value': '$totalAmount',
        'vendor_id': '$vendorId',
        'order_array': orderArray.toString(),
      }).then((value) {
        print("COUPON "+value.body);

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

  void appCoupon(couponCode,cart_id) {
    var url = applyCoupon;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'coupon_code': couponCode.toString(),
      'cart_id': cart_id.toString()
    }).then((value) {
      print(value.body.toString());

      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
      }});
  }

  Future<void> checkId() async {
    var url = checkid;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
    }).then((value) {
      var jsonData = jsonDecode(value.body);
      if (jsonData['status'] == 0) {
        setState(() {
          is_id_req = 1;
        });
      }
      else{
        setState(() {
          is_id_req = 0;
        });
      }
    });
  }

  Future<void> ordercharg() async {
    getCartItem();
    getResCartItem();

    var url = ordercharges;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');

    List<OrderArrayGrocery> orderArray = [];
    for (CartItem item in cartListI) {
      orderArray.add(OrderArrayGrocery(int.parse('${item.add_qnty}'),
          int.parse('${item.varient_id}'),int.parse('${item.addedBasket}')));
    }

    List<OrderArray> restorderArray = [];
    List<OrderAdonArray> orderAddonArray = [];
    for (RestaurantCartItem item in cartListII) {
      restorderArray.add(OrderArray(
          int.parse('${item.add_qnty}'), int.parse('${item.varient_id}')));
      if (item.addon.length > 0) {
        for (AddonCartItem addItem in item.addon) {
          orderAddonArray
              .add(OrderAdonArray(int.parse('${addItem.addonid}')));
        }
      }
    }


    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
      'order_array': orderArray.toString(),
      'rest_order_array': restorderArray.toString(),

    }).then((value) {
      print("ORDERCHARGE  "+value.body);
      var jsonData = jsonDecode(value.body);
      if (jsonData['status'] == '1') {
        setState(() {
          storedeliveryCharge = jsonData['delivery_charges'];
        });
      }
      else{
        setState(() {
          storedeliveryCharge = 0.0;
          Errormessage = jsonData['meesage'];
        });
      }
    });

  }
  void servicecharge() async {
    var url = servicecharges;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user_id');

    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': userId.toString(),
    }).then((value) {
      var jsonData = jsonDecode(value.body);

      print("SERVICECharege "+value.body.toString());

      if (jsonData['status'] == "1") {
        setState(() {
          surge_charges = jsonData['surge_charges'];
          night_charges = jsonData['night_charges'];
          conv_charges = jsonData['conv_charges'];
          maxincash = jsonData['maxincash'];
        });
      }
      else{
        setState(() {
          surge_charges = 0;
          night_charges = 0;
          conv_charges = 0;
        });
      }
    });
  }

}


class MyDialogContent extends StatefulWidget {
  MyDialogContent({
    Key? key,
    required this.cart,
  }): super(key: key);

  final List<CartItem> cart;

  @override
  _MyDialogContentState createState() => new _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {

  @override
  void initState(){
    super.initState();
  }

  _getContent(){
    bool _selectedIndex = false;

    if (widget.cart.length == 0){
      return new Container();
    }

    return Column(
        children: List<CheckboxListTile>.generate(
            widget.cart.length,
                (int index){
                  if(widget.cart[index].addedBasket==0){
                    _selectedIndex= false;
                  }

                  return  CheckboxListTile(
                value: (widget.cart[index].addedBasket==0)?false:true,
                ///groupValue: _selectedIndex,
                title: Text(widget.cart[index].product_name),
                onChanged: (bool? value) {
                  setState((){
                    (value==true)?
                    widget.cart[index].addedBasket=1
                        :
                    widget.cart[index].addedBasket=0;
                  });
                },
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }


}