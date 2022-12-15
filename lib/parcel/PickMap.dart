import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/bottom_bar.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/bean/latlng.dart';

import '../baseurlp/baseurl.dart';

class PickMap extends StatelessWidget {
  final dynamic lat;
  final dynamic lng;

  PickMap(this.lat, this.lng);

  @override
  Widget build(BuildContext context) {
    return SetLocationss(lat, lng);
  }
}

class SetLocationss extends StatefulWidget {
  final dynamic lat;
  final dynamic lng;

  SetLocationss(this.lat, this.lng);

  @override
  SetLocationState createState() => SetLocationState(lat, lng);
}

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

class SetLocationState extends State<SetLocationss> {
  dynamic lat;
  dynamic lng;
  CameraPosition? kGooglePlex;

  SetLocationState(this.lat, this.lng) {
    kGooglePlex = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 12.151926,
    );
  }
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  bool isCard = false;
  Completer<GoogleMapController> _controller = Completer();

  var isVisible = false;
  bool button = false;

  var currentAddress = '';

  Future<void> _goToTheLake(lat, lng) async {
    final CameraPosition _kLake = CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      button = false;
    });

    getdata();

    /// _getLocation();
  }

  Future<void> getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    lat = double.parse(pref.getString("lat")!);
    lng = double.parse(pref.getString("lng")!);
    _goToTheLake(lat, lng);

  }


  @override
  void dispose() {
    super.dispose();
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        Timer(Duration(seconds: 5), () async {
          double lat = position.latitude;
          double lng = position.longitude;
          GeoData data = await Geocoder2.getDataFromCoordinates(
              latitude: lat,
              longitude: lng,
              googleMapApiKey: apiKey);
          setState(() {
            currentAddress = data.address;
            _goToTheLake(lat, lng);
          });
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show(
                'Location permission is required!', duration: Toast.lengthShort,
                gravity: Toast.bottom);
          }
        }).catchError((e) {
          Toast.show(
              'Location permission is required!', duration: Toast.lengthShort,
              gravity: Toast.bottom);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show(
            'Location permission is required!', duration: Toast.lengthShort,
            gravity: Toast.bottom);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show(
            'Location permission is required!', duration: Toast.lengthShort,
            gravity: Toast.bottom);
      });
    }
  }

  void _getCameraMoveLocation(LatLng data) async {
    Timer(Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      GeoData data1 = await Geocoder2.getDataFromCoordinates(
          latitude: lat,
          longitude: lng,
          googleMapApiKey: apiKey);
      setState(() {
        currentAddress = data1.address;
        button = true;
      });
    });
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
    setState(() {
      button = false;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            'Set delivery location',
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
                    _getLocation();
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
                  padding: EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                      color: scaffoldBgColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: Row(
                    children: [
                      Icon(Icons.search,size: 25,),
                      SizedBox(width: 20,),
                      Text(
                          'Enter Location'
                      ),
                    ],
                  ),
                ),
              ),
              preferredSize:
              Size(MediaQuery.of(context).size.width * 0.85, 52)),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: kGooglePlex!,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
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
                // Align(
                //     alignment: Alignment.center,
                //     child: Padding(
                //       padding: EdgeInsets.only(bottom: 36.0),
                //       child: Image.asset(
                //         'images/map_pin.png',
                //         height: 36,
                //       ),
                //     ))
              ],
            ),
          ),
          Container(
            color: kCardBackgroundColor,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'images/map_pin.png',
                  scale: 3,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: Text(
                    '${currentAddress}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          (button)?
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                primary: kMainColor,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400)),

            onPressed: () {
              CheckLocation(lat,lng);

            },
            child: Text(
              'Continue',
              style:
              TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
            ),
          )
              :
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                primary: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),

            onPressed: () {
            },
            child: Text(
              'Continue',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            ),
          )

        ],
      ),
    );
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pickupLocation",'${currentAddress}');
    prefs.setString("plt",'${lat}');
    prefs.setString("pln",'${lng}');
    print('setdata');
    print('${lat}');
    print('${lng}');

  }


  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }

  void CheckLocation(lat, lng) {
    var url = parcel_check_location;
    Uri myUri = Uri.parse(url);
    var client = http.Client();
    client.post(myUri, body: {'lat': lat.toString(),'lng':lng.toString()})
        .then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == 1) {
          setData();
          Navigator.pop(context);
        }
        else{
          dailog(jsonData['message']);
        }
      }}).catchError((e) {
      print(e);
      });
  }
  Future<bool> dailog(message) async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Notice'),
        content: new Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('OK'),
          ),
        ],
      ),
    )) ?? false;
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);
    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
