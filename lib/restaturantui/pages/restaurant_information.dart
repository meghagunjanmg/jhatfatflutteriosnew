import 'package:flutter/material.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/nearstorebean.dart';

class RestaurantInformation extends StatelessWidget {
  final NearStores item;
  RestaurantInformation(this.item);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Text(
            'About',
            style: headingStyle,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(fixPadding),
          child: Text(
            '${(item.about!=null)?item.about:''}',
            style: listItemTitleStyle,
            textAlign: TextAlign.justify,
          ),
        ),
        Container(
          margin: EdgeInsets.all(fixPadding * 1.5),
          width: width - (fixPadding * 3.0),
          height: 180.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(width: 2.0, color: kWhiteColor),
          ),
          child: Image.network('${imageBaseUrl}${item.vendor_logo}',fit: BoxFit.fitWidth,),
          // child: Image.asset('assets/restaurant_location.jpg', fit: BoxFit.cover),
        ),
      ],
    );
  }
}
