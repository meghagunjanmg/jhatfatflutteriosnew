import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/pages/restaurant.dart';

import '../HomeOrderAccount/Home/UI/appcategory/appcategory.dart';
import '../bean/venderbean.dart';
import '../restaturantui/ui/resturanthome.dart';

class SubscribeStore extends StatefulWidget {

  SubscribeStore();

  @override
  State<StatefulWidget> createState() {
    return _SubscribeStore();
  }

}

class _SubscribeStore extends State<SubscribeStore> {
  bool isFetchStore = false;
  List<NearStores> nearStores = [];
  List<NearStores> nearStoresSearch = [];
  double userLat = 0.0;
  double userLng = 0.0;
  String message='';

  @override
  initState() {
    super.initState();
    getShareValue();
    hitService();
  }

  void hitService() async {
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = subsstore;
    Map<String, String> queryParams = {
      'lat':  prefs.getString('lat').toString(),
      'lng':  prefs.getString('lng').toString()
    };
    Uri myUri = Uri.parse(url);
    final finalUri = myUri.replace(queryParameters: queryParams); //USE THIS

    http.get(finalUri).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        print('Response Body: - ${value.body}');
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<NearStores> tagObjs = tagObjsJson
              .map((tagJson) => NearStores.fromJson(tagJson))
              .toList();
          setState(() {
            isFetchStore = false;
            nearStores.clear();
            nearStoresSearch.clear();
            nearStores = tagObjs;
            nearStoresSearch = List.from(nearStores);
          });
        }
        else {
          setState(() {
            isFetchStore = false;
          });
        }
      } else {
        setState(() {
          isFetchStore = false;
        });
      }
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
      Timer(Duration(seconds: 5), () {
        hitService();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            "Subscribed stores",
            style: Theme
                .of(context)
                .textTheme
                .bodyText1,
          ),
          bottom: PreferredSize(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                height: 52,
                padding: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                    color: scaffoldBgColor,
                    borderRadius: BorderRadius.circular(50)),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: kHintColor,
                    ),
                    hintText: 'Search Store...',
                  ),
                  cursorColor: kMainColor,
                  autofocus: false,
                  onChanged: (value) {
                    nearStores = nearStoresSearch
                        .where((element) =>
                        element.vendor_name
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  },
                ),
              ),
              preferredSize:
              Size(MediaQuery
                  .of(context)
                  .size
                  .width * 0.85, 52)),
        ),
      ),
      body:
      Column(
        children: [
      Container(
        height: MediaQuery
            .of(context)
            .size
            .height - 200
        ,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20.0),
                child: Text(
                  '${nearStores.length} Store found',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: kHintColor, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              (nearStores != null && nearStores.length > 0)
                  ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.vertical,
                    itemCount: nearStores.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if ((nearStores[index].online_status ==
                              "off" ||
                              nearStores[index].online_status == "Off" ||
                              nearStores[index].online_status ==
                                  "OFF")) {
                          }
                          else if(nearStores[index].inrange == 0){
                          }
                          else {
                            hitNavigator(
                                context,
                                nearStores[index]);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Material(
                          elevation: 2,
                          shadowColor: white_color,
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                width:
                                MediaQuery.of(context).size.width,
                                color: white_color,
                                padding: EdgeInsets.only(
                                    left: 20.0, top: 15, bottom: 15),
                                child: Row(
                                  children: <Widget>[
                                    Image.network(
                                      imageBaseUrl +
                                          nearStores[index].vendor_logo,
                                      width: 93.3,
                                      height: 93.3,
                                    ),
                                    SizedBox(width: 13.3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                              nearStores[index]
                                                  .vendor_name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .copyWith(
                                                  color:
                                                  kMainTextColor,
                                                  fontSize: 18)),
                                          SizedBox(height: 8.0),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.location_on,
                                                color: kIconColor,
                                                size: 15,
                                              ),
                                              SizedBox(width: 10.0),
                                              // Text(
                                              //     '${double.parse('${nearStores[index].distance}').toStringAsFixed(2)} km ',
                                              //     style: Theme.of(
                                              //         context)
                                              //         .textTheme
                                              //         .caption!
                                              //         .copyWith(
                                              //         color:
                                              //         kLightTextColor,
                                              //         fontSize:
                                              //         13.0)),
                                              // Text('| ',
                                              //     style: Theme.of(
                                              //         context)
                                              //         .textTheme
                                              //         .caption!
                                              //         .copyWith(
                                              //         color:
                                              //         kMainColor,
                                              //         fontSize:
                                              //         13.0)),
                                              Expanded(
                                                child: Text(
                                                    '${nearStores[index].vendor_loc}',
                                                    maxLines: 2,
                                                    style: Theme.of(
                                                        context)
                                                        .textTheme
                                                        .caption!
                                                        .copyWith(
                                                        color:
                                                        kLightTextColor,
                                                        fontSize:
                                                        13.0)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.access_time,
                                                color: kIconColor,
                                                size: 15,
                                              ),
                                              SizedBox(width: 10.0),
                                              Text('${nearStores[index].duration}',                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                      color:
                                                      kLightTextColor,
                                                      fontSize: 13.0)),
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(8),
                                            child: Visibility(
                                              visible: (nearStores[index]
                                                  .online_status ==
                                                  "off" ||
                                                  nearStores[index]
                                                      .online_status ==
                                                      "Off" ||
                                                  nearStores[index]
                                                      .online_status ==
                                                      "OFF")
                                                  ? true
                                                  : false,
                                              child: Container(
                                                margin: EdgeInsets.all(8),
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    10,
                                                alignment: Alignment.center,
                                                color: kCardBackgroundColor,
                                                child: Text(
                                                  'Store Closed Now\nStore open at ${nearStores[index].opening_time.toString()}',
                                                  style: TextStyle(
                                                      color: red_color,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(8),
                                            child: Visibility(
                                              visible: (nearStores[index]
                                                  .inrange == 0)
                                                  ? true
                                                  : false,
                                              child: Container(
                                                margin: EdgeInsets.all(8),
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    10,
                                                alignment: Alignment.center,
                                                color: kCardBackgroundColor,
                                                child: Text(
                                                  'Store Out of Delivery Range',
                                                  style: TextStyle(
                                                      color: red_color,
                                                      fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 10,
                      );
                    }),
              )
                  : Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isFetchStore
                        ? CircularProgressIndicator()
                        : Container(
                      width: 0.5,
                    ),
                    isFetchStore
                        ? SizedBox(
                      width: 10,
                    )
                        : Container(
                      width: 0.5,
                    ),
                    Text(
                      (!isFetchStore)
                          ? 'No Store Found at your location'
                          : 'Fetching Stores',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kMainTextColor),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    Text(
    message.toString(),
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: 12),
    )
    ]
      )
    );
  }
  getShareValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLat = double.parse('${prefs.getString('lat')}');
      userLng = double.parse('${prefs.getString('lng')}');
      message= prefs.getString("message")!;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2){
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min<60) {
      return ""+'${min.toInt()}'+" mins";
    }else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60)}' + " hour " + minutes +"mins";
    }
  }

  hitNavigator(BuildContext context, NearStores substores) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Navigator.push(context, MaterialPageRoute
      (builder: (context) =>
    new AppCategory(
        substores.vendor_category_id,
        substores.vendor_name.toString(),  substores.vendor_id,
        substores.distance)));

  }

}