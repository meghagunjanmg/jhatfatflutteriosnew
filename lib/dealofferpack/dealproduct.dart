import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Components/custom_appbar.dart';
import 'package:jhatfat/Components/search_bar.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/dealprodcutbean.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';

class DealProducts extends StatefulWidget {
  final dynamic pageTitle;
  final dynamic category_name;
  final dynamic category_id;
  final dynamic distance;
  final dynamic vendor_id;

  DealProducts(this.pageTitle, this.category_name, this.category_id,
      this.distance, this.vendor_id);

  @override
  State<StatefulWidget> createState() {
    return DealProductState();
  }
}

class DealProductState extends State<DealProducts>
    with SingleTickerProviderStateMixin {
  // AnimationController _animationController;
 // Animation<Color> animation;
  bool isCartCount = false;
  var cartCount = 0;
  List<DealProductList> productList = [];
  List<DealProductList> productVarientListSearch = [];
  dynamic currency = '';

  bool isDeal = true;

  @override
  void initState() {
    // _animationController =
    //     AnimationController(duration: Duration(microseconds: 500), vsync: this);
    // final CurvedAnimation curve = CurvedAnimation(parent: _animationController, curve: Curves.linear);
    //
    // //animation =  ColorTween(begin: Colors.white, end: kMainColor).animate(curve);
    //
    // animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _animationController.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     _animationController.forward();
    //   }
    // });
    // _animationController.forward();
    getCartCount();
    getDealProdcuts();
    super.initState();
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCount().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });
  }

  void getDealProdcuts() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
    var dealUrl = dealproductUrl;
    var client = http.Client();
    Uri myUri = Uri.parse(dealUrl);

    client.post(myUri, body: {'vendor_id': '${widget.vendor_id}'}).then(
        (value) {
      print(value.body);
      if (value.statusCode == 200 && value.body != null) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsonList = jsonData['data'] as List;

          List<DealProductList> tagObjs = jsonList
              .map((tagJson) => DealProductList.fromJson(tagJson))
              .toList();
          setState(() {
            productList.clear();
            productVarientListSearch.clear();
            productList = tagObjs;
            productVarientListSearch = List.from(productList);
          });
        } else {
          setState(() {
            isDeal = false;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    //_animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.pageTitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: kMainTextColor)),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      color: kIconColor,
                      size: 10,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                        '${double.parse('${widget.distance}').toStringAsFixed(2)} km ',
                        style: Theme.of(context).textTheme.overline),
                    Text('|', style: Theme.of(context).textTheme.overline),
                    Text(widget.category_name,
                        style: Theme.of(context).textTheme.overline),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Stack(
                children: [
                  IconButton(
                      icon: ImageIcon(
                        AssetImage('images/icons/ic_cart blk.png'),
                      ),
                      onPressed: () {
                          Navigator.pushNamed(context, PageRoutes.viewCart)
                              .then((value) {
//                            setList(productVarientList);
                            getCartCount();
                          });

                      }),
                  Positioned(
                      right: 5,
                      top: 2,
                      child: Visibility(
                        visible: isCartCount,
                        child: CircleAvatar(
                          minRadius: 4,
                          maxRadius: 8,
                          backgroundColor: kMainColor,
                          child: Text(
                            '$cartCount',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 7,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Column(
              children: <Widget>[
                CustomSearchBar(
                  hint: 'Search item...',
                  onChanged: (value) {
                    setState(() {
                      productList = productVarientListSearch
                          .where((element) => element.product_name
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  }, onTap: (){} , color: Colors.white, boxShadow: BoxShadow(color: kCardBackgroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
      body: (productList != null && productList.length > 0)
          ? ListView.separated(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                  },
                  behavior: HitTestBehavior.deferToChild,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          top: 5.0,
                          right: 30.0,
                          child: Row(
                            children: [
                              // AnimatedBuilder(
                              //   animation: animation,
                              //   builder: (context, child) {
                              //     return Icon(
                              //       Icons.timer,
                              //       size: 20,
                              //     );
                              //   },
                              // ),
                              SizedBox(
                                width: 8.0,
                              ),
                              TimerView(
                                dateTime: DateTime.now().add(Duration(
                                    hours: DateFormat('HH:mm:ss')
                                        .parse(productList[index].hoursmin)
                                        .hour)),
                              ),
                            ],
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.0, top: 30.0, right: 14.0),
                            child:
                                (productList != null && productList.length > 0)
                                    ? Image.network(
                                        imageBaseUrl +
                                            productList[index].varient_image,
//                                scale: 2.5,
                                        height: 93.3,
                                        width: 93.3,
                                      )
                                    : Image(
                                        image: AssetImage(
                                            'images/logos/logo_user.png'),
                                        height: 93.3,
                                        width: 93.3,
                                      ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(productList[index].product_name,
                                      style: bottomNavigationTextStyle.copyWith(
                                          fontSize: 15)),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Text('$currency ${productList[index].price}',
                                    style: Theme.of(context).textTheme.caption),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 120,
                        bottom: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: kCardBackgroundColor,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                '${productList[index].quantity} ${productList[index].unit}',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          height: 30,
                          right: 20.0,
                          bottom: 5,
                          child: productList[index].add_qnty == 0
                              ? Container(
                                  height: 30.0,
                                  child: TextButton(
                                    child: Text(
                                      'Add',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: kMainColor,
                                              fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (productList[index].stock >
                                            productList[index].add_qnty) {
                                          productList[index].add_qnty++;
                                          addOrMinusProduct(
                                              productList[index].product_name,
                                              productList[index].unit,
                                              double.parse(
                                                  '${productList[index].price}'),
                                              int.parse(
                                                  '${productList[index].quantity}'),
                                              productList[index].add_qnty,
                                              productList[index].varient_image,
                                              productList[index].varient_id);
                                        } else {
                                        }
                                      });
                                    },
                                  ),
                                )
                              : Container(
                                  height: 30.0,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 11.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: kMainColor),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            productList[index].add_qnty--;
                                          });
                                          addOrMinusProduct(
                                              productList[index].product_name,
                                              productList[index].unit,
                                              double.parse(
                                                  '${productList[index].price}'),
                                              int.parse(
                                                  '${productList[index].quantity}'),
                                              productList[index].add_qnty,
                                              productList[index].varient_image,
                                              productList[index].varient_id);
                                        },
                                        child: Icon(
                                          Icons.remove,
                                          color: kMainColor,
                                          size: 20.0,
                                          //size: 23.3,
                                        ),
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                          productList[index]
                                              .add_qnty
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption),
                                      SizedBox(width: 8.0),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (productList[index].stock >
                                                productList[index].add_qnty) {
                                              productList[index].add_qnty++;
                                              addOrMinusProduct(
                                                  productList[index]
                                                      .product_name,
                                                  productList[index].unit,
                                                  double.parse(
                                                      '${productList[index].price}'),
                                                  int.parse(
                                                      '${productList[index].quantity}'),
                                                  productList[index].add_qnty,
                                                  productList[index]
                                                      .varient_image,
                                                  productList[index]
                                                      .varient_id);
                                            } else {
                                               }
                                          });
                                        },
                                        child: Icon(
                                          Icons.add,
                                          color: kMainColor,
                                          size: 20.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                          ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 5,
                );
              },
            )
          : isDeal
              ? Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        radius: 20,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Loding data.......',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            color: kMainColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ))
              : Align(
                  alignment: Alignment.center,
                  child: Text('No deal found!'),
                ),
    );
  }

  void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
      varient_image, varient_id) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getcount(int.parse('${varient_id}')).then((value) {
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (price * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.is_pres: 0,
        DatabaseHelper.is_id: 0,
        DatabaseHelper.varientId: int.parse('${varient_id}')
      };
      if (value == 0) {
        db.insert(vae);
      } else {
        if (itemCount == 0) {
          db.delete(int.parse('${varient_id}'));
        } else {
          db.updateData(vae, int.parse('${varient_id}'));
        }
      }
      getCartCount();
    }).catchError((e) {
      print(e);
    });
  }
}

class TimerView extends StatefulWidget {
  final DateTime? dateTime;
  final double? fontSize;
  final Color? color;

  const TimerView({
    Key? key,
    this.dateTime,
    this.fontSize = 14,
    this.color,
  }) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  var timerCountDown = '00:00:00';
  Color colors = Colors.red;
  late DateTime dateCheck;
  late Timer timer;
  late DateTime dateTimeStart;

  @override
  void initState() {
    if (widget.dateTime == null) {
      dateTimeStart = DateTime.now();
    } else {
      dateTimeStart = widget.dateTime!;
    }
    if (widget.color != null) {
      colors = widget.color!;
    }
    dateCheck =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStart.toString());
    setTime();
    super.initState();
  }

  void setTime() {
    if (dateCheck.difference(DateTime.now()).inSeconds < 0) {
      setState(() {
        timerCountDown = getData(dateTimeStart.millisecondsSinceEpoch);
      });
    } else {
      if (dateCheck.difference(DateTime.now()).inHours < 24) {
        timer.cancel();
        timer = new Timer(new Duration(seconds: 1), () {
          setJustTime();
          setTime();
        });
      } else {
        final date = DateFormat('yyyy-MM-dd').parse(dateTimeStart.toString());
        final today = DateFormat('yyyy-MM-dd').parse(DateTime.now().toString());
        if (date.difference(today).inDays == 1) {
          colors = Colors.yellow;
          timerCountDown = 'Tomorrow';
        } else {
          if (!mounted) return;
          setState(() {
            colors = Colors.blueAccent;
            timerCountDown = DateFormat.E().format(date) +
                ', ' +
                DateFormat.d().format(date) +
                ' ' +
                DateFormat.MMM().format(date);
          });
        }
      }
    }
  }

  void setJustTime() {
    final seconds = dateCheck.difference(DateTime.now()).inSeconds;
    if (!mounted) return;
    setState(() {
      timerCountDown = secondsToHoursMinutesSeconds(seconds);
    });
  }

  String getData(int seconds) {
    var messageDate = new DateTime.fromMillisecondsSinceEpoch(seconds);
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(messageDate);
    var finalDate = DateTime.parse(formatted);
    var days = DateTime.now().difference(finalDate).inDays;
    if (days == 0) {
      if (DateTime.now().difference(messageDate).inHours > 0) {
        colors = Colors.black54;
        return '${DateTime.now().difference(messageDate).inHours} hours ago.';
      } else if (DateTime.now().difference(messageDate).inMinutes > 0) {
        return '${DateTime.now().difference(messageDate).inMinutes} minutes ago.';
      } else {
        return 'Few seconds ago.';
      }
    } else if (days == 1) {
      colors = Colors.red;
      return 'Yesterday ${DateFormat.jm().format(messageDate)}';
    } else if (days >= 2 && days <= 6) {
      return DateFormat.EEEE().format(messageDate) +
          " " +
          DateFormat.jm().format(messageDate);
    } else {
      return DateFormat.yMd().add_jm().format(messageDate);
    }
  }

  String secondsToHoursMinutesSeconds(int seconds) {
    var hour = seconds ~/ 3600;
    var minute = (seconds % 3600) ~/ 60;
    var second = (seconds % 3600) % 60;
    final hourUpdate = hour < 10 ? '0$hour' : '$hour';
    final minuteUpdate = minute < 10 ? '0$minute' : '$minute';
    final secondUpdate = second < 10 ? '0$second' : '$second';
    return hourUpdate + ' : ' + minuteUpdate + ' : ' + secondUpdate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Text(
        timerCountDown,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
          color: colors,
        ),
      ),
    ]));
  }
}
