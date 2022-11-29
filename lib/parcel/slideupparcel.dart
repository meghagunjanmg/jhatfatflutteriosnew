import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/parcel/pharmacybean/parcelorderhistorybean.dart';

class SlideUpPanelParcel extends StatefulWidget {
  final TodayOrderParcel ongoingOrders;
  final dynamic currency;

  SlideUpPanelParcel(this.ongoingOrders, this.currency);

  @override
  _SlideUpPanelParcelState createState() => _SlideUpPanelParcelState();
}

class _SlideUpPanelParcelState extends State<SlideUpPanelParcel> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.20,
      initialChildSize: 0.20,
      maxChildSize: 1.0,
      builder: (context, controller) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(left: 4.0),
          color: kCardBackgroundColor,
          child: SingleChildScrollView(
            controller: controller,
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        Hero(
                          tag: 'Delivery Boy',
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10.0, top: 14.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 22.0,
                                backgroundImage:
                                    AssetImage('images/profile.png'),
                              ),
                              title: Text(
                                widget.ongoingOrders.deliveryBoyName != null
                                    ? '${widget.ongoingOrders.deliveryBoyName}'
                                    : 'Delivery boy not assigned yet',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              subtitle: Text(
                                'Delivery Partner',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        fontSize: 11.7,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xffc2c2c2)),
                              ),
                              trailing: FittedBox(
                                fit: BoxFit.fill,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon:
                                          Icon(Icons.phone, color: kMainColor),
                                      onPressed: () {
                                        if (widget.ongoingOrders
                                                    .deliveryBoyPhone !=
                                                null &&
                                            widget.ongoingOrders
                                                    .deliveryBoyPhone
                                                    .toString()
                                                    .length >
                                                5) {
                                          _launchURL(
                                              "tel://${widget.ongoingOrders.deliveryBoyPhone}");
                                        } else {
                                          Toast.show(
                                              'Delivery boy not assigned yet', duration: Toast.lengthShort, gravity:  Toast.bottom);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Hero(
                            tag: 'arrow',
                            child: Icon(
                              Icons.keyboard_arrow_up,
                              color: kMainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6.0),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Text('PAYMENT INFO',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: kDisabledColor,
                            fontSize: 13.3,
                            letterSpacing: 0.67)),
                    color: Colors.white,
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Sub Total',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text(
                            '${widget.currency} ${(double.parse('${widget.ongoingOrders.distance}') > 1) ? double.parse('${widget.ongoingOrders.charges}') * double.parse('${widget.ongoingOrders.distance}') : double.parse('${widget.ongoingOrders.charges}')}\n\n',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ]),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Delivery Charge',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text(
                            '${widget.currency} ${widget.ongoingOrders.charges}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ]),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Coupon Discount',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text(
                            '- ${widget.currency} 0.0',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ]),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Paid by wallet',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text(
                            '${widget.currency} ${widget.ongoingOrders.wallet}',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ]),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                    child: (widget.ongoingOrders.paymentMethod == "Card" ||
                            widget.ongoingOrders.paymentMethod == "Wallet")
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                Text(
                                  'Payment Status',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                Text(
                                  '${widget.ongoingOrders.paymentStatus}',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                                Text(
                                  'Cash on Delivery',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                Text(
                                  '${widget.currency} ${(double.parse('${widget.ongoingOrders.distance}') > 1) ? double.parse('${widget.ongoingOrders.charges}') * double.parse('${widget.ongoingOrders.distance}') : double.parse('${widget.ongoingOrders.charges}')}\n\n',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
