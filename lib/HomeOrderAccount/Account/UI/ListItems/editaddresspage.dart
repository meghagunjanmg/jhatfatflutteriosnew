import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Components/entry_field.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/address.dart';

import '../../../../Components/custom_appbar.dart';
import '../../../../Themes/constantfile.dart';

class EditAddresspage extends StatefulWidget {
  final dynamic lat;
  final dynamic lng;
  final dynamic pincode;
  final dynamic houseno;
  final dynamic address;
  final dynamic state;
  final dynamic address_id;
  final dynamic vendorid;
  final dynamic area_id;
  final dynamic city_id;
  final dynamic type;

  EditAddresspage(this.lat,this.lng,this.pincode, this.houseno, this.address, this.state,
      this.address_id, this.vendorid, this.city_id, this.area_id, this.type);

  @override
  State<StatefulWidget> createState() {
    return EditAddresspageState(lat,lng,pincode, houseno, address, state, type);
  }
}

class EditAddresspageState extends State<EditAddresspage> {
  var pincodeController = TextEditingController();
  var houseController = TextEditingController();
  var streetController = TextEditingController();
  var street1Controller = TextEditingController();
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

  EditAddresspageState(lat,lng, pincode, houseno, address, state, type) {
    pincodeController.text = '${pincode}';
    houseController.text = '${houseno}';
    stateController.text = state;
    address = address.replaceAll('${pincode},', '');
    address = address.replaceAll('${pincode}', '');
    address = address.replaceAll('${houseno},', '');
    address = address.replaceAll('${state},', '');
    streetController.text = address;
    addressType = type;
    this.lat = double.parse(lat);
    this.lng = double.parse(lng);
  }
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      message = prefs.getString("message")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    getCityList();
  }
  Future<void> _goToTheLake(lat, lng) async {
    final CameraPosition _kLake = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

  }

  void getPlaces(context) async {
    // PlacesAutocomplete.show(
    //   context: context,
    //   apiKey: apiKey,
    //   mode: Mode.fullscreen,
    //   onError: (response) {
    //     print(response.predictions);
    //   },
    //   language: "en",
    //     components: [new Component(Component.country, "in")]
    // ).then((value) {
    //   //displayPrediction(value);
    // }).catchError((e) {
    //   print(e);
    // });


    final Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      onError: onError,
      mode: Mode.overlay, // or Mode.fullscreen
      language: 'en',
      components: [Component(Component.country, 'in')],
    );

    if (p != null) displayPrediction(p);
  }
  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Unknown error'),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: apiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail =
    await _places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    _getCameraMoveLocation(LatLng(lat, lng));
    print("${p.description} - $lat/$lng");

    final marker = Marker(
      markerId: MarkerId('location'),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      markers[MarkerId('location')] = marker;
      _goToTheLake(lat, lng);
    });

  }
  // Future<Null> displayPrediction(Prediction p) async {
  //   if (p != null) {
  //     PlacesDetailsResponse detail =
  //         await _places.getDetailsByPlaceId(p.placeId!);
  //     final lat = detail.result.geometry!.location.lat;
  //     final lng = detail.result.geometry!.location.lng;
  //     _getCameraMoveLocation(LatLng(lat, lng));
  //   }
  // }
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
          if (data.address.isNotEmpty) {
            streetController.text = data.address;
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            'Add Address',
            style: TextStyle(fontSize: 16.7, color: black_color),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: kMainColor,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    _getLocation(context);
                  },
                ))
          ],
          bottom: PreferredSize(
              child: GestureDetector(
                onTap: (){
                  getPlaces(context);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 52,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: scaffoldBgColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: Row(
                    children: [
                      Icon(Icons.search,size: 25,),
                      SizedBox(width: 20),
                      Text(
                          'Search Location'
                      ),
                    ],
                  ),
                ),
              ),
              preferredSize:
              Size(MediaQuery.of(context).size.width * 0.85, 52)),
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

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     Container(
                        //       width: MediaQuery.of(context).size.width * 0.45,
                        //       child:
                        //       TextFormField(
                        //         controller: houseController,
                        //         maxLines: 1,
                        //         decoration: InputDecoration(
                        //           hintText:'house No',
                        //               border: OutlineInputBorder(
                        //                 borderRadius: BorderRadius.circular(10.0),
                        //                 borderSide:
                        //                 BorderSide(color: Colors.black, width: 1),
                        //               ),
                        //           hintStyle: TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               color: kHintColor,
                        //               fontSize: 16),
                        //         ),
                        //       ),
                        //
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width * 0.45,
                        //       child:
                        //       TextFormField(
                        //         controller: pincodeController,
                        //         maxLines: 1,
                        //         decoration: InputDecoration(
                        //           hintText:'Pincode',
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10.0),
                        //             borderSide:
                        //             BorderSide(color: Colors.black, width: 1),
                        //           ),
                        //           hintStyle: TextStyle(
                        //               fontWeight: FontWeight.w600,
                        //               color: kHintColor,
                        //               fontSize: 16),
                        //         ),
                        //       ),
                        //
                        //     ),
                        //   ],
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.95,
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Container(
                            //   width: MediaQuery.of(context).size.width * 0.45,
                            //   padding: EdgeInsets.symmetric(horizontal: 10),
                            //
                            //   child:
                            //
                            //   TextFormField(
                            //     controller: stateController,
                            //     maxLines: 1,
                            //     decoration: InputDecoration(
                            //       hintText:'state',
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10.0),
                            //         borderSide:
                            //         BorderSide(color: Colors.black, width: 1),
                            //       ),
                            //       hintStyle: TextStyle(
                            //           fontWeight: FontWeight.w600,
                            //           color: kHintColor,
                            //           fontSize: 16),
                            //     ),
                            //   ),
                            // ),
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

  void getCityList() async {
    var url = cityList;
    Uri myUri = Uri.parse(url);

    http.post(myUri, body: {
      'vendor_id': '54',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CityList> tagObjs =
          tagObjsJson.map((tagJson) => CityList.fromJson(tagJson)).toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              cityListt.clear();
              cityListt = tagObjs;
              areaList.clear();
              selectAreaId = '';
              selectArea = 'Select near by area';
            });
            List<CityList> tagObjs1 = tagObjs
                .where((element) =>
            element.city_id.toString() == '${widget.city_id}')
                .toList();
            if (tagObjs1 != null && tagObjs1.length > 0) {
              setState(() {
                selectCity = tagObjs1[0].city_name;
                selectCityId = tagObjs1[0].city_id;
                streetController.text =
                    streetController.text.replaceAll('${selectCity},', '');
                streetController.text =
                    streetController.text.replaceAll('${selectCity}', '');
              });
              if (selectCityId != null &&
                  selectCityId != '' &&
                  selectCityId != null) {
                getAreaList1(selectCityId);
              }
            }
          } else {
            setState(() {
              cityListt.clear();
              areaList.clear();
              selectCity = 'Select city';
              selectCityId = '';
              selectAreaId = '';
              selectArea = 'Select near by area';
            });
          }
        }
      }
    });
  }

  void getAreaList1(dynamic city_id) async {
    var url = areaLists;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${widget.vendorid}',
      'city_id': '$city_id',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<AreaList> tagObjs =
          tagObjsJson.map((tagJson) => AreaList.fromJson(tagJson)).toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              areaList.clear();
              areaList = tagObjs;
            });
            List<AreaList> tagObjs1 = tagObjs
                .where((element) =>
            element.area_id.toString() == '${widget.area_id}')
                .toList();
            if (tagObjs1 != null && tagObjs1.length > 0) {
              setState(() {
                selectAreaId = tagObjs1[0].area_id;
                selectArea = tagObjs1[0].area_name;
                streetController.text =
                    streetController.text.replaceAll(',${selectArea},', '');
                streetController.text =
                    streetController.text.replaceAll('${selectArea},', '');
                streetController.text =
                    streetController.text.replaceAll('${selectArea}', '');
              });
            }
          } else {
            setState(() {
              areaList.clear();
              selectAreaId = '';
              selectArea = 'Select near by area';
            });
          }
        }
      }
    });
  }

  void getAreaList(dynamic city_id) async {
    var url = areaLists;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'vendor_id': '${widget.vendorid}',
      'city_id': '$city_id',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<AreaList> tagObjs =
          tagObjsJson.map((tagJson) => AreaList.fromJson(tagJson)).toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              areaList.clear();
              areaList = tagObjs;
            });
          } else {
            setState(() {
              areaList.clear();
              selectAreaId = '';
              selectArea = 'Select near by area';
            });
          }
        }
      }
    });
  }


  void addAddres(dynamic area_id, dynamic city_id, house_no, street, pincode,
      state, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = editAddress;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      'address_id': '${widget.address_id}',
      'user_id': '${prefs.getInt('user_id')}',
      'user_name': '${prefs.getString('user_name')}',
      'user_number': '${prefs.getString('user_phone')}',
      'area_id': '$area_id',
      'city_id': '$city_id',
      'houseno': '$house_no',
      'street': '$street',
      'state': '$state',
      'pin': '$pincode',
      'lat': '$lat',
      'lng': '$lng',
      'address_type': '${addressType}',
    }).then((value) {
      if (value.statusCode == 200) {
        print('Response Body: - ${value.body}');
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          prefs.setString("area_id", "$area_id");
          prefs.setString("city_id", "$city_id");
          setState(() {
            showDialogBox = false;
          });
          Navigator.pop(context);

        } else {
          print(jsonData['message']);
          setState(() {
            showDialogBox = false;
          });
        }
      } else {
        print(value.body.toString());

        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e.toString());

      setState(() {
        showDialogBox = false;
      });
      print(e);
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
        if (data1.address.isNotEmpty) {
          streetController.text = data1.address;
        }
        if (data1.postalCode.isNotEmpty) {
          pincodeController.text = data1.postalCode;
        }
        if (data1.state.isNotEmpty) {
          stateController.text = data1.state;
        }
      });
    });
  }

}
