import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Components/entry_field.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/address.dart';

import '../../../../Themes/constantfile.dart';

class AddAddressPage extends StatefulWidget {
  final dynamic vendorId;
  AddAddressPage(this.vendorId);

  @override
  State<StatefulWidget> createState() {
    return AddAddressState();
  }
}

class AddAddressState extends State<AddAddressPage> {
  var pincodeController = TextEditingController();
  var houseController = TextEditingController();
  var streetController = TextEditingController();
  var stateController = TextEditingController();

  List<CityList> cityListt = [];
  List<AreaList> areaList = [];
  List<String> addressTyp = [
    'Home',
    'Office',
    'Other',
  ];
  String selectCity = 'Select city';
  String addressType = 'Select address type';
  String selectArea = 'Select near by area';
  bool showDialogBox = false;
  dynamic selectAreaId;
  dynamic selectCityId;
  dynamic lat;
  dynamic lng;
  CameraPosition? kGooglePlex;


  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  bool isCard = false;
  Completer<GoogleMapController> _controller = Completer();

  var isVisible = false;

  var currentAddress = '';
  var message = '';

  @override
  void initState() {
    super.initState();
    getData();
    getCityList();
    _getLocation(context);
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
            desiredAccuracy: LocationAccuracy.high);
         double lat = position.latitude;
        double lng = position.longitude;

         setState(() {
           this.lat = lat;
           this.lng = lng;
         });
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: lat,
            longitude: lng,
            googleMapApiKey:apiKey);

        setState(() {
            if (data.postalCode.isNotEmpty) {
              pincodeController.text = data.postalCode;
            }
            if (data.state.isNotEmpty) {
              stateController.text = data.state;
            }
          });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation(context);
          } else {
            //Toast.show('Location permission is required!', duration: Toast.lengthShort, gravity:  Toast.bottom);
          }
        }).catchError((e) {
          //Toast.show('Location permission is required!',  duration: Toast.lengthShort, gravity:  Toast.bottom);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation(context);
      } else {
        //Toast.show('Location permission is required!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation(context);

      }).catchError((e) {
       // Toast.show('Location permission is required!', duration: Toast.lengthShort, gravity:  Toast.bottom);
      });
    }
  }

  void getCityList() async {
    var url = cityList;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '${widget.vendorId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CityList> tagObjs =
              tagObjsJson.map((tagJson) => CityList.fromJson(tagJson)).toList();
          setState(() {
            cityListt.clear();
            cityListt = tagObjs;
          });
        }
      }
    });
  }

  void getAreaList(dynamic city_id) async {
    var url = areaLists;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '${widget.vendorId}',
      'city_id': '${city_id}',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<AreaList> tagObjs =
              tagObjsJson.map((tagJson) => AreaList.fromJson(tagJson)).toList();
          setState(() {
            areaList.clear();
            areaList = tagObjs;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        title: Text(
          'Add Address',
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      body:
      SingleChildScrollView(
        primary: true,
        child:
      Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              child: Stack(
                children: [
               Column(
                      children: [
                        Container(
                          height: 400,
                          child:
                          GoogleMap(
                            gestureRecognizers: < Factory < OneSequenceGestureRecognizer >> [
                              new Factory < OneSequenceGestureRecognizer > (
                                    () => new EagerGestureRecognizer(),
                              ),
                            ].toSet(),
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(lat,lng),
                              zoom: 14.0,
                            ),
                            zoomControlsEnabled: true,
                            myLocationButtonEnabled: true,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            buildingsEnabled: false,
                            markers: markers.values.toSet(),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                              final marker = Marker(
                                markerId: MarkerId('location'),
                                position: LatLng(lat, lng),
                                icon: BitmapDescriptor.defaultMarker,
                              );
                              setState(() {
                                markers[MarkerId('location')] = marker;
                              });

                            },
                            onCameraIdle: () {
                              getMapLoc();
                            },
                            onCameraMove: (post) {
                              lat = post.target.latitude;
                              lng = post.target.longitude;

                              final marker = Marker(
                                markerId: MarkerId('location'),
                                position: LatLng(lat, lng),
                                icon: BitmapDescriptor.defaultMarker,
                              );
                              setState(() {
                                markers[MarkerId('location')] = marker;
                              });
                            },
                          ),
                        ),

                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: kHintColor, width: 1),
                          ),
                          child: DropdownButton<String>(
                            hint: Text(addressType),
                            isExpanded: true,
                            underline: Container(
                              height: 0.0,
                              color: scaffoldBgColor,
                            ),
                            items: addressTyp.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                addressType = value!;
                              });
                              print(addressType);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child:
                              TextFormField(
                                controller: houseController,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText:'house No',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide:
                                        BorderSide(color: Colors.black, width: 1),
                                      ),
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kHintColor,
                                      fontSize: 16),
                                ),
                              ),

                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child:
                              TextFormField(
                                controller: pincodeController,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText:'Pincode',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                                  ),
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kHintColor,
                                      fontSize: 16),
                                ),
                              ),

                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: kHintColor, width: 1),
                              ),
                              child: DropdownButton<CityList>(
                                hint: Text(
                                  selectCity,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                                isExpanded: true,
                                underline: Container(
                                  height: 0.0,
                                  color: scaffoldBgColor,
                                ),
                                items: cityListt.map((value) {
                                  return DropdownMenuItem<CityList>(
                                    value: value,
                                    child: Text(value.city_name,
                                        overflow: TextOverflow.clip),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectCity = value!.city_name;
                                    selectCityId = value.city_id;
                                    areaList.clear();
                                    selectArea = 'Select near by area';
                                    selectAreaId = '';
                                  });
                                  getAreaList(value!.city_id);
                                  print(value);
                                },
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              padding: EdgeInsets.symmetric(horizontal: 10),

                              child:

                              TextFormField(
                                controller: stateController,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText:'state',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:
                                    BorderSide(color: Colors.black, width: 1),
                                  ),
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kHintColor,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                          child:
                          TextFormField(
                            controller: streetController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:'Address Line 1',
                              contentPadding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1),
                              ),
                              hintStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: kHintColor,
                                  fontSize: 16),
                            ),
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
            ),
            Container(
              height: (MediaQuery.of(context).size.height - 77) * 0.1,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    if (addressType != null &&
                        addressType != 'Select address type' &&
                        houseController.text != null &&
                        houseController.text != '' &&
                        streetController.text != null &&
                        streetController.text != '' &&
                        pincodeController.text != null &&
                        pincodeController.text != '' &&
                        stateController.text != null &&
                        stateController.text != '') {
                      setState(() {
                        showDialogBox = true;
                      });
                      addAddres(
                          selectAreaId,
                          selectCityId,
                          houseController.text,
                          '${streetController.text}',
                          pincodeController.text,
                          stateController.text,
                          context);
                    } else {

                      Fluttertoast.showToast(
                          msg: "Enter all details carefully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: kMainColor),
                    child: Text(
                      'Save Address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
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
    );
  }

  void addAddres(dynamic area_id, dynamic city_id, house_no, street, pincode,
      state, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<Location> locations = await locationFromAddress(street);
    setState(() {
      lat = locations[0].latitude;
      lng = locations[0].longitude;
    });

    final marker = Marker(
      markerId: MarkerId('location'),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      markers[MarkerId('location')] = marker;
    });



    var url = addAddress;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'user_id': '${prefs.getInt('user_id')}',
      'user_name': '${prefs.getString('user_name')}',
      'user_number': '${prefs.getString('user_phone')}',
      'city_id': '$city_id',
      'houseno': '$house_no',
      'street': '$street',
      'state': '$state',
      'pin': '$pincode',
      'lat': '$lat',
      'lng': '$lng',
      'address_type': '${addressType}',
    }).then((value) {
      print('Response Body: - ${value.body}');

      if (value.statusCode == 200) {
        print('Response Body: - ${value.body}');
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          prefs.setString("area_id", "$area_id");
          prefs.setString("city_id", "$city_id");
          setState(() {
            showDialogBox = false;
          });
          setState(() {
            selectCity = 'Select city';
            selectCityId = '';
            areaList.clear();
            selectArea = 'Select near by area';
            addressType = 'Select address type';
            selectAreaId = '';
            houseController.clear();
            streetController.clear();
            pincodeController.clear();
            stateController.clear();
          });

          Navigator.pop(context);
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
      print(e);
    });
  }
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      message = prefs.getString("message")!;
    });
  }

  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }

  void _getCameraMoveLocation(LatLng data) async {
    Timer(Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      GeoData data1 = await Geocoder2.getDataFromCoordinates(
          latitude: lat,
          longitude: lng,
          googleMapApiKey: apiKey);
      setState(() {
        currentAddress = data1.address;
      });
    });
  }

}
