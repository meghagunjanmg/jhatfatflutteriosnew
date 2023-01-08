import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomeOrderAccount/Home/UI/Stores/stores.dart';
import '../HomeOrderAccount/home_order_account.dart';
import '../pharmacy/pharmastore.dart';
import '../restaturantui/ui/resturanthome.dart';

class CardContent extends StatelessWidget {
  final String? text;
  final String? image;
  final String? uiType;
  final String? vendorCategoryId;
  final BuildContext? context;


  CardContent(
  {required this.text,required this.image,required this.uiType,required this.vendorCategoryId,required this.context});

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap: (){
                           print(text);
          hitNavigator(
              context,
              text,
              uiType,
              vendorCategoryId
          );
    },
      child: Container(
          height: 120,
          width: 120,
          child:
            Card(
            elevation: 2,
            child: Container(
                height: 120,
                width: 120,
                child: Image.network(
                  '$image',
                  height: 120,
                  width: 120,
                  fit: BoxFit.fill,
                  alignment: Alignment.center,
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(left: 0.0, right: 0.0,top: 5,bottom: 5),
              //   child: Text(
              //     "$text",
              //     textAlign: TextAlign.center,
              //     overflow: TextOverflow.ellipsis,
              //     maxLines: 2,
              //     style: const TextStyle(
              //         fontSize: 12.0,
              //         fontWeight: FontWeight.w700,
              //         fontStyle: FontStyle.normal,
              //         wordSpacing: 0,
              //         height: 1),
              //   ),
              // ),
            )

      )
      );

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
    } else

      if (ui_type == "resturant" ||
        ui_type == "Resturant" ||
        ui_type == "2") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Restaurant("Urbanby Resturant")));



    }



      else if (ui_type == "pharmacy" ||
        ui_type == "Pharmacy" ||
        ui_type == "3") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPharmaPage('${category_name}', vendor_category_id)));
    }    else if (ui_type == "parcal" ||
          ui_type == "Parcal" ||
          ui_type == "4") {
        prefs.setString("vendor_cat_id", '${vendor_category_id}');
        prefs.setString("ui_type", '${ui_type}');
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
              return HomeOrderAccount(2);
            }), (Route<dynamic> route) => true);
      }
  }

}
