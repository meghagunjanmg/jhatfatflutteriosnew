import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:jhatfat/baseurlp/baseurl.dart';
import 'package:jhatfat/bean/productlistvarient.dart';
import 'package:jhatfat/bean/searchlist.dart';
import 'package:jhatfat/databasehelper/dbhelper.dart';

import '../bean/resturantbean/restaurantcartitem.dart';

class SingleProductPage_2 extends StatefulWidget {
  final ProductVarient productWithVarient;
  final dynamic currencyda;
  List<VarientList> productVarintList = [];

  SingleProductPage_2(this.productWithVarient, this.currencyda) {
    productVarintList = List.from(productWithVarient.data);
  }

  @override
  State<StatefulWidget> createState() {
    return SingleProductState2(productVarintList);
  }
}

class SingleProductState2 extends State<SingleProductPage_2> {
  var currentIndex = 0;
  int restrocart = 0;

  bool isCartCount = false;

  var cartCount = 0;
  dynamic v;

  SingleProductState2(List<VarientList> productVarint) {
    setList(productVarint);
  }

  void setList(List<VarientList> tagObjs) {
    for (int i = 0; i < tagObjs.length; i++) {
      DatabaseHelper db = DatabaseHelper.instance;
      db.getVarientCount(int.parse('${tagObjs[i].varient_id}')).then((value) {
        print('print val $value');
        if (value == null) {
          setState(() {
            tagObjs[i].add_qnty = 0;
          });
        } else {
          setState(() {
            tagObjs[i].add_qnty = value;
            isCartCount = true;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCartCount();
    getCartItem2();
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

  void getCartItem2() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getResturantOrderList().then((value) {
      List<RestaurantCartItem> tagObjs =
      value.map((tagJson) => RestaurantCartItem.fromJson(tagJson)).toList();
      if (tagObjs.isNotEmpty) {
        setState(() {
          restrocart = 1;
        });
      }
    });
  }

  showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: Text(
              'Grocery orders are to be placed separately.\nPlease clear/empty cart to add item. ',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Clear Cart'),
                onPressed: () {
                  ClearCart();
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }
    );
  }


  void ClearCart() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAllRestProdcut();
    getCartItem2();
    setState(() {
      restrocart = 0;
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
            '${widget.productWithVarient.product_name}',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w500),
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
                        Navigator.pushNamed(
                            context, PageRoutes.viewCart)
                            .then((value) {
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
        ),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                child: Image(
                  image: NetworkImage(imageBaseUrl +
                      widget.productWithVarient.data[0].varient_image),
                  fit: BoxFit.cover,
                ),
              )),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.0, right: 10, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                          color: (currentIndex == 0) ? kMainColor : kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(color: kMainColor)),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.5 - 20,
                      alignment: Alignment.center,
                      child: Text(
                        'Description',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color:
                            (currentIndex == 0) ? kWhiteColor : black_color,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 1;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                          color: (currentIndex == 1) ? kMainColor : kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(color: kMainColor)),
                      alignment: Alignment.center,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.5 - 20,
                      child: Text(
                        'Varient',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color:
                            (currentIndex == 1) ? kWhiteColor : black_color,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    ProductDescription(
                        widget.productWithVarient.data[0].description),
                    (widget.productVarintList.length > 0)
                        ? ListView.builder(
                        itemCount: widget.productVarintList.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0, top: 30.0, right: 14.0),
                                    child:
                                    (widget.productVarintList != null &&
                                        widget.productVarintList
                                            .length >
                                            0)
                                        ? Image.network(
                                      imageBaseUrl +
                                          widget
                                              .productVarintList[
                                          index]
                                              .varient_image,
                                      height: 93.3,
                                      width: 93.3,
                                      fit: BoxFit.fill,
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          padding:
                                          EdgeInsets.only(right: 20),
                                          child: Text(
                                              widget.productWithVarient
                                                  .product_name,
                                              style:
                                              bottomNavigationTextStyle
                                                  .copyWith(
                                                  fontSize: 15)),
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Row(
                                            children: [
                                              Text(
                                                  (widget
                                                      .productVarintList[index]
                                                      .toString()
                                                      .length < 0 || widget
                                                      .productVarintList[index]
                                                      .strick_price
                                                      <=
                                                      widget
                                                          .productVarintList[index]
                                                          .price ||
                                                      widget
                                                          .productVarintList[index]
                                                          .strick_price == null)
                                                      ? ''
                                                      : '${widget
                                                      .currencyda}  ${widget
                                                      .productVarintList[index]
                                                      .strick_price}',

                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough)),
                                              Text(
                                                '${widget.currencyda} ${widget
                                                    .productVarintList[index]
                                                    .price} ',
                                                //style: TextStyle(decoration: TextDecoration.lineThrough)
                                              ),
                                            ]),
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
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 30.0,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: kCardBackgroundColor,
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          '${widget.productVarintList[index]
                                              .quantity} ${widget
                                              .productVarintList[index].unit}',
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                        SizedBox(
                                          width: 8.0,
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: kMainColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  height: 30,
                                  right: 20.0,
                                  bottom: 5,
                                  child: widget.productVarintList[index]
                                      .add_qnty ==
                                      0
                                      ? Container(
                                    height: 30.0,
                                    child: TextButton(
                                      onPressed: () {
                                        if (restrocart == 1) {
                                          print("ALREADY");
                                          showMyDialog(context);
                                        }
                                        else {
                                          setState(() {
                                            if (widget
                                                .productVarintList[
                                            index]
                                                .stock >
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .add_qnty) {
                                              widget
                                                  .productVarintList[
                                              index]
                                                  .add_qnty++;
                                              addOrMinusProduct(
                                                widget
                                                    .productWithVarient
                                                    .is_id,
                                                widget
                                                    .productWithVarient
                                                    .is_pres,
                                                widget
                                                    .productWithVarient
                                                    .isbasket,
                                                widget
                                                    .productWithVarient,
                                                widget
                                                    .productWithVarient
                                                    .product_name,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .unit,
                                                double.parse(
                                                    '${widget
                                                        .productVarintList[index]
                                                        .price}'),
                                                int.parse(
                                                    '${widget
                                                        .productVarintList[index]
                                                        .quantity}'),
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .add_qnty,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .varient_image,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .varient_id,
                                              );
                                            } else {
                                              Toast.show(
                                                  "No more stock available!",
                                                  duration: Toast.lengthShort,
                                                  gravity: Toast.bottom);
                                            }
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Add',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                            color: kMainColor,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                    ),
                                  )
                                      : Container(
                                    height: 30.0,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 11.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: kMainColor),
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget
                                                  .productVarintList[
                                              index]
                                                  .add_qnty--;
                                            });
                                            addOrMinusProduct(
                                                widget
                                                    .productWithVarient
                                                    .is_id,
                                                widget
                                                    .productWithVarient
                                                    .is_pres,
                                                widget
                                                    .productWithVarient
                                                    .isbasket,
                                                widget
                                                    .productWithVarient
                                                    .product_name,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .unit,
                                                double.parse(
                                                    '${widget
                                                        .productVarintList[index]
                                                        .price}'),
                                                int.parse(
                                                    '${widget
                                                        .productVarintList[index]
                                                        .quantity}'),
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .add_qnty,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .varient_image,
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .varient_id,
                                                widget.productVarintList[index]
                                                    .vendor_id
                                            );
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
                                            widget
                                                .productVarintList[
                                            index]
                                                .add_qnty
                                                .toString(),
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .caption),
                                        SizedBox(width: 8.0),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (widget
                                                  .productVarintList[
                                              index]
                                                  .stock >
                                                  widget
                                                      .productVarintList[
                                                  index]
                                                      .add_qnty) {
                                                widget
                                                    .productVarintList[
                                                index]
                                                    .add_qnty++;
                                                addOrMinusProduct(
                                                    widget
                                                        .productWithVarient
                                                        .is_id,
                                                    widget
                                                        .productWithVarient
                                                        .is_pres,
                                                    widget
                                                        .productWithVarient
                                                        .isbasket,
                                                    widget
                                                        .productWithVarient
                                                        .product_name,
                                                    widget
                                                        .productVarintList[
                                                    index]
                                                        .unit,
                                                    double.parse(
                                                        '${widget
                                                            .productVarintList[index]
                                                            .price}'),
                                                    int.parse(
                                                        '${widget
                                                            .productVarintList[index]
                                                            .quantity}'),
                                                    widget
                                                        .productVarintList[
                                                    index]
                                                        .add_qnty,
                                                    widget
                                                        .productVarintList[
                                                    index]
                                                        .varient_image,
                                                    widget
                                                        .productVarintList[
                                                    index]
                                                        .varient_id,
                                                    widget
                                                        .productVarintList[index]
                                                        .vendor_id
                                                );
                                              } else {
                                                Toast.show(
                                                    "No more stock available!",
                                                    duration: Toast.lengthShort,
                                                    gravity: Toast.bottom);
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
                                  )),
                            ],
                          );
                        })
                        : Container(),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void addOrMinusProduct(is_id, is_pres, isbasket, product_name, unit, price,
      quantity, itemCount,
      varient_image, varient_id, vendorid) async {
    DatabaseHelper db = DatabaseHelper.instance;

    Future<int?> existing = db.getcount(int.parse('${varient_id}'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? store_name = prefs.getString('store_name');

    existing.then((value) {
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.storeName: store_name,
        DatabaseHelper.vendor_id: vendorid,
        DatabaseHelper.price: (price * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.is_pres: is_pres,
        DatabaseHelper.is_id: is_id,
        DatabaseHelper.isBasket: isbasket,
        DatabaseHelper.addedBasket: 0,
        DatabaseHelper.varientId: int.parse('${varient_id}')
      };

      bool allow = (prefs.getString("allowmultishop").toString() != "1");
      if (value == 0) {
        if (v != null && v < 3) {
          db.insert(vae);
          getCartCount();
        }
        else {
          db.delete(int.parse('${varient_id}'));
          showMyDialog2(context);
        }
      }

      else {
        if (itemCount == 0) {
          db.delete(int.parse('${varient_id}'));
          getCartCount();
        } else {
          db.updateData(vae, int.parse('${varient_id}')).then((vay) {
            print('vay - $vay');
            getCartCount();
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }
}
class ProductDescription extends StatelessWidget {
  final dynamic description;

  ProductDescription(this.description);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          primary: true,
          child: Text(
            '${description}',
            style: TextStyle(
                fontSize: 16,
                color: kHintColor,
                height: 1.5,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
showMyDialog2(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: const Text(
            'Maximum Vendor Limit Reached',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      }
  );
}
