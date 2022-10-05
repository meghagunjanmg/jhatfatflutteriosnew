import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/HomeOrderAccount/Account/UI/ListItems/editaddresspage.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/address.dart';
import 'package:toast/toast.dart';

import '../../../../Routes/routes.dart';
import 'addaddresspage.dart';

class SavedAddressesPage extends StatelessWidget {
  final dynamic vendorId;

  SavedAddressesPage(this.vendorId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kCardBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0.0,
          title: Text(
            'Saved Addresses',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        body: SavedAddresses(vendorId));
  }
}

class SavedAddresses extends StatefulWidget {
  final dynamic vendorId;

  SavedAddresses(this.vendorId);

  @override
  _SavedAddressesState createState() => _SavedAddressesState();
}

class _SavedAddressesState extends State<SavedAddresses> {
  List<ShowAddress> showAddressList = [];

  // List<ShowAddress> showAddressList2 = [];
  // List<ShowAddress> showAddressList3 = [];

  var idd = -1;
  var idd1 = -1;

  bool showDialogBox = false;
  bool isVendor_list = false;
  bool isFetchAdd = false;
  bool adminSelection = false;
  dynamic currency = '';

  List<ShowAddressNew> addressDelivery = [];
  final GlobalKey _textKey = GlobalKey();
  //AddressBloc _addressBloc;
  @override
  void initState() {
    super.initState();
//    _addressBloc = BlocProvider.of<AddressBloc>(context);
//    _addressBloc.add(FetchAddressesEvent());
    if (widget.vendorId != null &&
        widget.vendorId.toString().length > 0 &&
        widget.vendorId != "") {
      getVendorAddress(context);
    } else {
      setState(() {
        isFetchAdd = true;
      });
      getAddress(context);
    }
    // getAddress2();
    // getAddress3();
  }

  void deleteAddressList() async {
    for (ShowAddressNew dd in addressDelivery) {
      showAddressList.removeWhere((element) =>
      element.address_id.toString() == dd.addressId.toString());
    }
  }

  void getVendorAddress(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isVendor_list = true;
      isFetchAdd = true;
      currency = prefs.getString('curency');
    });
    int? userId = prefs.getInt('user_id');
    String? vendorId = prefs.getString('vendor_id');
    print('${vendorId} - ${userId}');
    var url = address_selection;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': '${userId}',
      'vendor_id': '${vendorId}'
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = json.decode(value.body);
        if (jsonData['status'] == "1" &&
            jsonData['data'] != null &&
            jsonData['data'] != 'null') {
          var jsonD2 = jsonData['data'] as List;
          print('${jsonD2.toString()}');
          if (jsonD2 != null) {
            List<ShowAddressNew> tagObjs =
            jsonD2.map((e) => ShowAddressNew.fromJson(e)).toList();
            setState(() {
              isVendor_list = false;
              addressDelivery = List.from(tagObjs);
            });
          } else {
            setState(() {
              isVendor_list = false;
              addressDelivery.clear();
            });
          }
          getAddress(context);
        } else {
          setState(() {
            isVendor_list = false;
          });
          getAddress(context);
          // Toast.show("Address not found!", context,
          //     duration: Toast.LENGTH_SHORT);
        }
        // setState(() {
        //   isCartFetch = false;
        // });
      } else {
        setState(() {
          isVendor_list = false;
        });
        getAddress(context);
        // Toast.show('No Address found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      setState(() {
        isVendor_list = false;
      });
      getAddress(context);
      print(e);
    });
  }

  void getAddress(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print('${userId}');
    // String vendorId = prefs.getString('vendor_id');
    setState(() {
      currency = prefs.getString('curency');
    });
    var url = showAddress;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': '${userId}'
      // 'vendor_id': '${(vendorId==null || vendorId=="null")?"":vendorId}'
    }).then((value) {
      print('ddd ${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<ShowAddress> tagObjs = tagObjsJson
              .map((tagJson) => ShowAddress.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isFetchAdd = false;
              showAddressList.clear();
              showAddressList = tagObjs;
              if (addressDelivery.length > 0) {
                int index = addressDelivery.indexOf(ShowAddressNew('', '', '', '', '', '', '',
                    '', '', '', '', '1', '', '', '', '','','','','',''));
                idd1 = index;
                deleteAddressList();
              }else{
                int index1 = showAddressList.indexOf(ShowAddress('', '', '', '', '', '', '',
                    '', '', '', '', '1', '', '', '', '','','','','','',''));
                idd = index1;
                print('${idd}');
              }
            });
          } else {
            setState(() {
              isFetchAdd = false;
              showAddressList.clear();
            });
          }
        } else {
          setState(() {
            isFetchAdd = false;
            showAddressList.clear();
          });
          Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
      } else {
        setState(() {
          isFetchAdd = false;
        });
        Toast.show('No address found!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetchAdd = false;
      });
      // Toast.show('Please try again!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic height = MediaQuery.of(context).size.height;
    return
      SingleChildScrollView(
          child:
          Column(
              children: [
      Stack(
      children: [
        Stack(
          children: <Widget>[

            ((showAddressList != null && showAddressList.length > 0) ||
                (addressDelivery != null && addressDelivery.length > 0))
                ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height-200,
              child:  Column(
                  children: [
                    Visibility(
                      visible: (addressDelivery != null &&
                          addressDelivery.length > 0)
                          ? true
                          : false,
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: addressDelivery.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                Divider(
                                  height: 6.0,
                                  color: kCardBackgroundColor,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 6.0),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                        kCardBackgroundColor,
                                        child: ImageIcon(
                                          AssetImage(
                                              'images/address/ic_homeblk.png'),
                                          color: kMainColor,
                                          size: 28,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 8.0, bottom: 8.0),
                                              child: Text(
                                                '${addressDelivery[index].address}',
                                                style: listTitleTextStyle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: [
                                            IconButton(
                                                icon: Icon(Icons.edit),
                                                iconSize: 24.0,
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) {
                                                            return EditAddresspage(
                                                              addressDelivery[
                                                              index]
                                                                  .lat,
                                                              addressDelivery[
                                                              index]
                                                                  .lng,
                                                              addressDelivery[
                                                              index]
                                                                  .pincode,
                                                              addressDelivery[
                                                              index]
                                                                  .houseno,
                                                              addressDelivery[
                                                              index]
                                                                  .address,
                                                              addressDelivery[
                                                              index]
                                                                  .state,
                                                              addressDelivery[
                                                              index]
                                                                  .addressId,
                                                              widget.vendorId,
                                                              addressDelivery[
                                                              index]
                                                                  .cityId,
                                                              addressDelivery[
                                                              index]
                                                                  .areaId,
                                                              (addressDelivery[
                                                              index]
                                                                  .type!=null)?addressDelivery[
                                                              index]
                                                                  .type:'Other',);
                                                          })).then((value) {
                                                    if (widget.vendorId != null &&
                                                        widget.vendorId.toString().length > 0 &&
                                                        widget.vendorId != "") {
                                                      getVendorAddress(context);
                                                    } else {
                                                      setState(() {
                                                        isFetchAdd = true;
                                                      });
                                                      getAddress(context);
                                                    }
                                                  });
                                                }),
                                            Radio(
                                                value: index,
                                                groupValue: idd1,
                                                onChanged: (value) {
                                                  setState(() {
                                                    idd1 = index;
                                                    showDialogBox = true;
                                                  });
                                                  selectAddressd(
                                                      addressDelivery[index]
                                                          .addressId,
                                                      widget.vendorId);
                                                }),
                                            IconButton(
                                                icon: Icon(Icons.delete),
                                                iconSize: 24.0,
                                                onPressed: () {
                                                  setState(() {
                                                    showDialogBox = true;
                                                    deleteAddress(
                                                        addressDelivery[index].addressId,
                                                        context);
                                                  });
                                                }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                    Visibility(
                      visible: (showAddressList != null &&
                          showAddressList.length > 0)
                          ? true
                          : false,
                      child: ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: showAddressList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                Divider(
                                  height: 6.0,
                                  color: kCardBackgroundColor,
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 6.0),
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor:
                                            kCardBackgroundColor,
                                            child: ImageIcon(
                                              AssetImage(
                                                  'images/address/ic_homeblk.png'),
                                              color: kMainColor,
                                              size: 28,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0, bottom: 8.0),
                                                  child: Text(
                                                    '${showAddressList[index].address}',
                                                    style: listTitleTextStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Visibility(
                                                  visible: (widget.vendorId !=
                                                      null &&
                                                      widget.vendorId
                                                          .toString()
                                                          .length >
                                                          0 &&
                                                      widget.vendorId != "")
                                                      ? true
                                                      : false,
                                                  child: IconButton(
                                                      icon: Icon(Icons.edit),
                                                      iconSize: 24.0,
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                                  return EditAddresspage(
                                                                      showAddressList[
                                                                      index]
                                                                          .lat,
                                                                      showAddressList[
                                                                      index]
                                                                          .lng,
                                                                      showAddressList[
                                                                      index]
                                                                          .pincode,
                                                                      showAddressList[
                                                                      index]
                                                                          .houseno,
                                                                      showAddressList[
                                                                      index].street,
                                                                      showAddressList[
                                                                      index]
                                                                          .state,
                                                                      showAddressList[
                                                                      index]
                                                                          .address_id,
                                                                      widget.vendorId,
                                                                      showAddressList[
                                                                      index].city_id,
                                                                      showAddressList[
                                                                      index].area_id,
                                                                      (showAddressList[
                                                                      index].type!=null)?showAddressList[
                                                                      index].type:'Other');
                                                                })).then((value) {
                                                          if (widget.vendorId != null &&
                                                              widget.vendorId.toString().length > 0 &&
                                                              widget.vendorId != "") {
                                                            getVendorAddress(context);
                                                          } else {
                                                            setState(() {
                                                              isFetchAdd = true;
                                                            });
                                                            getAddress(context);
                                                          }
                                                        });
                                                      }),
                                                ),
                                                Radio(
                                                    value: index,
                                                    groupValue: idd,
                                                    onChanged: (value) {
                                                      if(addressDelivery!=null && addressDelivery.length>0){

                                                      }else{
                                                        setState(() {
                                                          idd = index;
                                                          showDialogBox = true;
                                                        });
                                                        selectAddressd(
                                                            showAddressList[index]
                                                                .address_id,
                                                            widget.vendorId);
                                                      }
                                                    }),
                                                IconButton(
                                                    icon: Icon(Icons.delete),
                                                    iconSize: 24.0,
                                                    onPressed: () {
                                                      setState(() {
                                                        showDialogBox = true;
                                                        deleteAddress(
                                                            showAddressList[
                                                            index]
                                                                .address_id,
                                                            context);
                                                      });
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 50,
                                        child: Visibility(
                                          visible:(addressDelivery != null && addressDelivery.length > 0)?true:false,
                                          child: Container(
                                            padding:EdgeInsets.symmetric(vertical: 10),
                                            width: MediaQuery.of(context).size.width,
                                            alignment: Alignment.center,
                                            color:kCardBackgroundColor,
                                            child: Text('We are not delivery this address',style: TextStyle(fontSize: 13),),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
            ): Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (isVendor_list || isFetchAdd)
                      ? CircularProgressIndicator()
                      : Container(
                    width: 0.5,
                  ),
                  (isVendor_list || isFetchAdd)
                      ? SizedBox(
                    width: 10,
                  )
                      : Container(
                    width: 0.5,
                  ),
                  Text(
                    (isVendor_list || isFetchAdd)
                        ? 'Fetching address'
                        : 'No address found',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kMainTextColor),
                  )
                ],
              ),
            ),
          ],
        ),
        Positioned.fill(
            child: Visibility(
              visible: showDialogBox,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        color: white_color,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Loading please wait!....',
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ],
      ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: (widget.vendorId != null &&
                  widget.vendorId.toString().length > 0 &&
                  widget.vendorId != "")
                  ? true
                  : false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  primary: kMainColor,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),

                onPressed: () {
//                  Navigator.pushNamed(context, PageRoutes.locationPage);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddAddressPage(widget.vendorId);
                  })).then((value) {
                    if (widget.vendorId != null &&
                        widget.vendorId.toString().length > 0 &&
                        widget.vendorId != "") {
                      getVendorAddress(context);
                    } else {
                      setState(() {
                        isFetchAdd = true;
                      });
                      getAddress(context);
                    }
                  });
                }, child: Text("Add New",style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
              ),

              ),
            ),
          )
])
      );
  }

  void selectAddressd(dynamic value, vendorId) async {
    var url = selectAddress;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {'address_id': '${value}'}).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          // Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
          if (vendorId != null && vendorId != "") {
            Navigator.pop(context);
          }
        } else {
          // Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        // Toast.show('Unable to select address', duration: Toast.lengthShort, gravity:  Toast.bottom);
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      // Toast.show('Please try again!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void deleteAddress(dynamic value, context) async {
    var url = removeAddress;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'address_id': '${value}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
         // Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        } else {
        //  Toast.show(jsonData['message'],  duration: Toast.lengthShort, gravity:  Toast.bottom);
        }
        setState(() {
          showDialogBox = false;
          getAddress(context);
        });
      } else {
        // Toast.show('Unable to select address', duration: Toast.lengthShort, gravity:  Toast.bottom);
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      // Toast.show('Please try again!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}

