import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Pages/items.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/categorylist.dart';
import 'package:jhatfat/bean/vendorbanner.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/dealofferpack/dealproduct.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../bean/productlistvarient.dart';
import '../../../../bean/venderbean.dart';
import '../../../../singleproductpage/singleproductpage.dart';

class AppCategory extends StatefulWidget {
  final String pageTitle;
  final dynamic vendor_id;
  final dynamic distance;
  final dynamic vendorCategoryId;

  AppCategory(this.vendorCategoryId,this.pageTitle, this.vendor_id, this.distance) {
    setStoreName(pageTitle);
  }

  void setStoreName(pageTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("store_name", pageTitle);
  }

  @override
  State<StatefulWidget> createState() {
    return AppCategoryState(vendorCategoryId,pageTitle, vendor_id);
  }
}

class AppCategoryState extends State<AppCategory> {
  final String pageTitle;
  final dynamic vendor_id;
  final dynamic vendorCategoryId;
  bool isCartCount = false;
  bool isFetch = false;
  int cartCount = 0;
  String message = "";
  String curency = "";
  bool isNoCategoryTrue = false;

  TextEditingController searchController = TextEditingController();

  AppCategoryState(this.vendorCategoryId,this.pageTitle, this.vendor_id);

  List<VendorBanner> listImage = [];
  List<String> listImages = ['', '', '', '', ''];
  List<CategoryList> categoryLists = [];
  List<CategoryList> categoryListsSearch = [];
  List<CategoryList> categoryListsDemo = [
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', '')
  ];
  ProductWithVarient? productWithVarient;

  @override
  void initState() {
    super.initState();
    getData();
    hitBannerUrl();
    Timer(Duration(seconds: 1), () {
      hitServices();
    });
    getCartCount();
  }

  void hitBannerUrl() async {
    setState(() {
      isFetch = true;
    });
    var url = vendorBanner;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {'vendor_id': '$vendor_id'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        print('Response Body: - ${value.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<VendorBanner> tagObjs = tagObjsJson
              .map((tagJson) => VendorBanner.fromJson(tagJson))
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
      }
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCount().then((value) {
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

  bool isSearchOpen = false;



  @override
  void dispose() {
    super.dispose();
  }

  void setList() {
    if (searchController != null && searchController.text.length > 0) {
      setState(() {
        searchController.clear();
        categoryLists.clear();
        categoryLists = List.from(categoryListsSearch);
      });
    } else {
      setState(() {
        isSearchOpen = false;
        categoryLists.clear();
        categoryLists = List.from(categoryListsSearch);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // bool valued = await handlePopBack();
        if (isSearchOpen) {
          setList();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isSearchOpen ? 60 : 112.0),
          child:
          CustomAppBar(
                  titleWidget: Text(
                    pageTitle,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  actions: [
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 2.0),
                    //   child: IconButton(
                    //       icon: Icon(
                    //         Icons.search,
                    //         color: kHintColor,
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           isSearchOpen = !isSearchOpen;
                    //         });
                    //       }),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Stack(
                        children: [
                          IconButton(
                              icon: ImageIcon(
                                AssetImage('images/icons/ic_cart blk.png'),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, PageRoutes.viewCart)
                                    .then((value) {
                                  getCartCount();
                                });
                              }),
                          // Positioned(
                          //     right: 5,
                          //     top: 2,
                          //     child: Visibility(
                          //       visible: isCartCount,
                          //       child: CircleAvatar(
                          //         minRadius: 4,
                          //         maxRadius: 8,
                          //         backgroundColor: kMainColor,
                          //         child: Text(
                          //           '$cartCount',
                          //           overflow: TextOverflow.ellipsis,
                          //           style: TextStyle(
                          //               fontSize: 7,
                          //               color: kWhiteColor,
                          //               fontWeight: FontWeight.w200),
                          //         ),
                          //       ),
                          //     ))
                        ],
                      ),
                    ),                  ],
                  bottom:
                  PreferredSize(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DealProducts(
                                      pageTitle,
                                      '',
                                      '',
                                      widget.distance,
                                      widget.vendor_id))).then((value) {
                            getCartCount();
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Card(
                          color: kMainColor,
                          elevation: 0.1,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 52,
                            color: kMainColor,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Deal/Offer Zone',
                                  style: TextStyle(color: kWhiteColor),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: kWhiteColor,
                                      size: 24,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      preferredSize:
                          Size(MediaQuery.of(context).size.width, 52)),
                ),
        ),
        body:
        Container(
          height:
              MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            primary: true,
            child: Column(
              children: [
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
                        hintText: 'Search Items...',
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await BackendService.getSuggestions(pattern,widget.vendor_id);
                    },
                    itemBuilder: (context, ProductWithVarient suggestion) {
                      return ListTile(
                          title: Text('${suggestion.str1}'),
                          subtitle: Text('${suggestion.str2}'
                          )
                      );
                    },
                    hideOnError: true,
                    onSuggestionSelected: (ProductWithVarient detail) {
                      if(detail.category_id!=null){
                        hitNavigator(
                            context,
                            pageTitle,
                            vendor_id,
                            detail.category_name,
                            detail.category_id,
                            widget.distance);
                      }

                      else if (detail.product_id!=null){
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return SingleProductPage(
                                detail,
                                curency,
                              );
                            }));
                      }
                    },
                  ),
                ),

                (vendorCategoryId==18 && Platform.isAndroid)?
                Container(
                    color: kMainColor,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Center(child: Text("For More Pan Store Items, Visit Our Web",
                          style: TextStyle(fontSize: 20),
                        )),
                    Center(child: Text(
                            'jhatfat.com/web',
                            style: TextStyle(decoration: TextDecoration.underline,fontSize: 20),
                          ),
                )
                   ] ),
                )
                :
                Text(" "),

                Visibility(
                  visible: (!isFetch && listImage.length == 0) ? false : true,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 5),
                    child: CarouselSlider(
                        options: CarouselOptions(
                          height: 170.0,
                          autoPlay: true,
                          initialPage: 0,
                          viewportFraction: 0.9,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          scrollDirection: Axis.horizontal,
                        ),
                        items: (listImage != null && listImage.length > 0)
                            ? listImage.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return InkWell(
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: Material(
                                          elevation: 5,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: Container(
                                            width: MediaQuery.of(context)
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
                                              imageBaseUrl + e.banner_image,
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
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
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
                (isSearchOpen ||
                        categoryLists != null && categoryLists.length > 0)
                    ? Padding(
                        padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                          controller: ScrollController(keepScrollOffset: false),
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          children: categoryLists.map((e) {
                            return GestureDetector(
                              onTap: () {
                                hitNavigator(
                                    context,
                                    pageTitle,
                                    vendor_id,
                                    e.category_name,
                                    e.category_id,
                                    widget.distance);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 3),
                                color: kCardBackgroundColor,
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: kWhiteColor),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10.0),
                                        child: Image.network(
                                          '${imageBaseUrl}${e.category_image}',
                                          height: 100,
                                          width: 120,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          e.category_name,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: black_color,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : (isNoCategoryTrue != true)
                        ? Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 30),
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              controller:
                                  ScrollController(keepScrollOffset: false),
                              shrinkWrap: true,
                              primary: false,
                              scrollDirection: Axis.vertical,
                              children: categoryListsDemo.map((e) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 3),
                                  color: kCardBackgroundColor,
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: kWhiteColor),
                                    child: Container(
                                      color: white_color,
                                      height: 120,
                                      child: Shimmer(
                                        duration: Duration(seconds: 3),
                                        color: Colors.black38,
                                        enabled: true,
                                        direction: ShimmerDirection.fromLTRB(),
                                        child: Container(
                                          height: 120,
                                          color: kTransparentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ))
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 120,
                            alignment: Alignment.center,
                            child: Text(
                              'No category found for this store ${widget.pageTitle}',
                              style: TextStyle(
                                  color: kMainColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
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
      ),
    );
  }

  void hitServices() async {
    var url = categoryList;
    Uri myUri = Uri.parse(url);
    var response =
        await http.post(myUri, body: {'vendor_id': vendor_id.toString()});
    try {
      print("752   "+response.body.toString());

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryList> tagObjs = tagObjsJson
              .map((tagJson) => CategoryList.fromJson(tagJson))
              .toList();
          setState(() {
            isNoCategoryTrue = false;
            categoryLists.clear();
            categoryListsSearch.clear();
            categoryLists = tagObjs;
            categoryListsSearch = List.from(categoryLists);
          });
        } else {
          setState(() {
            isNoCategoryTrue = true;
            categoryLists.clear();
            categoryLists = [];
          });
          Toast.show('No Category found!', duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      }
    } on Exception catch (_) {
      Toast.show('No Category found!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      Timer(Duration(seconds: 5), () {
        hitServices();
      });
    }
  }

  void hitNavigator(context, pageTitle,vendor_id, category_name, category_id, distance) {
    print(pageTitle+" "+category_name+" "+category_id.toString()+" "+distance.toString());
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ItemsPage(pageTitle,vendor_id, category_name, category_id, distance)))
        .then((value) {
      getCartCount();
    });
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      message = prefs.getString("message")!;
      curency = prefs.getString("curency")!;
    });
  }

}

class BackendService {
  static Future<List<ProductWithVarient>> getSuggestions(String query,
      dynamic vendor_id) async {
    if (query.isEmpty && query.length < 2) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }

    var url = storesearch;
    Uri myUri = Uri.parse(url);
    var response = await http.post(myUri, body: {
      'vendor_id': vendor_id.toString(),
      'prod_name': query
    });

    List<ProductWithVarient> vendors = [];
    List<ProductWithVarient> vendors1 = [];

    if (response.statusCode == 200) {
      Iterable json1 = jsonDecode(response.body)['product'];
      Iterable json2 = jsonDecode(response.body)['cat'];


      if (json1.isNotEmpty) {
        vendors.clear();
        vendors =
        List<ProductWithVarient>.from(json1.map((model) => ProductWithVarient.fromJson(model)));
      }
      if (json2.isNotEmpty) {
        vendors1.clear();
        vendors1 =
        List<ProductWithVarient>.from(json2.map((model) => ProductWithVarient.fromJson(model)));
        vendors.addAll(vendors1);
      }
    }

    return Future.value(vendors);
  }
}