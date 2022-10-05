import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/Stores/stores.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/appcategory/appcategory.dart';
import 'package:jhatfat/HomeOrderAccount/Home/UI/home2.dart';

import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/nearstorebean.dart';
import 'package:jhatfat/pharmacy/pharmadetailpage.dart';
import 'package:jhatfat/pharmacy/pharmastore.dart';
import 'package:jhatfat/restaturantui/pages/restaurant.dart';
import 'package:jhatfat/restaturantui/ui/resturanthome.dart';


class CardContentNew extends StatelessWidget {
  final String text;
  final String image;
  final List<dynamic> list;
  final String ui_type;
  final int id;
  final BuildContext context;
  final double lat,lng;
  CardContentNew({required this.text,required this.image,required this.list,
    required this.ui_type,required this.id,required this.context,required this.lat,required this.lng});

  /// Outlines a text using shadows.
  static List<Shadow> outlinedText({double strokeWidth = 2, Color strokeColor = Colors.black, int precision = 5}) {
    Set<Shadow> result = HashSet();
    for (int x = 1; x < strokeWidth + precision; x++) {
      for(int y = 1; y < strokeWidth + precision; y++) {
        double offsetX = x.toDouble();
        double offsetY = y.toDouble();
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
        result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      }
    }
    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    print("** " + list.toString());
    var tagObjsJson = list;
      List<NearStores> tagObjs = tagObjsJson
          .map((tagJson) => NearStores.fromJson(tagJson))
          .toList();
      print("***** " + tagObjs[0].toString());

    void hitNavigator(context, category_name, ui_type,
        vendor_category_id) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (ui_type == "grocery" || ui_type == "Grocery" || ui_type == "Bakery"|| ui_type == "1") {
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
      }

      // else if (ui_type == "parcal" || ui_type == "Parcal" || ui_type == "4") {
      //   prefs.setString("vendor_cat_id", '${vendor_category_id}');
      //   prefs.setString("ui_type", '${ui_type}');
      //   hitNavigator1(
      //       context,
      //       lat,lng,
      //       tagObjs[0].vendor_name,
      //       tagObjs[0].vendor_id,
      //       tagObjs[0].distance);
      //
      //
      //   // Navigator.push(
      //   //     context,
      //   //     MaterialPageRoute(
      //   //         builder: (context) => ParcalStoresPage('${vendor_category_id}')));
      //
      // }
    }

      return
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Container(
                  margin: new EdgeInsets.symmetric(horizontal: 20.0,vertical: 20.0),
                  child:
                  new GestureDetector(
                  onTap: () {
                    hitNavigator(context, text, ui_type,id);
                  },
                  child: Text(
                    text,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20
                    ),
                  ),
                  ),

                )
            ),
            ConstrainedBox(
                constraints: new BoxConstraints(
                  minWidth: 170,
                  maxHeight: 120,
                ),
                child:

                  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Card(
                              margin: EdgeInsets.all(8),
                              child:
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width: 170,
                                      height: 150,
                                      child: new GestureDetector(
                                          onTap: () {
                                            print("Container clicked 2");
                                            if (ui_type == "1") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AppCategory(
                                                              tagObjs[index]
                                                                  .vendor_name,
                                                              tagObjs[index]
                                                                  .vendor_id,
                                                              tagObjs[index]
                                                                  .distance)))
                                                  .then((value) {
                                                //getCartCount();
                                              });
                                            }
                                            else if (ui_type == "2") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Restaurant_Sub(
                                                              tagObjs[index],
                                                              "Rs ")))
                                                  .then((value) {});
                                            }

                                            else if (ui_type == "3") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PharmaItemPage(
                                                              tagObjs[index]
                                                                  .vendor_name,
                                                              tagObjs[index]
                                                                  .vendor_id,
                                                              tagObjs[index]
                                                                  .delivery_range,
                                                              tagObjs[index]
                                                                  .distance)))
                                                  .then((value) {});
                                            }
                                            else if (ui_type == "4") {
                                              hitNavigator(
                                                  context,
                                                  text,
                                                  ui_type,
                                                  id);
                                            }
                                          }
                                          ,
                                          child: Container(
                                              width: 160,
                                              height: 120,
                                              child:
                                              Column(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Container(
                                                        child: Image.network(
                                                         imageBaseUrl+tagObjs[index]
                                                              .vendor_logo,
                                                          height: 100,
                                                          width: 120,
                                                          fit: BoxFit.fill,
                                                          alignment: Alignment
                                                              .center,
                                                        ),

                                                      ),
                                                    ),
                                                    Container(
                                                        height: 80,
                                                        width: 100,
                                                        child:
                                                        Text(
                                                          tagObjs[index]
                                                              .vendor_name,
                                                          textAlign: TextAlign
                                                              .center,
                                                          style: TextStyle(
                                                              color: black_color,
                                                              fontWeight: FontWeight
                                                                  .w500,
                                                              fontSize: 14),
                                                        )
                                                    ),
                                                  ]
                                              )
                                          )
                                      ),

                                    )
                                  ]
                              )
                          )
                  )

            )

          ]
      );
    }
  }
