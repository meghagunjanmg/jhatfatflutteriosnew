import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/bannerbean.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/pages/product_tab.dart';
import 'package:jhatfat/restaturantui/pages/restaurant_information.dart';

import '../../bean/cartitem.dart';
import '../../bean/resturantbean/addonidlist.dart';
import '../../bean/resturantbean/categoryresturantlist.dart';
import '../../bean/venderbean.dart';
import '../helper/juice_list.dart';

class Restaurant_Sub extends StatefulWidget {
  final NearStores item;
  final dynamic currencySymbol;
  Restaurant_Sub(this.item, this.currencySymbol);

  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant_Sub> {
  bool favourite = false;
  List<BannerDetails> listImage = [];
  bool isSlideFetch = false;
  bool isCartCount = false;
  List<CategoryResturant> categoryList = [];
  List<CategoryResturant> categoryList2 = [];

  var cartCount = 0;
  String message='';
  int grocercart = 0;

  @override
  void initState() {
    getdata();
    hitResturantItem();
    getCartCount();
    getCartItem();
    super.initState();
  }
  void getCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryAllRows().then((value) {
      List<CartItem> tagObjs =
      value.map((tagJson) => CartItem.fromJson(tagJson)).toList();
      if (tagObjs.isNotEmpty) {
        print("ALREADY G");
        setState(() {
          grocercart = 1;
        });
      }
    });
  }
  showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: const Text(
              'Restraunt orders to be placed separately.\nPlease clear/empty cart to add item.in seperate orders',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Clear Cart'),
                onPressed: () {
                  ClearCart();

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

  void ClearCart() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll();
    getCartItem();

    setState(() {
      grocercart = 0;
    });
  }

  void hitResturantItem() async {

    print('${widget.item.vendor_id}');
    var url = homecategoryss;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${widget.item.vendor_id}'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryResturant> tagObjs = tagObjsJson
              .map((tagJson) => CategoryResturant.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              categoryList.clear();
              categoryList2.clear();
              categoryList = List.from(tagObjs);
              List<CategoryResturant> categoryListNew = List.from(tagObjs);
              categoryList2 = categoryListNew.toSet().toList();
            });
          } else {
          }
        }
      } else {
      }
    }).catchError((e) {
      print(e);
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


  void getCartCount() {

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
  void getCartCount_new() {
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
      // getResturantFavioute(widget.item.vendor_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 230,
                  backgroundColor: Colors.white,
                  pinned: true,
                  elevation: 0.0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: innerBoxIsScrolled ? kMainTextColor : kWhiteColor,
                      size: 24.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    // IconButton(
                    //   icon: (favourite)
                    //       ? Icon(
                    //           Icons.bookmark,
                    //           color: innerBoxIsScrolled?kMainTextColor:kWhiteColor,
                    //         )
                    //       : Icon(
                    //           Icons.bookmark_border,
                    //           color: innerBoxIsScrolled?kMainTextColor:kWhiteColor,
                    //         ),
                    //   onPressed: () {
                    //     // setState(() {
                    //     //   favourite = !favourite;
                    //     // });
                    //     favourite
                    //         ? removeFavourite(widget.item, context)
                    //         : setFaviouriteResturant(widget.item, context);
                    //   },
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Stack(
                        children: [
                          IconButton(
                              icon: ImageIcon(
                                AssetImage('images/icons/ic_cart blk.png'),
                                color: innerBoxIsScrolled?kMainTextColor:kWhiteColor,
                              ),
                              onPressed: () {
                                  Navigator.pushNamed(context, PageRoutes.viewCart);

//                        getCurrency();
                              }),
                          // Positioned(
                          //     right: 5,
                          //     top: 2,
                          //     child: Visibility(
                          //       visible: isCartCount,
                          //       child: CircleAvatar(
                          //         minRadius: 4,
                          //         maxRadius: 8,
                          //         backgroundColor: innerBoxIsScrolled?kMainColor:kWhiteColor,
                          //         child: Text(
                          //           '$cartCount',
                          //           overflow: TextOverflow.ellipsis,
                          //           style: TextStyle(
                          //               fontSize: 7,
                          //               color: innerBoxIsScrolled?kWhiteColor:kMainTextColor,
                          //               fontWeight: FontWeight.w200),
                          //         ),
                          //       ),
                          //     ))
                        ],
                      ),
                    ),
                  ],
                  title: Visibility(
                    visible: innerBoxIsScrolled ? true : false,
                    child: Text('${widget.item.vendor_name}'.toUpperCase(),
                        style: TextStyle(
                          color:
                              innerBoxIsScrolled ? kMainTextColor : kWhiteColor,
                          fontSize: 13.0,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          child: Container(
                            height: 180,
                            width: width,
                            alignment: Alignment.bottomCenter,
                            // decoration: BoxDecoration(
                            //   image: DecorationImage(
                            //     image: AssetImage(
                            //         'assets/restaurant/restaurant_3.png'),
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),
                            child: Image.network(
                              imageBaseUrl + widget.item.vendor_logo,
                              fit: BoxFit.cover,
                              width: width,
                              height: 180,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          child: Container(
                            height: 180.0,
                            width: width,
                            color: kMainTextColor.withOpacity(0.6),
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(fixPadding),
                                  child: Text(
                                    '${widget.item.vendor_name}',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: innerBoxIsScrolled
                                          ? kMainTextColor
                                          : kWhiteColor,
                                      fontFamily: 'OpenSans',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: fixPadding,
                                    left: fixPadding,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: kWhiteColor,
                                        size: 18.0,
                                      ),
                                      SizedBox(width: 2.0),
                                      Expanded(
                                        child: Text(
                                          '${widget.item.vendor_loc}',
                                          style: whiteSubHeadingStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.all(fixPadding),
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.center,
                                //     children: <Widget>[
                                //       Icon(Icons.star,
                                //           color: Colors.lime, size: 18.0),
                                //       SizedBox(width: 2.0),
                                //       Text(
                                //         '4.5',
                                //         style: whiteSubHeadingStyle,
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                heightSpace,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: darkPrimaryColor,
                    labelColor: kMainTextColor,
                    indicatorPadding: EdgeInsets.only(right: 15.0, left: 15.0),
                    tabs: [
                      Tab(text: 'Products'),
                      // Tab(text: 'Review'),
                      Tab(text: 'Information'),
                    ],
                  ),
                ),
              ];
            },
            body:
            Container(
              height: height,
              width: width,
              child:  Column(
                  children: [
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
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
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
                    heightSpace,
                    heightSpace,
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      height: 50,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.only(left: 5),

                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          autofocus: false,
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
                              color: kHintColor,
                            ),
                            hintText: 'Search Dishes...',
                          ),
                        ),
                        suggestionsCallback: (pattern) async {
                          return await BackendService.getSuggestions(pattern,widget.item.vendor_id);
                        },
                        itemBuilder: (context, Vendors suggestion) {
                          return ListTile(
                              title: Text('${suggestion.str1}'),
                              subtitle: Text('${suggestion.str2}'
                              )
                          );
                        },
                        hideOnError: true,
                        onSuggestionSelected: (Vendors detail) {
                          for(int i=0;i<categoryList.length;i++)
                          {
                            if(detail.product_id.toString()==categoryList[i].product_id.toString() ||
                                detail.str1.toString().trim().toLowerCase()==categoryList[i].product_name.toString().trim().toLowerCase()
                            )
                            {
                              CallSearch(categoryList[i],i);
                              print("CLICKED: " + categoryList[i].toString());
                            }
                          }
                        },
                      ),
                    ),
                    Container(
    height: height * 0.55,
    width: width,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
    color: kMainColor,
    ),
    child:
    TabBarView(
    children: [
    ProductTabData(widget.item,widget.currencySymbol,(){
      getCartCount();
    }),
                // ReviewTabData(widget.item),
                RestaurantInformation(widget.item),
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
                )

          )
          )
        ),

      ),
    );
  }

  void getResturantFavioute(dynamic id) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getcountRestcount(id).then((value) {
      print('$value');
      if (value == 1) {
        setState(() {
          favourite = true;
        });
      } else {
        setState(() {
          favourite = false;
        });
      }
    }).catchError((e) {
      print('${e}');
    });
  }

  void setFaviouriteResturant(NearStores item, BuildContext context) async {
    DatabaseHelper db = DatabaseHelper.instance;
    var vae = {
      DatabaseHelper.storeName:item.vendor_name,
      DatabaseHelper.vendor_name: item.vendor_name,
      DatabaseHelper.vendor_phone: item.vendor_phone,
      DatabaseHelper.vendor_id: item.vendor_id,
      DatabaseHelper.vendor_logo: item.vendor_logo,
      DatabaseHelper.vendor_category_id: item.vendor_category_id,
      DatabaseHelper.distance: item.distance,
      DatabaseHelper.lat: item.lat,
      DatabaseHelper.lng: item.lng,
      DatabaseHelper.delivery_range: item.delivery_range
    };
    db.insertRaturant(vae).then((value) {
      print('$value');
      setState(() {
        favourite = true;
      });
      (favourite)
          ?
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Added to Favourite'),
      ))
          :   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Remove from Favourite'),
            ));
    });
  }
  void CallSearch(CategoryResturant categoryListNew, int index) {
    {
      print(index);
      DatabaseHelper db =
          DatabaseHelper.instance;
      db.getRestProdQty(
          '${categoryListNew.variant[0].variant_id}')
          .then((value) {
        if (value != null) {
          setState(() {
            categoryListNew.variant[0].addOnQty = value;
          });
        } else {
          if (categoryListNew.variant[0].addOnQty > 0) {
            setState(() {
              categoryListNew.variant[0].addOnQty = 0;
            });
          }
        }
        db.calculateTotalRestAdonA(
            '${categoryListNew.variant[0].variant_id}')
            .then((value1) {
          double priced = 0.0;
          if (value != null) {
            var tagObjsJson =
            value1 as List;
            dynamic totalAmount_1 =
            tagObjsJson[0]['Total'];
            if (totalAmount_1 != null) {
              setState(() {
                priced = double.parse(
                    '${totalAmount_1}');
              });
            }
          }



          db.getAddOnList(
              '${categoryListNew.variant[0].variant_id}')
              .then((valued) {
            List<AddonList> addOnlist = [];
            if (valued != null &&
                valued.length > 0) {
              addOnlist = valued
                  .map((e) =>
                  AddonList.fromJson(e))
                  .toList();
              for (int i = 0;
              i < categoryListNew.addons.length;
              i++) {
                int ind = addOnlist.indexOf(
                    AddonList(
                        '${categoryListNew.addons[i].addon_id}'));
                if (ind != null && ind >= 0) {
                  setState(() {
                    categoryListNew.addons[i].isAdd =
                    true;
                  });
                }
              }
            }

            if(grocercart==1){
              print("ALREADY");
              showMyDialog(context);
            }
            else {
              productDescriptionModalBottomSheets(
                  context,
                  grocercart,
                  MediaQuery
                      .of(context)
                      .size
                      .height,
                  categoryListNew,
                  0, addOnlist,
                  widget.currencySymbol,
                  priced,
                      (){
                    getCartCount();
                  });
            }
          });
        });
      });
    }
  }

  removeFavourite(NearStores item, BuildContext context) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteResturant(item.vendor_id).then((value) {
      print('$value');
      setState(() {
        favourite = false;
      });
      (favourite)
          ?   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Added to Favourite'),
            ))
          :   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Remove from Favourite'),
            ));
    }).catchError((e) {
      print(e);
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // Widget no = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    Widget clear = GestureDetector(
      onTap: (){
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text('Clear',style: TextStyle(fontSize: 13,color: kWhiteColor),),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: (){
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: Text('No',style: TextStyle(fontSize: 13,color: kWhiteColor),),
        ),
      ),
    );

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [
        clear,
        no
      ],
    );


    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState((){
      message = pref.getString("message")!;
    });
  }
}
class BackendService {
  static Future<List<Vendors>> getSuggestions(String query,dynamic vendor_id) async {
    if (query.isEmpty && query.length < 2) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }

    var url = RestSearch_key;
    Uri myUri = Uri.parse(url);
    var response = await http.post(myUri, body: {
      'vendor_id':vendor_id.toString(),
      'prod_name': query
    });

    List<Vendors> vendors = [];
    List<Vendors> vendors1 = [];

    if (response.statusCode == 200) {
      Iterable json1 = jsonDecode(response.body)['restproduct'];
      Iterable json2 = jsonDecode(response.body)['restcat'];


      if (json1.isNotEmpty) {
        vendors.clear();
        vendors =
        List<Vendors>.from(json1.map((model) => Vendors.fromJson(model)));
      }
      if (json2.isNotEmpty) {
        vendors1.clear();
        vendors1 =
        List<Vendors>.from(json2.map((model) => Vendors.fromJson(model)));
        vendors.addAll(vendors1);
      }

    }

    return Future.value(vendors);
  }
}
