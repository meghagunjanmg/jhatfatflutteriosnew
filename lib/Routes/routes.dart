import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatfat/Auth/login_navigator.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/about_us_page.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/support_page.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/tnc_page.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/home2.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/order_placed_map.dart';
import 'package:jhatfat/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:jhatfat/Maps/UI/location_page.dart';
import 'package:jhatfat/parcel/DropMap.dart';
import 'package:jhatfat/parcel/ParcelLocation.dart';
import 'package:jhatfat/parcel/PickMap.dart';
import 'package:jhatfat/restaturantui/pages/rasturantlistpage.dart';
import 'package:jhatfat/settingpack/settings.dart';
import 'package:jhatfat/subscription/subscription.dart';
import 'package:jhatfat/walletrewardreffer/reffer/ui/reffernearn.dart';
import 'package:jhatfat/walletrewardreffer/reward/ui/reward.dart';
import 'package:jhatfat/walletrewardreffer/wallet/ui/wallet.dart';

import '../Pages/oneViewCart.dart';
import '../restaturantui/ui/resturanthome.dart';

class PageRoutes {
  static const String locationPage = 'location_page';
  static const String subscription = 'subscription';
  static const String livetrack = 'livetrack';
  static const String homeOrderAccountPage = 'home_order_account';
  static const String homeOrderAccountPage3 = 'homeOrderAccountPage3';
  static const String homePage = 'home_page';
  static const String accountPage = 'account_page';
  static const String orderPage = 'order_page';
  static const String tncPage = 'tnc_page';
  static const String aboutUsPage = 'about_us_page';
  static const String settings = 'settings';
  static const String savedAddressesPage = 'saved_addresses_page';
  static const String supportPage = 'support_page';
  static const String loginNavigator = 'login_navigator';
  static const String orderMapPage = 'order_map_page';
  static const String viewCart = 'view_cart';
  static const String restviewCart = 'restviewCart';
  static const String orderPlaced = 'order_placed';
  static const String paymentMethod = 'payment_method';
  static const String wallet = 'wallet';
  static const String reward = 'reward';
  static const String reffernearn = 'reffernearn';
  static const String returanthome = 'returanthome';
  static const String pharmacart = 'pharmacart';
  static const String offers = 'offers';
  static const String dropmap = 'DropMap';
  static const String pickmap = 'pickmap';
  static const String parcellocation = 'parcellocation';
  static const String restro = 'restro';

  Map<String, WidgetBuilder> routes() {
    return {
      homeOrderAccountPage: (context) => HomeOrderAccount(0),
      homeOrderAccountPage3: (context) => HomeOrderAccount(3),
      subscription: (context) => Subscription(),
      homePage: (context) => HomePage2(),
      orderPage: (context) => OrderPage(),
      accountPage: (context) => AccountPage(),
      tncPage: (context) => TncPage(),
      aboutUsPage: (context) => AboutUsPage(),
      supportPage: (context) => SupportPage(),
      loginNavigator: (context) => LoginNavigator(),
      orderMapPage: (context) => OrderMapPage(),
      viewCart: (context) => oneViewCart(),
      wallet: (context) => Wallet(),
      reward: (context) => Reward(),
      reffernearn: (context) => RefferScreen(),
      settings: (context) => Settings(),
      restviewCart: (context) => oneViewCart(),
      offers: (context) => OfferScreen(),
      parcellocation: (context) => ParcelLocation(),
      restro: (context) => Restaurant("Urbanby Resturant"),
      pickmap: (context) => PickMap(30.3165, 78.0322),
      dropmap: (context) => DropMap(30.3165, 78.0322),
      locationPage: (context) => LocationPage(30.3165, 78.0322),
    };
  }
}
