import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/constantfile.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/parcel/parcelcancel.dart';
import 'package:jhatfat/parcel/pharmacybean/parcelorderhistorybean.dart';
import 'package:jhatfat/parcel/slideupparcel.dart';
import 'package:location/location.dart' as loc;

class OrderMapParcelPage extends StatelessWidget {
  late  String? instruction;
  late  String? pageTitle;
  late  TodayOrderParcel? ongoingOrders;
  late  dynamic currency;
  final dynamic user_id;


  OrderMapParcelPage(
      { this.instruction, this.pageTitle, this.ongoingOrders, this.currency,this.user_id});

  @override
  Widget build(BuildContext context) {
    return OrderMapParcel
      (pageTitle!, ongoingOrders!, currency,user_id);
  }
}

class OrderMapParcel extends StatefulWidget {
   late String? pageTitle;
  late TodayOrderParcel? ongoingOrders;
   late dynamic currency;
   final dynamic user_id;


   OrderMapParcel
       (this.pageTitle, this.ongoingOrders, this.currency,this.user_id);


  @override
  _OrderMapParcelState createState() => _OrderMapParcelState();
}

class _OrderMapParcelState extends State<OrderMapParcel> {
  bool showAction = false;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  double _destLatitude = 30.3165, _destLongitude = 78.0322;
  double _originLatitude = 0.0, _originLongitude = 0.0;
  final loc.Location location = loc.Location();
  GoogleMapController? _controller;
  List<LatLng> polylineCoordinates = [];
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  bool _added = false;
 late final dynamic user_id;



  @override
  void initState() {
    super.initState();

    _originLatitude = double.parse(double.parse((widget.ongoingOrders!.sourceLat.toString())).toStringAsFixed(4));
    _originLongitude = double.parse(double.parse((widget.ongoingOrders!.sourceLng.toString())).toStringAsFixed(4));

    _destLatitude = double.parse(double.parse((widget.ongoingOrders!.destinationLat.toString())).toStringAsFixed(4));
    _destLongitude = double.parse(double.parse((widget.ongoingOrders!.destinationLng.toString())).toStringAsFixed(4));

    getDirections();

    _listenLocation();

  }
  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc(
          user_id.toString()).set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': 'john'
      }, SetOptions(merge: true));
      _originLatitude = currentlocation.latitude!;
      _originLongitude = currentlocation.longitude!;
    });
  }

  _getLocation() async {
    try {
      await FirebaseFirestore.instance.collection('location').doc(user_id.toString()).set({
        'latitude': double.parse(double.parse((widget.ongoingOrders!.sourceLat.toString())).toStringAsFixed(4)),
        'longitude': double.parse(double.parse((widget.ongoingOrders!.sourceLng.toString())).toStringAsFixed(4)),
        'name': 'john'
      }, SetOptions(merge: true));

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(52.0),
          child: AppBar(
            titleSpacing: 0.0,
            title: Text(
              'Order #${widget.ongoingOrders!.cartId}',
              style: TextStyle(
                  fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
            ),
            actions: [
              Visibility(
                visible: (widget.ongoingOrders!.orderStatus == 'Pending' ||
                    widget.ongoingOrders!.orderStatus == 'Confirmed')
                    ? true
                    : false,
                child: Padding(
                  padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child:
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return CancelParcel(widget.ongoingOrders!.cartId);
                      })).then((value) {
                        if (value) {
                          setState(() {
                            widget.ongoingOrders!.orderStatus = "Cancelled";
                          });
                        }
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          color: kMainColor, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('location').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            mymap();

            if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty){
                  if (_added) {
                    _originLatitude = snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.user_id)['latitude'];
                    _originLongitude = snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.user_id)['longitude'];
                  }
                  return
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              GoogleMap(
                                mapType: MapType.normal,
                                markers: Set<Marker>.of(markers.values),
                                polylines: Set<Polyline>.of(polylines.values),
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(_originLatitude,
                                        _originLongitude),
                                    zoom: 14),
                                onMapCreated: (GoogleMapController controller) async {
                                  setState(() {
                                    _controller = controller;
                                    _added = true;
                                  });
                                  getDirections();
                                },
                              ),


                              Positioned(
                                top: 0.0,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Container(
                                  color: white_color,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: PreferredSize(
                                    preferredSize: Size.fromHeight(0.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.3),
                                              child: Image.asset(
                                                'images/maincategory/vegetables_fruitsact.png',
                                                height: 42.3,
                                                width: 33.7,
                                              ),
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                title: Text(
                                                  '${widget.ongoingOrders!
                                                      .vendorName}',
                                                  style: orderMapAppBarTextStyle
                                                      .copyWith(
                                                      letterSpacing: 0.07),
                                                ),
                                                subtitle: Text(
                                                  (widget.ongoingOrders!
                                                      .pickupDate !=
                                                      "null" &&
                                                      widget.ongoingOrders!
                                                          .pickupTime !=
                                                          "null" &&
                                                      widget.ongoingOrders!
                                                          .pickupDate !=
                                                          null &&
                                                      widget.ongoingOrders!
                                                          .pickupTime !=
                                                          null)
                                                      ? '${widget.ongoingOrders!
                                                      .pickupDate} | ${widget
                                                      .ongoingOrders!.pickupTime}'
                                                      : '',
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .copyWith(
                                                      fontSize: 11.7,
                                                      letterSpacing: 0.06,
                                                      color: Color(0xffc1c1c1)),
                                                ),
                                                trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    Text(
                                                      '${widget.ongoingOrders!
                                                          .orderStatus}',
                                                      style: orderMapAppBarTextStyle
                                                          .copyWith(
                                                          color: kMainColor),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      '1 items | ${widget
                                                          .currency} ${(double
                                                          .parse(
                                                          '${widget.ongoingOrders!
                                                              .distance}') > 1)
                                                          ? double.parse(
                                                          '${widget.ongoingOrders!
                                                              .charges}') *
                                                          double.parse('${widget
                                                              .ongoingOrders!
                                                              .distance}')
                                                          : double.parse(
                                                          '${widget.ongoingOrders!
                                                              .charges}')}\n\n',
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .headline6!
                                                          .copyWith(
                                                          fontSize: 11.7,
                                                          letterSpacing: 0.06,
                                                          color: Color(0xffc1c1c1)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: kCardBackgroundColor,
                                          thickness: 1.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 36.0,
                                                  bottom: 6.0,
                                                  top: 6.0,
                                                  right: 12.0),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'images/custom/ic_pickup_pointact.png'),
                                                size: 13.3,
                                                color: kMainColor,
                                              ),
                                            ),
//                              Text(
//                                '${widget.ongoingOrders.vendor_name}\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
                                            Expanded(
                                              child: Text(
                                                '${widget.ongoingOrders!
                                                    .vendorName}\t',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    fontSize: 10.0,
                                                    letterSpacing: 0.05),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 36.0,
                                                  bottom: 12.0,
                                                  top: 12.0,
                                                  right: 12.0),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'images/custom/ic_droppointact.png'),
                                                size: 13.3,
                                                color: kMainColor,
                                              ),
                                            ),
//                              Expanded(
//                                child: Text(
//                                  '${widget.ongoingOrders.address}\t',
//                                  style: orderMapAppBarTextStyle.copyWith(
//                                      fontSize: 10.0, letterSpacing: 0.05),
//                                ),
//                              ),
                                            Expanded(
                                              child: Text(
                                                '${widget.ongoingOrders!
                                                    .vendorLoc}\t',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    fontSize: 10.0,
                                                    letterSpacing: 0.05),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SlideUpPanelParcel(
                                  widget.ongoingOrders!, widget.currency),
                            ],
                          ),
                        ),
                        Container(
                          height: 60.0,
                          color: kCardBackgroundColor,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '1 items | ${widget.currency} ${(double.parse(
                                    '${widget.ongoingOrders!.distance}') > 1)
                                    ? double.parse('${widget.ongoingOrders!
                                    .charges}') * double.parse('${widget
                                    .ongoingOrders!.distance}')
                                    : double.parse('${widget.ongoingOrders!
                                    .charges}')}\n\n',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                } else {
                  if (_added) {
                    _originLatitude = double.parse(double.parse((widget.ongoingOrders!.sourceLat.toString())).toStringAsFixed(4));
                    _originLongitude = double.parse(double.parse((widget.ongoingOrders!.sourceLng.toString())).toStringAsFixed(4));

                    _destLatitude = double.parse(double.parse((widget.ongoingOrders!.destinationLat.toString())).toStringAsFixed(4));
                    _destLongitude = double.parse(double.parse((widget.ongoingOrders!.destinationLng.toString())).toStringAsFixed(4));

                    getDirections();


                  }

                  return
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              GoogleMap(
                                mapType: MapType.normal,
                                markers: Set<Marker>.of(markers.values),
                                polylines: Set<Polyline>.of(polylines.values),
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(_originLatitude,
                                        _originLongitude),
                                    zoom: 14),
                                onMapCreated: (GoogleMapController controller) async {
                                  setState(() {
                                    _controller = controller;
                                    _added = true;
                                  });
                                  getDirections();
                                },
                              ),


                              Positioned(
                                top: 0.0,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Container(
                                  color: white_color,
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: PreferredSize(
                                    preferredSize: Size.fromHeight(0.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.3),
                                              child: Image.asset(
                                                'images/maincategory/vegetables_fruitsact.png',
                                                height: 42.3,
                                                width: 33.7,
                                              ),
                                            ),
                                            Expanded(
                                              child: ListTile(
                                                title: Text(
                                                  '${widget.ongoingOrders!
                                                      .vendorName}',
                                                  style: orderMapAppBarTextStyle
                                                      .copyWith(
                                                      letterSpacing: 0.07),
                                                ),
                                                subtitle: Text(
                                                  (widget.ongoingOrders!
                                                      .pickupDate !=
                                                      "null" &&
                                                      widget.ongoingOrders!
                                                          .pickupTime !=
                                                          "null" &&
                                                      widget.ongoingOrders!
                                                          .pickupDate !=
                                                          null &&
                                                      widget.ongoingOrders!
                                                          .pickupTime !=
                                                          null)
                                                      ? '${widget.ongoingOrders!
                                                      .pickupDate} | ${widget
                                                      .ongoingOrders!.pickupTime}'
                                                      : '',
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .headline6!
                                                      .copyWith(
                                                      fontSize: 11.7,
                                                      letterSpacing: 0.06,
                                                      color: Color(0xffc1c1c1)),
                                                ),
                                                trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    Text(
                                                      '${widget.ongoingOrders!
                                                          .orderStatus}',
                                                      style: orderMapAppBarTextStyle
                                                          .copyWith(
                                                          color: kMainColor),
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    Text(
                                                      '1 items | ${widget
                                                          .currency} ${(double
                                                          .parse(
                                                          '${widget.ongoingOrders!
                                                              .distance}') > 1)
                                                          ? double.parse(
                                                          '${widget.ongoingOrders!
                                                              .charges}') *
                                                          double.parse('${widget
                                                              .ongoingOrders!
                                                              .distance}')
                                                          : double.parse(
                                                          '${widget.ongoingOrders!
                                                              .charges}')}\n\n',
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .headline6!
                                                          .copyWith(
                                                          fontSize: 11.7,
                                                          letterSpacing: 0.06,
                                                          color: Color(0xffc1c1c1)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: kCardBackgroundColor,
                                          thickness: 1.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 36.0,
                                                  bottom: 6.0,
                                                  top: 6.0,
                                                  right: 12.0),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'images/custom/ic_pickup_pointact.png'),
                                                size: 13.3,
                                                color: kMainColor,
                                              ),
                                            ),
//                              Text(
//                                '${widget.ongoingOrders.vendor_name}\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
                                            Expanded(
                                              child: Text(
                                                '${widget.ongoingOrders!
                                                    .vendorName}\t',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    fontSize: 10.0,
                                                    letterSpacing: 0.05),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 36.0,
                                                  bottom: 12.0,
                                                  top: 12.0,
                                                  right: 12.0),
                                              child: ImageIcon(
                                                AssetImage(
                                                    'images/custom/ic_droppointact.png'),
                                                size: 13.3,
                                                color: kMainColor,
                                              ),
                                            ),
//                              Expanded(
//                                child: Text(
//                                  '${widget.ongoingOrders.address}\t',
//                                  style: orderMapAppBarTextStyle.copyWith(
//                                      fontSize: 10.0, letterSpacing: 0.05),
//                                ),
//                              ),
                                            Expanded(
                                              child: Text(
                                                '${widget.ongoingOrders!
                                                    .vendorLoc}\t',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    fontSize: 10.0,
                                                    letterSpacing: 0.05),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SlideUpPanelParcel(
                                  widget.ongoingOrders!, widget.currency),
                            ],
                          ),
                        ),
                        Container(
                          height: 60.0,
                          color: kCardBackgroundColor,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '1 items | ${widget.currency} ${(double.parse(
                                    '${widget.ongoingOrders!.distance}') > 1)
                                    ? double.parse('${widget.ongoingOrders!
                                    .charges}') * double.parse('${widget
                                    .ongoingOrders!.distance}')
                                    : double.parse('${widget.ongoingOrders!
                                    .charges}')}\n\n',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                }
              } else {
                if (_added) {
                  _originLatitude = double.parse(double.parse((widget.ongoingOrders!.sourceLat.toString())).toStringAsFixed(4));
                  _originLongitude = double.parse(double.parse((widget.ongoingOrders!.sourceLng.toString())).toStringAsFixed(4));

                  _destLatitude = double.parse(double.parse((widget.ongoingOrders!.destinationLat.toString())).toStringAsFixed(4));
                  _destLongitude = double.parse(double.parse((widget.ongoingOrders!.destinationLng.toString())).toStringAsFixed(4));

                  getDirections();


                }

                return
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            GoogleMap(
                              mapType: MapType.normal,
                              markers: Set<Marker>.of(markers.values),
                              polylines: Set<Polyline>.of(polylines.values),
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(_originLatitude,
                                      _originLongitude),
                                  zoom: 14),
                              onMapCreated: (GoogleMapController controller) async {
                                setState(() {
                                  _controller = controller;
                                  _added = true;
                                });
                                getDirections();
                              },
                            ),


                            Positioned(
                              top: 0.0,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              child: Container(
                                color: white_color,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: PreferredSize(
                                  preferredSize: Size.fromHeight(0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.3),
                                            child: Image.asset(
                                              'images/maincategory/vegetables_fruitsact.png',
                                              height: 42.3,
                                              width: 33.7,
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                '${widget.ongoingOrders!
                                                    .vendorName}',
                                                style: orderMapAppBarTextStyle
                                                    .copyWith(
                                                    letterSpacing: 0.07),
                                              ),
                                              subtitle: Text(
                                                (widget.ongoingOrders!
                                                    .pickupDate !=
                                                    "null" &&
                                                    widget.ongoingOrders!
                                                        .pickupTime !=
                                                        "null" &&
                                                    widget.ongoingOrders!
                                                        .pickupDate !=
                                                        null &&
                                                    widget.ongoingOrders!
                                                        .pickupTime !=
                                                        null)
                                                    ? '${widget.ongoingOrders!
                                                    .pickupDate} | ${widget
                                                    .ongoingOrders!.pickupTime}'
                                                    : '',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                    fontSize: 11.7,
                                                    letterSpacing: 0.06,
                                                    color: Color(0xffc1c1c1)),
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: <Widget>[
                                                  Text(
                                                    '${widget.ongoingOrders!
                                                        .orderStatus}',
                                                    style: orderMapAppBarTextStyle
                                                        .copyWith(
                                                        color: kMainColor),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                    '1 items | ${widget
                                                        .currency} ${(double
                                                        .parse(
                                                        '${widget.ongoingOrders!
                                                            .distance}') > 1)
                                                        ? double.parse(
                                                        '${widget.ongoingOrders!
                                                            .charges}') *
                                                        double.parse('${widget
                                                            .ongoingOrders!
                                                            .distance}')
                                                        : double.parse(
                                                        '${widget.ongoingOrders!
                                                            .charges}')}\n\n',
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                        fontSize: 11.7,
                                                        letterSpacing: 0.06,
                                                        color: Color(0xffc1c1c1)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Divider(
                                        color: kCardBackgroundColor,
                                        thickness: 1.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 36.0,
                                                bottom: 6.0,
                                                top: 6.0,
                                                right: 12.0),
                                            child: ImageIcon(
                                              AssetImage(
                                                  'images/custom/ic_pickup_pointact.png'),
                                              size: 13.3,
                                              color: kMainColor,
                                            ),
                                          ),
//                              Text(
//                                '${widget.ongoingOrders.vendor_name}\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
                                          Expanded(
                                            child: Text(
                                              '${widget.ongoingOrders!
                                                  .vendorName}\t',
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.05),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 36.0,
                                                bottom: 12.0,
                                                top: 12.0,
                                                right: 12.0),
                                            child: ImageIcon(
                                              AssetImage(
                                                  'images/custom/ic_droppointact.png'),
                                              size: 13.3,
                                              color: kMainColor,
                                            ),
                                          ),
//                              Expanded(
//                                child: Text(
//                                  '${widget.ongoingOrders.address}\t',
//                                  style: orderMapAppBarTextStyle.copyWith(
//                                      fontSize: 10.0, letterSpacing: 0.05),
//                                ),
//                              ),
                                          Expanded(
                                            child: Text(
                                              '${widget.ongoingOrders!
                                                  .vendorLoc}\t',
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                  fontSize: 10.0,
                                                  letterSpacing: 0.05),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SlideUpPanelParcel(
                                widget.ongoingOrders!, widget.currency),
                          ],
                        ),
                      ),
                      Container(
                        height: 60.0,
                        color: kCardBackgroundColor,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '1 items | ${widget.currency} ${(double.parse(
                                  '${widget.ongoingOrders!.distance}') > 1)
                                  ? double.parse('${widget.ongoingOrders!
                                  .charges}') * double.parse('${widget
                                  .ongoingOrders!.distance}')
                                  : double.parse('${widget.ongoingOrders!
                                  .charges}')}\n\n',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
              }

            },

            ));
    }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  void mymap() async {

    await _controller!
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
          _originLatitude,
         _originLongitude,
        ),
        zoom: 14)));

    _addMarker(LatLng(_originLatitude, _originLongitude), "source",await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(90,90)), 'assets/delivery.png'));
    _addMarker(LatLng(_destLatitude, _destLongitude), "dest", BitmapDescriptor.defaultMarkerWithHue(90));
  }


  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
     apiKey,
      PointLatLng(_originLatitude, _originLongitude),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: kMainColor,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  }
