import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bean/resturantbean/restaurantcartitem.dart';

import '../Themes/colors.dart';
import '../bean/cartitem.dart';
import '../bean/orderarray.dart';
import '../databasehelper/dbhelper.dart';

class instructions extends StatefulWidget {
  @override
  _instructionsState createState() => _instructionsState();
}

class _instructionsState extends State<instructions> {
  List<CartItem> cartListI = [];
  List<instructionbean> instructions = [];
  List<instructionbean> instructio = [];
  List<RestaurantCartItem> cartListII = [];
  String restins='';
  String message = '';


  @override
  void initState() {
    super.initState();
    getData();
    getResCartItem();
    getCartItem();
    clear();
  }

  @override
  Widget build(BuildContext context) {
  return
      Scaffold(
      appBar: AppBar(
      title:
      Text('Instructions', style: Theme
      .of(context)
      .textTheme
      .bodyText1),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
            child: TextButton(
              onPressed: () async {

                SharedPreferences preferences = await SharedPreferences.getInstance();
                preferences.setString("instructions", instructio.toString());
                preferences.setString("r_instructions", restins.toString());

                Navigator.pop(context);

              },
              child: Text(
                'Add',
                style:
                TextStyle(color: kMainColor, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
    ),
        body:
            Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    margin: EdgeInsets.all(8),
                    child:
                    (cartListI.length>0)?
                    ListView.builder(
                      itemCount: cartListI.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('${cartListI[index].store_name}'),
                            subtitle:TextField(
                              onSubmitted: (newText) {
                                addInstruction(cartListI[index].store_name,newText);
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hoverColor: kMainColor,
                                labelText: 'Instruction',
                                isDense: true, // Added this
                                contentPadding: EdgeInsets.all(8),  // Added this
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        :
                    Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(8),
                        child:
                        TextField(
                          onSubmitted: (newText) {
                            addInstruction2(newText);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hoverColor: kMainColor,
                            labelText: 'Instruction',
                            isDense: true, // Added this
                            contentPadding: EdgeInsets.all(8),  // Added this
                          ),
                        ))),

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
            )

      );
  }

  addInstruction(store_name,newText) async {
    instructions.add(instructionbean('"'+store_name+'"','"'+newText+'"'));
    setState(() {
      instructio = instructions.toSet().toList();
    });
  }

  addInstruction2(newText) async {
   restins = newText;
  }

  void getCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryAllRows().then((value) {
      List<CartItem> tagObjs =
      value.map((tagJson) => CartItem.fromJson(tagJson)).toList();

      if (tagObjs.isEmpty) {
        setState(() {});
      }
      else {
        final ids = tagObjs.map((e) => e.store_name).toSet();
        tagObjs.retainWhere((x) => ids.remove(x.store_name));

        setState(() {
          cartListI.clear();
          cartListI = tagObjs;
        });
      }
    });


    print("CART: "+cartListI.toString());
  }
  void getResCartItem() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getResturantOrderList().then((value) {
      List<RestaurantCartItem> tagObjs =
      value.map((tagJson) => RestaurantCartItem.fromJson(tagJson)).toList();
      setState(() {
        cartListII = List.from(tagObjs);
      });
      for (int i = 0; i < cartListII.length; i++) {
        print('${cartListII[i].varient_id}');
        db
            .getAddOnListWithPrice(int.parse('${cartListII[i].varient_id}'))
            .then((values) {
          List<AddonCartItem> tagObjsd =
          values.map((tagJson) => AddonCartItem.fromJson(tagJson)).toList();
          setState(() {
            cartListII[i].addon = tagObjsd;
          });
        });
      }
      setState(() {
      });
    });

    print("R CART: "+cartListII.toString());
  }

  Future<void> clear() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.remove("instructions");
    pref.remove("r_instructions");

  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      message = prefs.getString("message")!;
    });
  }

}