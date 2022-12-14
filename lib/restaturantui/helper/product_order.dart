import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/resturantbean/addonidlist.dart';
import 'package:jhatfat/bean/resturantbean/popular_item.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';
import 'package:jhatfat/restaturantui/helper/add_to_cartbottomsheet.dart';

class ProductsOrdered extends StatefulWidget {
  List<PopularItem> popularItem;
  final dynamic currencySymbol;
  final VoidCallback onVerificationDone;

  ProductsOrdered(
      this.currencySymbol, this.popularItem, this.onVerificationDone);

  @override
  _ProductsOrderedState createState() => _ProductsOrderedState();
}

class _ProductsOrderedState extends State<ProductsOrdered> {
  List<PopularItem> popularItem = [];

  bool isFetch = false;

  @override
  void initState() {
    popularItem = widget.popularItem;
    super.initState();
  }

  void hitBannerUrl() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isFetch = true;
    });
    var url = popular_item;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${preferences.getString('vendor_cat_id')}'
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
              isFetch = false;
              popularItem.clear();
              popularItem = tagObjs;
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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Visibility(
      visible: (!isFetch && popularItem.length == 0) ? false : true,
      child: Container(
        width: width,
        height: 170.0,
        child: (popularItem != null && popularItem.length > 0)
            ? ListView.builder(
                itemCount: popularItem.length,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = popularItem[index];
                  return InkWell(
                    onTap: () async {
                      DatabaseHelper db = DatabaseHelper.instance;
                      db.getRestProdQty('${item.variant_id}').then((value) {
                        print('dddd - ${value}');
                        int index = item.variant.indexOf(PopularItemListd(
                            item.variant_id,
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            0,
                            0,
                            false));
                        if (value != null) {
                          setState(() {
                            item.variant[index].addOnQty = value;
                          });
                        } else {
                          if (item.variant[index].addOnQty > 0) {
                            setState(() {
                              item.variant[index].addOnQty = 0;
                            });
                          }
                        }
                        db.getAddOnList('${item.variant_id}').then((valued) {
                          List<AddonList> addOnlist = [];
                          if (valued != null && valued.length > 0) {
                            addOnlist = valued
                                .map((e) => AddonList.fromJson(e))
                                .toList();
                            for (int i = 0; i < item.addons.length; i++) {
                              int ind = addOnlist.indexOf(
                                  AddonList('${item.addons[i].addon_id}'));
                              if (ind != null && ind >= 0) {
                                setState(() {
                                  item.addons[i].isAdd = true;
                                });
                              }
                            }
                          }
                          db
                              .calculateTotalRestAdonA('${item.variant_id}')
                              .then((value1) {
                            double priced = 0.0;
                            print('${value1}');
                            if (value != null) {
                              var tagObjsJson = value1 as List;
                              dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                              print('${totalAmount_1}');
                              if (totalAmount_1 != null) {
                                setState(() {
                                  priced = double.parse('${totalAmount_1}');
                                });
                              }
                            }
                            productDescriptionModalBottomSheet(
                                    context,
                                    MediaQuery.of(context).size.height,
                                    item,
                                    widget.currencySymbol,
                                    priced)
                                .then((value) {
                              widget.onVerificationDone();
                            });
                          });
                        });
                      });
                    },
                    child: Container(
                      width: 130.0,
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      margin: (index != (popularItem.length - 1))
                          ? EdgeInsets.only(left: fixPadding)
                          : EdgeInsets.only(
                              left: fixPadding, right: fixPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 110.0,
                            width: 130.0,
                            // alignment: Alignment.topRight,
                            padding: EdgeInsets.all(fixPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(5.0)),
                            ),
                            child: Stack(
                              children: [
                                Image.network(
                                  imageBaseUrl + item.product_image,
                                  fit: BoxFit.fill,
                                  height: 110.0,
                                  width: 130.0,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 130.0,
                            height: 50.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    item.product_name,
                                    style: listItemTitleStyle,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 5.0, right: 5.0),
                                  child: Text(
                                    '${item.deal_price}',
                                    style: listItemSubTitleStyle,
                                    textAlign: TextAlign.start,
                                    // maxLines: 1,
                                    // overflow: TextOverflow.ellipsis,
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
              )
            : (isFetch)
                ? ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      // final item = productList[index];
                      return InkWell(
                        onTap: () {},
                        child: Container(
                          width: 130.0,
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          margin: EdgeInsets.only(
                              left: fixPadding, right: fixPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Shimmer(
                                duration: Duration(seconds: 3),
                                color: Colors.white,
                                enabled: true,
                                direction: ShimmerDirection.fromLTRB(),
                                child: Container(
                                  width: 130.0,
                                  height: 110.0,
                                  color: kTransparentColor,
                                ),
                              ),
                              Container(
                                width: 130.0,
                                height: 50.0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Shimmer(
                                        duration: Duration(seconds: 3),
                                        color: Colors.white,
                                        enabled: true,
                                        direction: ShimmerDirection.fromLTRB(),
                                        child: Container(
                                          width: 130.0,
                                          height: 10.0,
                                          color: kTransparentColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      child: Shimmer(
                                        duration: Duration(seconds: 3),
                                        color: Colors.white,
                                        enabled: true,
                                        direction: ShimmerDirection.fromLTRB(),
                                        child: Container(
                                          width: 130.0,
                                          height: 10.0,
                                          color: kTransparentColor,
                                        ),
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
                  )
                : Container(),
      ),
    );
  }
}
