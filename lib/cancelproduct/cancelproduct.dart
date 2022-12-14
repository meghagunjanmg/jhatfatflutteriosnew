import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/cancelbean.dart';

class CancelProduct extends StatefulWidget {
  final dynamic cart_id;

  CancelProduct(this.cart_id);

  @override
  State<StatefulWidget> createState() {
    return CancelProductState();
  }
}

class CancelProductState extends State<CancelProduct> {
  List<CancelProductList> cancelListPro = [];

  var idd = -1;

  bool showDialogBox = false;

  @override
  void initState() {
    super.initState();
    getCancelReasonList();
  }

  getCancelReasonList() async {
    var client = http.Client();
    var url = cancelReasonList;
    Uri myUri = Uri.parse(url);

    client.get(myUri).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && value.body != null) {
        var js = jsonDecode(value.body);
        if (js['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CancelProductList> tagObjs = tagObjsJson
              .map((tagJson) => CancelProductList.fromJson(tagJson))
              .toList();
          if (tagObjs.length > 0) {
            setState(() {
              cancelListPro.clear();
              cancelListPro = tagObjs;
            });
          }
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(52.0),
          child: AppBar(
            titleSpacing: 0.0,
            title: Text(
              'Cancel Order Reason List',
              style: TextStyle(
                  fontSize: 18,
                  color: black_color,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${cancelListPro[index].reason}'),
                              Radio(
                                  value: index,
                                  groupValue: idd,
                                  onChanged: (value) {
                                    setState(() {
                                      idd = value!;
                                    });
                                  })
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: kCardBackgroundColor,
                            height: 2,
                          );
                        },
                        itemCount: cancelListPro.length),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kMainColor,
                        foregroundColor : kMainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        primary: Colors.purple,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle:TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400)),

                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: kWhiteColor, fontWeight: FontWeight.w400),
                    ),

                    onPressed: () {
                      setState(() {
                        showDialogBox = true;
                      });
                      if (idd == -1) {
                        Toast.show(
                            'Please select a reason to cancel the product!',
                             duration: Toast.lengthShort, gravity:  Toast.bottom);
                      } else {
                        hitService('${cancelListPro[idd].reason}', context);
                      }
                    },
                  ),
                ),
              ],
            ),
            Positioned.fill(
                child: Visibility(
              visible: showDialogBox,
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(
                  // color: black_color.withOpacity(0.6),
                  height: MediaQuery.of(context).size.height - 100,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            )),
          ],
        ));
  }

  void hitService(String s, BuildContext context) {
    var client = http.Client();
    var url = cancelOrderApi;
    Uri myUri = Uri.parse(url);
    client.post(myUri,
        body: {'reason': '${s}', 'cart_id': '${widget.cart_id}'}).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && value.body != null) {
        var js = jsonDecode(value.body);
        if (js['status'] == "1") {
          Toast.show(js['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
          Navigator.of(context).pop(true);
        } else {
          Toast.show('Prodcut not canceled.',  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}
