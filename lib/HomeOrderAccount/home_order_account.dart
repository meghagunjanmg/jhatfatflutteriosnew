import 'dart:convert';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jhatfat/bean/adminsetting.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:jhatfat/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:jhatfat/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';

import '../Pages/oneViewCart.dart';
import '../bean/bannerbean.dart';
import '../parcel/ParcelLocation.dart';
import 'Home/UI/home2.dart';

class HomeStateless extends StatelessWidget {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeOrderAccount(this._currentIndex),
    );
  }
}

class HomeOrderAccount extends StatefulWidget {
  int _currentIndex = 0;

  HomeOrderAccount(this._currentIndex);

  @override
  _HomeOrderAccountState createState() => _HomeOrderAccountState(_currentIndex);
}

class _HomeOrderAccountState extends State<HomeOrderAccount> {
  int _currentIndex = 0;
  double bottomNavBarHeight = 60.0;
  late CircularBottomNavigationController _navigationController;
  String ClosedImage = '';
  List<BannerDetails> ClosedBannerImage = [];
  Adminsetting? admins;

  _HomeOrderAccountState(this._currentIndex);

  var lat = 0.0;
  var lng = 0.0;
  String? cityName = 'NO LOCATION SELECTED';

  @override
  void initState() {
    super.initState();
    _requestPermission();
    getData();
    _navigationController =
    new CircularBottomNavigationController(_currentIndex);
    getCurrency();
  }

  void getData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      cityName = pref.getString("addr")!;
      lat = double.parse(pref.getString("lat")!);
      lng = double.parse(pref.getString("lng")!);

      pref.setString("lat", lat.toString());
      pref.setString("lng", lng.toString());
      pref.setString("addr", cityName.toString());

      print("HOME_ORDER" + lat.toString() + lng.toString());
    } catch (e) {
      print(e);
    }
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }


  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;

    var client = http.Client();
    Uri myUri = Uri.parse(currencyUrl);
    client.get(myUri).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {
      print(e);
    });
  }

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.home, "Home", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.restaurant, "Resturant", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
   ///  new TabItem(Icons.reorder, "Order", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.pin_drop, "Pick & Drop", Colors.blue,labelStyle: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)),
     new TabItem(Icons.shopping_cart, "Cart", Colors.blue, labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 10)),
  ]);

  final List<Widget> _children = [
     HomePage2(),
     Restaurant("Urbanby Resturant"),
     ///OrderPage(),
     ParcelLocation(),

        oneViewCart(),
    // ViewCart(),

  ];

  void onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
     Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }

  Widget bottomNav(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: kWhiteColor,
      child: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: 45,
        circleSize: 40,
        barBackgroundColor: kWhiteColor,
        iconsSize: 20,
        circleStrokeWidth: 5,
        animationDuration: const Duration(milliseconds: 300),
        selectedCallback: (int? selectedPos) {
          setState(() {
            _currentIndex = selectedPos!;
          });

          if(selectedPos==3){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeOrderAccount(3)),
                    (Route<dynamic> route) => false);
          }
        },
      ),
    );

  }
}
