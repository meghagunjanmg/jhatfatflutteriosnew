import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/addaddresspage.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/bannerbean.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/bean/resturantbean/categoryresturantlist.dart';
import 'package:jhatfat/bean/resturantbean/popular_item.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/helper/categorylist.dart';
import 'package:jhatfat/restaturantui/helper/hot_sale.dart';
import 'package:jhatfat/restaturantui/helper/product_order.dart';
import 'package:jhatfat/restaturantui/pages/rasturantlistpage.dart';
import 'package:jhatfat/restaturantui/pages/recentproductorder.dart';
import 'package:jhatfat/restaturantui/pages/restaurant.dart';
import 'package:jhatfat/restaturantui/searchResturant.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../HomeOrderAccount/home_order_account.dart';
import '../../bean/venderbean.dart';

class Restaurant extends StatefulWidget {
  final String? pageTitle;

  Restaurant(this.pageTitle);

  @override
  State<StatefulWidget> createState() {
    return RestaurantState();
  }
}

class RestaurantState extends State<Restaurant> {
  late final String? pageTitle;

  late double lat=0.0;
  late double lng=0.0;

  String cityName = '';

  List<PopularItem> popularItem = [];
  List<CategoryResturant> categoryList = [];

  List<BannerDetails> listImage = [];
  List<NearStores> nearStores = [];
  List<NearStores> nearStoresSearch = [];

  static String id = 'exploreScreen';

  String currentAddress = "76A, New York, US.";
  bool address1 = true;
  bool address2 = false;
  dynamic currencySymbol = '';
  dynamic cartCount = 0;
  bool isCartCount = false;
  bool isProdcutOrderFetch = false;
  bool isCategoryFetch = false;
  bool isSlideFetch = false;
  bool isFetchRestStore = false;
  bool isFetch = false;

  String nodata='';
  String message='';

  @override
  void initState() {
    super.initState();
    getData();
  }
  void callThisMethod(bool isVisible){
    debugPrint('_HomeScreenState.callThisMethod: isVisible: ${isVisible}');
    getData();
  }

  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState((){
      message = pref.getString("message")!;
      cityName = pref.getString("addr")!;
      lat = double.parse(pref.getString("lat")!);
      lng = double.parse(pref.getString("lng")!);
      print("HOME_RES" + lat.toString() + lng.toString());
      _hitServices();
    });

  }

  void _hitServices() {
    getCurrentSymbol();
    // _getLocation();
    getCartCount();
    hitProductUrl();
    hitCategoryUrl();
    // hitSliderUrl();
    hitRestaurantService();
  }

  Future<void> getCartCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("vendor_cat_id", "12");
    prefs.setString("ui_type", "2");
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCountRest().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });
  }



  getCurrentSymbol() async {
    SharedPreferences pre = await SharedPreferences.getInstance();
    setState(() {
      currencySymbol = pre.getString('curency');
    });
  }

  void hitProductUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isProdcutOrderFetch = true;
    });
    var url = popular_item;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '${preferences.getString('vendor_cat_id')}'
      // 'vendor_id': '24'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<PopularItem> tagObjs = tagObjsJson
              .map((tagJson) => PopularItem.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isProdcutOrderFetch = false;
              popularItem.clear();
              popularItem = tagObjs;
            });
          } else {
            setState(() {
              isProdcutOrderFetch = false;
            });
          }
        } else {
          setState(() {
            isProdcutOrderFetch = false;
          });
        }
      } else {
        setState(() {
          isProdcutOrderFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isProdcutOrderFetch = false;
      });
    });
  }

  void hitCategoryUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isCategoryFetch = true;
    });
    var url = homecategoryss;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '${preferences.getString('vendor_cat_id')}'
      // 'vendor_id': '24'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryResturant> tagObjs = tagObjsJson
              .map((tagJson) => CategoryResturant.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isCategoryFetch = false;
              categoryList.clear();
              categoryList = tagObjs;
            });
          } else {
            setState(() {
              isCategoryFetch = false;
            });
          }
        } else {
          setState(() {
            isCategoryFetch = false;
          });
        }
      } else {
        setState(() {
          isCategoryFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isCategoryFetch = false;
      });
    });
  }

  void hitSliderUrl() async {
    setState(() {
      isSlideFetch = true;
    });
    var url = resturant_banner;
    Uri myUri = Uri.parse(url);

    http.get(myUri).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isSlideFetch = false;
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isSlideFetch = false;
            });
          }
        } else {
          setState(() {
            isSlideFetch = false;
          });
        }
      } else {
        setState(() {
          isSlideFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isSlideFetch = false;
      });
    });
  }

  void hitRestaurantService() async {
    setState(() {
      isFetchRestStore = true;
      isFetch = false;
    });

    var url = nearbyrest;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'lat': lat.toString(),
      'lng':lng.toString(),
    }).then((value) {
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
            isFetchRestStore = false;
            isFetch = true;
            nearStores.clear();
            nearStoresSearch.clear();
            nearStores = tagObjs;
            nearStoresSearch = List.from(nearStores);
            nodata='';
          });
        } else {
          setState(() {
            isFetchRestStore = false;
            isFetch = false;
            nearStores.clear();
            nearStoresSearch.clear();
            nodata="No Restaurants available in your area.";
          });
        }
      }
    }).catchError((e) {
      print(e);
      Timer(Duration(seconds: 5), () {
        hitRestaurantService();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return  VisibilityDetector(
        key: Key(RestaurantState.id),
    onVisibilityChanged: (VisibilityInfo info) {
    bool isVisible = info.visibleFraction != 0;
    callThisMethod(isVisible);
    },
    child:Container(
      color: kMainColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 130,
                  backgroundColor: Colors.white,
                  pinned: true,
                  floating: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: innerBoxIsScrolled ? kMainTextColor : kWhiteColor,
                      size: 24.0,
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeOrderAccount(0,1)),
                              (Route<dynamic> route) => false);
                      },
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Stack(
                        children: [
                          IconButton(
                              icon: ImageIcon(
                                AssetImage('images/icons/ic_cart blk.png'),
                                color: innerBoxIsScrolled
                                    ? kMainTextColor
                                    : kWhiteColor,
                              ),
                              onPressed: () {
                                  Navigator.pushNamed(
                                          context, PageRoutes.restviewCart)
                                      .then((value) {
                                    getCartCount();
                                  });

//                        getCurrency();
                              }),
                          Positioned(
                              right: 5,
                              top: 2,
                              child: Visibility(
                                visible: isCartCount,
                                child: CircleAvatar(
                                  minRadius: 4,
                                  maxRadius: 8,
                                  backgroundColor: innerBoxIsScrolled
                                      ? kMainColor
                                      : kWhiteColor,
                                  child: Text(
                                    '$cartCount',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 7,
                                        color: innerBoxIsScrolled
                                            ? kWhiteColor
                                            : kMainTextColor,
                                        fontWeight: FontWeight.w200),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.shopping_cart,color: innerBoxIsScrolled?kMainTextColor:kWhiteColor,size: 24.0,),
                    //   onPressed: () {
                    //    hitResturantCart(context);
                    //   },
                    // ),
                  ],
                  title: InkWell(
                    onTap: () {
                      // _addressBottomSheet(context, width);
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (context) {
                      //   return LocationPage(lat, lng);
                      // })).then((value) {
                      //   if (value != null) {
                      //     print('${value.toString()}');
                      //     BackLatLng back = value;
                      //     getBackResult(back.lat, back.lng);
                      //   }
                      // }).catchError((e) {
                      //   print(e);
                      //   // getBackResult();
                      // });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Delivering To'.toUpperCase(),
                            style: TextStyle(
                              color: innerBoxIsScrolled
                                  ? kMainTextColor
                                  : kWhiteColor,
                              fontSize: 13.0,
                              fontFamily: 'OpenSans',
                              fontWeight: FontWeight.w500,
                            )),
                        SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: innerBoxIsScrolled
                                  ? kMainTextColor
                                  : kWhiteColor,
                              size: 16.0,
                            ),
                            Text(cityName,
                                style: TextStyle(
                                  color: innerBoxIsScrolled
                                      ? kMainTextColor
                                      : kWhiteColor,
                                  fontSize: 13.0,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w500,
                                )),
                            // Icon(
                            //   Icons.arrow_drop_down,
                            //   color: innerBoxIsScrolled
                            //       ? kMainTextColor
                            //       : kWhiteColor,
                            //   size: 16.0,
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background:

                    Container(
                      padding: EdgeInsets.only(
                          left: fixPadding,
                          right: fixPadding,
                          top: 0.0,
                          bottom: fixPadding),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: kMainColor,
                      ),
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //         context,
                          //         PageTransition(
                          //             type: PageTransitionType.rightToLeft,
                          //             child: SearchRestaurantStore(
                          //                 currencySymbol)))
                          //     .then((value) {
                          //   getCartCount();
                          // });
                        },
                        child:

                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.85,
                          height: 52,
                          padding: EdgeInsets.only(left: 5),

                          child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              autofocus: false,
                              style:
                              DefaultTextStyle.of(context)
                                  .style
                                  .copyWith(fontStyle: FontStyle.italic),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    borderSide: BorderSide(color: Colors.black)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    borderSide: BorderSide(color: Colors.black)),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                hintText: 'Search Restaurant...',
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return await BackendService.getSuggestions(pattern,lat,lng);
                            },
                            itemBuilder: (context, Vendors suggestion) {
                              return ListTile(
                                  title: Text('${suggestion.str1}'),
                                  subtitle: Text('${suggestion.str2}'
                                  )
                              );
                            },
                             hideOnError: true,
 onSuggestionSelected: (Vendors detail) async {
                              for(int i=0;i<nearStores.length;i++)
                              {
                                if(nearStores.elementAt(i).vendor_id == detail.vendorId)
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Restaurant_Sub(
                                                  nearStores.elementAt(i), currencySymbol)));
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                ),
              ];
            },
            body: SafeArea(
              child:
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                  color: kCardBackgroundColor,
                ),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    // Image Slider List Start
//                     Visibility(
//                       visible: (!isSlideFetch && listImage!=null && listImage.length>0)?true:false,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.only(top: fixPadding * 1.5),
//                             child: ImageSliderList(listImage,(){
// getCartCount();
//                             }),
//                           ),
//                           // Image Slider List End
//                           heightSpace,
//                         ],
//                       ),
//                     ),

                    (!isFetch)?
                    Visibility(
                        visible: true,
                      child: Padding(
                        padding: EdgeInsets.all(fixPadding),
                        child: Text(
                          nodata,
                          style: headingStyle,
                        ),
                      ))
                  :
                    Visibility(
                        visible: false,
                        child: Padding(
                          padding: EdgeInsets.all(fixPadding),
                          child: Text(
                            'No Restaurants available in your area.',
                            style: headingStyle,
                          ),
                        ))
,
                    Visibility(
                      visible: (!isSlideFetch && listImage.length > 0)
                          ? true
                          : false,
                      child: Container(
                        width: width,
                        height: 160.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: (listImage != null && listImage.length > 0)
                              ? ListView.builder(
                                  itemCount: listImage.length,
                                  scrollDirection: Axis.vertical,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    // final item = listImage[index];
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                        width: 170.0,
                                        margin: (index !=
                                                (listImage.length - 1))
                                            ? EdgeInsets.only(left: fixPadding)
                                            : EdgeInsets.only(
                                                left: fixPadding,
                                                right: fixPadding),
                                        decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //   image: Image.network(imageBaseUrl+listImage[index].banner_image),
                                          //   fit: BoxFit.cover,
                                          // ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Image.network(
                                          '${imageBaseUrl}${listImage[index].bannerImage}',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: 10,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    // final item = listImages[index];
                                    return InkWell(
                                      onTap: () {},
                                      child: Container(
                                        width: 170.0,
                                        margin: (index != (10 - 1))
                                            ? EdgeInsets.only(left: fixPadding)
                                            : EdgeInsets.only(
                                                left: fixPadding,
                                                right: fixPadding),
                                        decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //   image: AssetImage(imageBaseUrl+item.banner_image),
                                          //   fit: BoxFit.cover,
                                          // ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Shimmer(
                                          duration: Duration(seconds: 3),
                                          //Default value
                                          color: Colors.white,
                                          //Default value
                                          enabled: true,
                                          //Default value
                                          direction:
                                              ShimmerDirection.fromLTRB(),
                                          //Default Value
                                          child: Container(
                                            color: kTransparentColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    // Categories Start
                    Visibility(
                      // visible: (!isCategoryFetch && categoryList!=null && categoryList.length>0)?true:false,
                      visible: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(fixPadding),
                            child: Text(
                              'Categories',
                              style: headingStyle,
                            ),
                          ),
                          CategoryList(categoryList, () {
                            getCartCount();
                          }),
                          // Categories End
                          heightSpace,
                        ],
                      ),
                    ),
                    // Products Ordered Start
                    Visibility(
                      visible: (!isProdcutOrderFetch &&
                              popularItem != null &&
                              popularItem.length > 0)
                          ? true
                          : false,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(fixPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Products Ordered',
                                  style: headingStyle,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: ProductsOrderedNew(
                                                currencySymbol)));
                                  },
                                  child: Text('View all', style: moreStyle),
                                ),
                              ],
                            ),
                          ),
                          ProductsOrdered(currencySymbol, popularItem, () {
                            getCartCount();
                          }),
                          // Products Ordered End
                          heightSpace,
                          heightSpace,
                        ],
                      ),
                    ),
                    // Products Ordered Start
                    Visibility(
                        visible: (!isFetchRestStore && nearStores.length == 0)
                            ? false
                            : true,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(fixPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Store',
                                    style: headingStyle,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  child: ResturantPageList(
                                                      currencySymbol)))
                                          .then((value) {
                                        getCartCount();
                                      });
                                    },
                                    child: Text('View all', style: moreStyle),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child:

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0, top: 20.0),
                                    child: Text(
                                      '${nearStores.length} Restaurant found',
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
                                              else{
                                                hitNavigator(context, nearStores[index]);
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
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width ,
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
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(nearStores[index].vendor_name,
                                                                style: Theme
                                                                    .of(context)
                                                                    .textTheme
                                                                    .subtitle2!
                                                                    .copyWith(
                                                                    color: kMainTextColor,
                                                                    fontSize: 18)),
                                                            SizedBox(height: 10.0),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Icon(
                                                                        Icons.location_on,
                                                                        color: kIconColor,
                                                                        size: 15,
                                                                      ),
                                                                      SizedBox(width: 10.0),
                                                                      Text(
                                                                          '${double.parse(
                                                                              '${nearStores[index].distance}')
                                                                              .toStringAsFixed(2)} km ',
                                                                          style: Theme
                                                                              .of(context)
                                                                              .textTheme
                                                                              .caption!
                                                                              .copyWith(
                                                                              color:
                                                                              kLightTextColor,
                                                                              fontSize: 13.0)),
                                                                      Text('|',
                                                                          style: Theme
                                                                              .of(context)
                                                                              .textTheme
                                                                              .caption!
                                                                              .copyWith(
                                                                              color: kMainColor,
                                                                              fontSize: 13.0)),
                                                                      Text(
                                                                          '${nearStores[index].vendor_loc}', //equal minlines: 3
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: Theme
                                                                              .of(context)
                                                                              .textTheme
                                                                              .caption!
                                                                              .copyWith(
                                                                              color:
                                                                              kLightTextColor,
                                                                              fontSize: 13.0))
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
                                                                Text('${nearStores[index].duration}',                                                                    style: Theme.of(context)
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
                                                                  padding: EdgeInsets.all(8),
                                                                  alignment: Alignment.centerLeft,
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
                                                                  padding: EdgeInsets.all(8),
                                                                  alignment: Alignment.centerLeft,
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
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height / 2,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        isFetchRestStore ? CircularProgressIndicator() : Container(
                                          width: 0.5,),
                                        isFetchRestStore ? SizedBox(
                                          width: 10,
                                        ) : Container(width: 0.5,),
                                        Text(
                                          (!isFetchRestStore)
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
                            heightSpace,
                          ],
                        )),
                    // FavouriteRestaurantsList(currencySymbol,nearStores,nearStoresSearch,() {
                    //   getCartCount();
                    //   print("value rest up");
                    // }),
                    // Products Ordered End

                    // Hot Sale Start
                    Visibility(
                      visible: (!isProdcutOrderFetch &&
                              popularItem != null &&
                              popularItem.length > 0)
                          ? true
                          : false,
                      child: Column(
                        children: [
                          heightSpace,
                          Padding(
                            padding: EdgeInsets.all(fixPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Hot Sale',
                                  style: headingStyle,
                                ),
                                InkWell(
                                  onTap: () {
                                    // Navigator.push(context, PageTransition(type: PageTransitionType.downToUp, child: MoreList()));
                                  },
                                  child: Text('View all', style: moreStyle),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    HotSale(currencySymbol, popularItem, () {
                      getCartCount();
                    }),
                    // Hot Sale End
                    heightSpace,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
    );
  }

  hitNavigator(BuildContext context, NearStores item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('${prefs.getString("res_vendor_id")}');
    print('${item.vendor_id}');
    if (isCartCount &&
        prefs.getString("res_vendor_id") != null &&
        prefs.getString("res_vendor_id") != "" &&
        prefs.getString("res_vendor_id") != '${item.vendor_id}') {
      showMyDialog(context, item, currencySymbol);

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => Restaurant_Sub(item, currencySymbol)))
      //     .then((value) {
      //   getCartCount();
      // });
    } else {
      prefs.setString("res_vendor_id", '${item.vendor_id}');
      prefs.setString("res_pack_charge", '${item.packaging_charges}');
      prefs.setString("store_resturant_name", '${item.vendor_name}');
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Restaurant_Sub(item, currencySymbol)))
          .then((value) {
        getCartCount();
      });
    }
  }

  showMyDialog(BuildContext context,NearStores item, currencySymbol) {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return new AlertDialog(
            content: Text(
              'Your cart contains dishes from a different resturant. Do you want to discard the selection and add dishes from this resturant.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Clear Cart'),
                onPressed: () {
                  deleteAllRestProduct(context,item, currencySymbol);
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }
    );
  }

  void deleteAllRestProduct(
      BuildContext context, NearStores item, currencySymbol) async {
    DatabaseHelper database = DatabaseHelper.instance;
    database.deleteAllRestProdcut();
    database.deleteAllAddOns();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("res_vendor_id", '${item.vendor_id}');
    prefs.setString("res_pack_charge", '${item.packaging_charges}');
    prefs.setString("store_resturant_name", '${item.vendor_name}');
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Restaurant_Sub(item, currencySymbol)))
        .then((value) {
      getCartCount();
    });
  }

  void hitResturantCart(context) async {
    if (isCartCount) {
      Navigator.pushNamed(context, PageRoutes.restviewCart).then((value) {
        getCartCount();
      });
    } else {
      Toast.show('No Value in the cart!', duration: Toast.lengthShort, gravity:  Toast.bottom);
    }
  }

  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
   class BackendService {
  static Future<List<Vendors>> getSuggestions(String query,double lat,double lng) async {
    if (query.isEmpty && query.length < 4) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }


    var url = restSearch_key;
    Uri myUri = Uri.parse(url);
    var response = await http.post(myUri, body: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'prod_name': query
    });

    List<Vendors> vendors = [];

    if (response.statusCode == 200) {
      Iterable json1 = jsonDecode(response.body)['vendor'];


      if (json1.isNotEmpty) {
        vendors.clear();
        vendors =
        List<Vendors>.from(json1.map((model) => Vendors.fromJson(model)));
      }
    }
    return Future.value(vendors);
  }
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
// Bottom Sheet for Address Ends Here
}
