import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Themes/colors.dart';
import '../../baseurlp/baseurl.dart';
import 'package:http/http.dart' as http;

import '../../bean/bannerbean.dart';


class ClosedStateless extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Closed(),
    );
  }
}

class Closed extends StatefulWidget {

  @override
  _ClosedState createState() => _ClosedState();
}
class _ClosedState extends State<Closed> {
  String ClosedImage = '';
  List<BannerDetails> ClosedBannerImage = [];
  bool isLoading = false;

  _ClosedState();


  @override
  void initState() {
    super.initState();
    ClosedBanner();
  }
  void ClosedBanner() async {
    setState(() {
      isLoading = true;
    });
    var url2 = closed_banner;
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
            ClosedBannerImage.clear();
            ClosedBannerImage = tagObjs;
            ClosedImage = imageBaseUrl + tagObjs[0].bannerImage;
          });

          setState(() {
            isLoading = false;
          });
        }
      }
    } on Exception catch (_) {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Loading
          Align(
            alignment: Alignment.center,
            child: isLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kMainColor),
                ),
              ),
              color: Colors.white.withOpacity(0.8),
            )
                : Container(),
          ),
        Align(
            alignment: Alignment.center,
        child: Dialog(
        child: Container(
        decoration: BoxDecoration(
        color: white_color,
        borderRadius:
        BorderRadius.circular(20.0),
    ),
    child: Image.network(
      ClosedImage,
    fit: BoxFit.fill,
    ),
    ),
        ))]
        ),
);
  }

}