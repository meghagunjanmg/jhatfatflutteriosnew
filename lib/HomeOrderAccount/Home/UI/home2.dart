import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:location/location.dart' as loc;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/card_content.dart';
import 'package:jhatfat/Components/card_content_new.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Components/reusable_card.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/Stores/stores.dart';
import 'package:jhatfat/Maps/UI/location_page.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/bannerbean.dart';
import 'package:jhatfat/bean/latlng.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/bean/venderbean.dart';
import 'package:jhatfat/bean/vendorbanner.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/parcel/ParcelLocation.dart';
import 'package:jhatfat/parcel/fromtoaddress.dart';
import 'package:jhatfat/parcel/parcalstorepage.dart';
import 'package:jhatfat/pharmacy/pharmastore.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../Themes/constantfile.dart';
import '../../../Themes/style.dart';
import '../../../bean/adminsetting.dart';
import '../../../restaturantui/pages/rasturantlistpage.dart';
import '../../../restaturantui/pages/restaurant.dart';
import '../../../subscription/SubscribeStore.dart';
import '../Closed.dart';
import 'appcategory/appcategory.dart';


class HomePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Home();
  }

}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Adminsetting? admins;

  String? cityName = 'NO LOCATION SELECTED';
  String? currency = '';
  late List<NearStores> rest_nearStores = [];
  String ClosedImage = '';
  List<BannerDetails> ClosedBannerImage = [];

  String pickImage = '';
  String subsImage = '';
  String bigImage = '';
  String TopImage = '';
  var lat = 30.3253;
  var lng = 78.0413;
  List<BannerDetails> listImage = [];
  List<BannerDetails> pickBannerImage = [];
  List<BannerDetails> topBannerImage = [];
  List<VendorList> nearStores = [];
  List<VendorList> newnearStores = [];
  List<Vendors> substores = [];
  List<VendorList> nearStoresShimmer = [
    VendorList(),
    VendorList(),
    VendorList(),
    VendorList(),
  ];
  List<String> listImages = ['', '', '', '', ''];
  bool isCartCount = false;
  int cartCount = 0;
  bool isFetch = true;

  final dynamic vendor_category_id = 14;

  // final dynamic ui_type;

  List<VendorBanner> listImage1 = [];
  List<NearStores> nearStores1 = [];
  List<NearStores> nearStoresSearch1 = [];
  List<NearStores> nearStoresShimmer1 = [
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "",""),
    NearStores("", "", 0, "", "", "", "", "", "", "", "", "",""),
  ];
  List<String> listImages1 = ['', '', '', '', ''];
  double userLat = 0.0;
  double userLng = 0.0;
  bool isFetchStore = true;
  TextEditingController searchController = TextEditingController();
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  static String id="";

  bool subscription = false;

  @override
  void initState() {
    super.initState();
    checksubscription();

    getData();
  }


  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowBothCount().then((value) {
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

        setState(() {
          currency = '${jsonData['data'][0]['currency_sign']}';
        });
      }
    }).catchError((e) {});
  }
  void callThisMethod(bool isVisible) {
   getData();
  }
  void _getLocation(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        double lt = position.latitude;
        String latstring = lt.toStringAsFixed(8); // '2.35'
        double lats = double.parse(latstring);

        double ln = position.longitude;
        String lanstring = ln.toStringAsFixed(8); // '2.35'
        double lngs = double.parse(lanstring);

        prefs.setString("lat", latstring);
        prefs.setString("lng", lanstring);

        setState(() {
          lat = lats;
          lng = lngs;
        });

        //double lat = position.latitude;
        //double lat = 29.006057;
        //double lng = position.longitude;
        //double lng = 77.027535;

        List<Placemark> placemarks = await placemarkFromCoordinates(lats, lngs);
        setState(() {
          cityName = (placemarks
              .elementAt(0)
              .subLocality
              .toString()) + " ( " + (placemarks
              .elementAt(0)
              .locality
              .toString()) + " )".toUpperCase();

          prefs.setString("addr", cityName.toString());
        });

        calladminsetting();


      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation(context);
          } else {
            // Toast.show('Location permission is required!', context,
            //     duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          // Toast.show('Location permission is required!', context,
          //     duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation(context);
      } else {
        // Toast.show('Location permission is required!', context,
        //     duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation(context);
      }).catchError((e) {
        // Toast.show('Location permission is required!', context,
        //     duration: Toast.LENGTH_SHORT);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      VisibilityDetector(
        key: Key(_HomeState.id),
    onVisibilityChanged: (VisibilityInfo info) {
    bool isVisible = info.visibleFraction != 0;
    callThisMethod(isVisible);
    },
    child:
    Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.location_searching,
                color: Colors.white,
              ),
              onPressed: () {
                _getLocation(context);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, PageRoutes.accountPage);
                // do something
              },
            ),
          ],
          color: kMainColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Icon(
              Icons.location_on,
              color: Colors.white,
            ),
          ),

          titleWidget:
          GestureDetector(
            onTap: () async {
              print("SENDINGLATLNG  " + lat.toString() + lng.toString());
              BackLatLng back = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LocationPage(lat, lng)));

              getBackResult(back.lat, back.lng);
            },
            child: Text(
              cityName!,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (admins!.surge==1)
                  ?
              Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 24.0),
                  child:
                    Text(
                      admins!.surgeMsg.toString(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16,color: Colors.blue),
                    )

              )
                  :
          Padding(
            padding: EdgeInsets.only(top: 8.0, left: 24.0),
            child: Text(
                    "",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  )
          ),
              Padding(
                padding: EdgeInsets.only(top: 8.0, left: 24.0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: ()async {

                        await showDialog(
                            context: context,
                            builder: (_) => Dialog(
                            child: Container(
                              decoration: BoxDecoration(
                                color: white_color,
                                borderRadius:
                                BorderRadius.circular(20.0),
                              ),
                              child: Image.network(
                                TopImage,
                                fit: BoxFit.fill,
                              ),
                            ),
                        )
                        );
                      },
                    child: Text(
                      admins!.topMessage.toString(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1,
                    ),
                ),
          ],
              ),
              ),
              SizedBox(
                  height: 20
              ),

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
                    style: DefaultTextStyle
                        .of(context)
                        .style
                        .copyWith(fontStyle: FontStyle.italic),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.black)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: kHintColor,
                      ),
                      hintText: 'Search Store,Restaurant...',
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await BackendService.getSuggestions(
                        pattern, lat, lng);
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
                    if (detail.uiType == "grocery" ||
                        detail.uiType == "Grocery" ||
                        detail.uiType == 1) {
                      Navigator.push(context, MaterialPageRoute
                        (builder: (context) =>
                      new AppCategory(
                        detail.vendorCategoryId,
                          detail.vendorName.toString(), detail.vendorId,
                          detail.distance)));
                    }
                    else if (detail.uiType == "resturant" ||
                        detail.uiType == "Resturant" ||
                        detail.uiType == 2) {
                      for (int i = 0; i < rest_nearStores.length; i++) {
                        if (rest_nearStores
                            .elementAt(i)
                            .vendor_id == detail.vendorId) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Restaurant_Sub(
                                          rest_nearStores.elementAt(i),
                                          currency)));
                        }
                      }
                    }
                  },
                ),
              ),
              // Container(
              //   width: MediaQuery
              //       .of(context)
              //       .size
              //       .width * 0.85,
              //   height: 52,
              //   padding: EdgeInsets.only(left: 5),
              //   decoration: BoxDecoration(
              //       color: scaffoldBgColor,
              //       borderRadius: BorderRadius.circular(50)),
              //   child: TextFormField(
              //     decoration: InputDecoration(
              //       border: InputBorder.none,
              //       prefixIcon: Icon(
              //         Icons.search,
              //         color: kHintColor,
              //       ),
              //       hintText: 'Search store...',
              //     ),
              //     controller: searchController,
              //     cursorColor: kMainColor,
              //     keyboardType: TextInputType.text,
              //     textInputAction: TextInputAction.done,
              //     autofocus: false,
              //       onChanged: (value) {
              //               if(value.length>5) callSearch();
              //       },
              //     onTap: () {
              //
              //     },
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.all(20),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 100 / 90,
                  controller: ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  // childAspectRatio: itemWidth/(itemHeight),
                  children: (nearStores != null && nearStores.length > 0)
                      ? nearStores.map((e) {
                    return ReusableCard(
                      cardChild: CardContent(
                        image: '${imageBaseUrl}${e.categoryImage}',
                        text: '${e.categoryName}',
                        uiType: e.uiType,
                        vendorCategoryId: '${e.vendorCategoryId}',
                        context: context,
                      ),
                    );
                  }).toList()

                      : nearStoresShimmer.map((e) {
                    return ReusableCard(
                        cardChild: Shimmer(
                          duration: Duration(seconds: 3),
                          //Default value
                          color: Colors.white,
                          //Default value
                          enabled: true,
                          //Default value
                          direction: ShimmerDirection.fromLTRB(),
                          //Default Value
                          child: Container(
                            color: kTransparentColor,
                          ),
                        ),
                        onPress: () {});
                  }).toList(),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: 2),
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute
                        (builder: (context) =>
                      new AppCategory(pickBannerImage[0].vendorCategoryId,pickBannerImage[0].vendorName,
                          pickBannerImage[0].vendorId, "22")));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Material(
                        borderRadius:
                        BorderRadius.circular(20.0),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          height: 100,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width *
                              0.90,
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                          decoration: BoxDecoration(
                            color: white_color,
                            borderRadius:
                            BorderRadius.circular(20.0),
                          ),
                          child: Image.network(
                            pickImage,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  );
                },

              ),
            ),

              ( !subscription )?
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 2),
                child: Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, PageRoutes.subscription);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: Material(
                          borderRadius:
                          BorderRadius.circular(20.0),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            height: 100,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width *
                                0.90,
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                            decoration: BoxDecoration(
                              color: white_color,
                              borderRadius:
                              BorderRadius.circular(20.0),
                            ),
                            child: Image.network(
                              subsImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    );
                  },

                ),
              )        :
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 2),
                child:
    Column(
    children: <Widget>[

    Padding(
      padding: EdgeInsets.all(fixPadding),
      child:
      Column(
      children:[
      Padding(
      padding: EdgeInsets.only(top: 8.0, left: 24.0,right: 24.0),
                  child:
                  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        Text(
        'Subscribed stores',
        style: headingStyle,
      ),
      InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType
                      .bottomToTop,
                  child: SubscribeStore()));
        },
        child: Text('View all', style: moreStyle),
      ),
    ]),
      ),
                  SizedBox(
                      height: 150,
                      width: MediaQuery. of(context). size. width,
                      child:
    ListView.builder(
      itemCount: (substores.length/2).toInt()+1,
    scrollDirection: Axis.horizontal,
    itemBuilder: (BuildContext context, int index) =>
        Padding(padding: const EdgeInsets.all(2.0),
          child: InkWell(onTap: () {
    Navigator.push(context, MaterialPageRoute
    (builder: (context) =>
    new AppCategory(
    substores[index].vendorCategoryId,
    substores[index].vendorName.toString(), substores[index].vendorId,
    substores[index].distance)));
          },
            child: Container(
              width: 120.0,
              child: ListTile(
                  title: Image.network('${imageBaseUrl}${substores[index].vendorLogo}',
                    width: 100.0,
                    height: 100.0,),
                  subtitle: Container(
                    alignment: Alignment.topCenter,
                    child: Text(substores[index].vendorName!),
                  )
              ),
            ),
          ),
        ),
    ),
                  )
        ]
    )
    ),
    ])),
              Visibility(
                visible: (!isFetch && listImage.length == 0) ? false : true,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        initialPage: 0,
                        viewportFraction: 0.9,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: (listImage != null && listImage.length > 0)
                          ? listImage.map((e) {
                        return Builder(
                          builder: (context) {
                            return InkWell(
                              onTap: () {
                                hitbannerVendor(e);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Material(
                                  elevation: 5,
                                  borderRadius:
                                  BorderRadius.circular(20.0),
                                  clipBehavior: Clip.hardEdge,
                                  child: Container(
                                    height: 200,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.90,
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: white_color,
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                    ),
                                    child: Image.network(
                                      imageBaseUrl + e.bannerImage,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList()
                          : listImages.map((e) {
                        return Builder(builder: (context) {
                          return Container(
                            height: 200,
                            width:
                            MediaQuery
                                .of(context)
                                .size
                                .width * 0.90,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Shimmer(
                              duration: Duration(seconds: 3),
                              //Default value
                              color: Colors.white,
                              //Default value
                              enabled: true,
                              //Default value
                              direction: ShimmerDirection.fromLTRB(),
                              //Default Value
                              child: Container(
                                color: kTransparentColor,
                              ),
                            ),
                          );
                        });
                      }).toList()),
                ),
              ),


              Padding(
                padding: EdgeInsets.only(top: 2, bottom: 2),
                child: Builder(
                  builder: (context) {
                    return InkWell(
                      onTap: () {
                        ////hitService1();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Material(
                          borderRadius:
                          BorderRadius.circular(20.0),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                            decoration: BoxDecoration(
                              color: white_color,
                              borderRadius:
                              BorderRadius.circular(20.0),
                            ),
                            child: Image.network(
                              bigImage,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    );
                  },

                ),
              ),

              Text(
                    admins!.bottomMessage.toString(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  )


            ],
          ),
        ),
      ),
    )

    );
  }

  void getBackResult(latss, lngss) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    double lats = double.parse(prefs.getString('lat')!);
    double lngs = double.parse(prefs.getString('lng')!);
    //
    // prefs.setString("lat", latss.toStringAsFixed(8));
    // prefs.setString("lng", lngss.toStringAsFixed(8));

    print("LATLONG" + lat.toString() + lng.toString());
    List<Placemark> placemarks = await placemarkFromCoordinates(lats, lngs);

    print("LATLONG" + placemarks.toString());

    setState(() {
      cityName = (placemarks
          .elementAt(0)
          .subLocality
          .toString()) + " ( " + (placemarks
          .elementAt(0)
          .locality
          .toString()) + " )".toUpperCase();
      prefs.setString("addr", cityName.toString());

    });
    calladminsetting();

  }


  Future<void> pickbanner() async {
    var url2 = pickdropbanner;
    Uri myUri2 = Uri.parse(url2);
    var response = await http.get(myUri2);
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          setState(() {
            pickBannerImage.clear();
            pickBannerImage = tagObjs;
            pickImage = imageBaseUrl + tagObjs[0].bannerImage;
          });
        }
      }
    } on Exception catch (_) {

    }
  }
  Future<void> Topbanner() async {
    var url2 = top_msg_banner;
    Uri myUri2 = Uri.parse(url2);
    var response = await http.get(myUri2);
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          setState(() {
            topBannerImage.clear();
            topBannerImage = tagObjs;
            TopImage = imageBaseUrl + tagObjs[0].bannerImage;
          });
        }
      }
    } on Exception catch (_) {

    }
  }




  void hitService(String lat, String lng) async {
    var endpointUrl = vendorUrl;
    Map<String, String> queryParams = {
      'lat': lat.toString(),
      'lng': lng.toString()
    };
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = endpointUrl + '?' +
        queryString; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
    print(requestUrl);
    Uri myUri = Uri.parse(requestUrl);

    var response = await http.get(myUri);
    {
      try {
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == "1") {
            var tagObjsJson = jsonDecode(response.body)['data'] as List;
            List<VendorList> tagObjs = tagObjsJson
                .map((tagJson) => VendorList.fromJson(tagJson))
                .toList();

            setState(() {
              nearStores.clear();
              nearStores = tagObjs;
            });
          }
        }
      } on Exception catch (_) {
        Timer(Duration(seconds: 5), () {
          hitService(lat.toString(), lng.toString());
        });
      }
    }


    var endpointUrl1 = newvendorUrl;
    Map<String, String> queryParams1 = {
      'lat': lat.toString(),
      'lng': lng.toString()
    };
    String queryString1 = Uri(queryParameters: queryParams1).query;
    var requestUrl1 = endpointUrl1 + '?' +
        queryString1; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
    print(requestUrl1);
    Uri myUri1 = Uri.parse(requestUrl1);
    var response1 = await http.get(myUri1);
    {
      try {
        if (response1.statusCode == 200) {
          var jsonData = jsonDecode(response1.body);
          if (jsonData['status'] == "1") {
            var tagObjsJson = jsonDecode(response1.body)['data'] as List;
            List<VendorList> tagObjs = tagObjsJson
                .map((tagJson) => VendorList.fromJson(tagJson))
                .toList();
            setState(() {
              newnearStores.clear();
              newnearStores = tagObjs;
            });
          }
        }
      } on Exception catch (_) {
        Timer(Duration(seconds: 5), () {
          hitService(lat.toString(), lng.toString());
        });
      }
    }
  }


  void hitBannerUrl() async {
    setState(() {
      isFetch = true;
    });
    var url = bannerUrl;
    Uri myUri = Uri.parse(url);
    http.get(myUri).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if (tagObjs.isNotEmpty) {
            setState(() {
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        } else {
          setState(() {
            isFetch = false;
          });
        }
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetch = false;
      });
    });


    var url3 = bigbanner;
    Uri myUri3 = Uri.parse(url3);
    var response3 = await http.get(myUri3);
    try {
      if (response3.statusCode == 200) {
        var jsonData = jsonDecode(response3.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response3.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          setState(() {
            bigImage = imageBaseUrl + tagObjs[0].bannerImage;
          });
        }
      }
    } on Exception catch (_) {

    }

    var url1 = subsbanner;
    Uri myUri1 = Uri.parse(url1);

    var response1 = await http.get(myUri1);
    try {
      if (response1.statusCode == 200) {
        var jsonData = jsonDecode(response1.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response1.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          setState(() {
            subsImage = imageBaseUrl + tagObjs[0].bannerImage;
          });
        }
      }
    } on Exception catch (_) {

    }
  }

  void hitNavigator(context, category_name, ui_type, vendor_category_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ui_type == "grocery" || ui_type == "Grocery" || ui_type == "1") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPage(category_name, vendor_category_id)));
    } else if (ui_type == "resturant" ||
        ui_type == "Resturant" ||
        ui_type == "2") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Restaurant("Urbanby Resturant")));
    } else if (ui_type == "pharmacy" ||
        ui_type == "Pharmacy" ||
        ui_type == "3") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPharmaPage('${category_name}', vendor_category_id)));
    } else if (ui_type == "parcal" || ui_type == "Parcal" || ui_type == "4") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      hitService1();

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => ParcalStoresPage('${vendor_category_id}')));

    }
  }

  void hitService1() async {
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = nearByStore;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
      'vendor_category_id': '${vendor_category_id}',
      'ui_type': '4'
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
            nearStores1.clear();
            nearStoresSearch1.clear();
            nearStores1 = tagObjs;
            nearStoresSearch1 = List.from(nearStores1);
          });
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
      Timer(Duration(seconds: 5), () {
        hitService(lat.toString(), lng.toString());
      });
    });


    hitNavigator1(
        context,
        lat, lng,
        nearStores1[0].vendor_name,
        nearStores1[0].vendor_id,
        nearStores1[0].distance);
  }

  void getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    try {
      setState(() {
            cityName = pref.getString("addr")!;
            lat = double.parse(pref.getString("lat")!);
            lng = double.parse(pref.getString("lng")!);
       });
      print("HOME_ORDER_HOME"+lat.toString()+lng.toString());
    } catch (e) {
      print(e);
    }

    if(pref.getString("lat")==null || pref.getString("lat").toString().isEmpty)
{
  _getLocation(context);
}


    calladminsetting();

  }

  void hitbannerVendor(BannerDetails detail) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (detail.uiType == "grocery" || detail.uiType == "Grocery" ||
        detail.uiType == 1) {
      Navigator.push(context, MaterialPageRoute
        (builder: (context) =>
      new AppCategory(detail.vendorCategoryId,detail.vendorName, detail.vendorId, "22")));
    }


    else if (detail.uiType == "resturant" ||
        detail.uiType == "Resturant" ||
        detail.uiType == 2) {
      print("REST BANNER");
      print("REST BANNER" + detail.vendorId.toString());

      for (int i = 0; i < rest_nearStores.length; i++) {
        print("REST BANNER" + rest_nearStores
            .elementAt(i)
            .vendor_id.toString());

        if (rest_nearStores
            .elementAt(i)
            .vendor_id.toString() == detail.vendorId.toString()) {

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Restaurant_Sub(
                          rest_nearStores.elementAt(i),
                          currency)));
        }
      }
    }
  }

  void hitRestaurantService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print(
        'data - ${prefs.getString('lat')} - ${prefs.getString('lng')} - ${prefs
            .getString('vendor_cat_id')} - ${prefs.getString('ui_type')}');
    var url = nearByStore;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
      'vendor_category_id': '12',
      'ui_type': '2'
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<NearStores> tagObjs = tagObjsJson
              .map((tagJson) => NearStores.fromJson(tagJson))
              .toList();

          setState(() {
            rest_nearStores.clear();
            rest_nearStores = tagObjs;
          });
          print('Response Body: - ' + rest_nearStores.toString());
        } else {

        }
      } else {

      }
    }).catchError((e) {
      print(e);
      Timer(Duration(seconds: 5), () {
        hitRestaurantService();
      });
    });
  }

  hitNavigator1(BuildContext context, lat, lng, vendor_name, vendor_id,
      distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pr_vendor_id", '${vendor_id}');
    prefs.setString("pr_store_name", '${vendor_name}');

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ParcelLocation();
    }));

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             AddressFrom(vendor_name, vendor_id, distance)));
  }

  void callSearch() {
    var url = Search_key;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'prod_name': searchController.text.toString()
    }).
    then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        print('Response Body: - ${value.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['vendor'] as List;
          List<Vendors> tagObjs = tagObjsJson
              .map((tagJson) => Vendors.fromJson(tagJson))
              .toList();
          if (tagObjs.isNotEmpty) {
            print(tagObjs
                .elementAt(0)
                .vendorName);
          }
        }
      }
    });
  }
  void checksubscription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = checksubs;
    Uri myUri = Uri.parse(url);
    var value = await http.post(myUri , body: {
    'user_phone': prefs.getString('user_phone')});
    var jsonData = jsonDecode(value.body.toString());
    if (jsonData['status'] == "1") {
      setState(() {
        subscription = true;
        callSubStore();
      });
      }
      else {
      setState(() {
        subscription = false;
      });
      }
    }
  void callSubStore() async {
    var url = subsstore;
    Uri myUri = Uri.parse(url);
    var value = await http.get(myUri);
    var jsonData = jsonDecode(value.body.toString());
    if (jsonData['status'] == "1") {
      var tagObjsJson = jsonDecode(value.body)['data'] as List;
      List<Vendors> tagObjs = tagObjsJson
          .map((tagJson) => Vendors.fromJson(tagJson))
          .toList();
      setState(() {
        substores.clear();
        substores = tagObjs;
      });
    }
  }

  void calladminsetting() async {
    var url = adminsettings;
    Uri myUri = Uri.parse(url);
    var value = await http.get(myUri);
    var jsonData = jsonDecode(value.body.toString());
    if (jsonData['status'] == "1") {
        admins = Adminsetting.fromJson(jsonData['data']);
        print("ADMIN RES: " + admins!.cityadminId.toString());
      if(admins!.status==1) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        messaging.getToken().then((value) {
          print(value);
        });
        getCurrency();
        Topbanner();
        hitService(lat.toString(), lng.toString());
        hitBannerUrl();
        pickbanner();
        hitRestaurantService();
        location.changeSettings(
            interval: 300, accuracy: loc.LocationAccuracy.high);
        location.enableBackgroundMode(enable: true);
      }
      else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Closed()),
                (Route<dynamic> route) => false);
      }
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });


    getCurrency();
    Topbanner();
    hitService(lat.toString(), lng.toString());
    hitBannerUrl();
    pickbanner();
    hitRestaurantService();
    location.changeSettings(
        interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);

  }
}

class BackendService {
  static Future<List<Vendors>> getSuggestions(String query,double lat,double lng) async {
    if (query.isEmpty && query.length < 2) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }

    var url = Search_key;
    Uri myUri = Uri.parse(url);
    var response = await http.post(myUri, body: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'prod_name': query
    });

    List<Vendors> vendors = [];
    List<Vendors> resturant = [];
    List<Vendors> product = [];
    List<Vendors> cat = [];
    List<Vendors> restcat = [];

    if (response.statusCode == 200) {
      Iterable json1 = jsonDecode(response.body)['vendor'];
      Iterable json2 = jsonDecode(response.body)['restproduct'];
      Iterable json3 = jsonDecode(response.body)['product'];
      Iterable json4 = jsonDecode(response.body)['cat'];
      Iterable json5 = jsonDecode(response.body)['restcat'];


      if (json1.isNotEmpty) {
        vendors.clear();
        vendors =
        List<Vendors>.from(json1.map((model) => Vendors.fromJson(model)));
      }
      if (json2.isNotEmpty) {
        resturant.clear();
        resturant =
        List<Vendors>.from(json2.map((model) => Vendors.fromJson(model)));
        vendors.addAll(resturant);
      }
      if (json3.isNotEmpty) {
        product.clear();
        product =
        List<Vendors>.from(json3.map((model) => Vendors.fromJson(model)));
        vendors.addAll(product);
      }
      if (json4.isNotEmpty) {
        cat.clear();
        cat =
        List<Vendors>.from(json4.map((model) => Vendors.fromJson(model)));
        vendors.addAll(cat);
      }
      if (json5.isNotEmpty) {
        restcat.clear();
        restcat =
        List<Vendors>.from(json5.map((model) => Vendors.fromJson(model)));
        vendors.addAll(restcat);
      }

    }
    return Future.value(vendors);
  }

}
