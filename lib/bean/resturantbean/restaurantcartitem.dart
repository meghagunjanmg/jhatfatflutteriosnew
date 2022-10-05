
class RestaurantCartItem{
  dynamic varient_id;
  dynamic store_name;
  dynamic add_qnty;
  dynamic qnty;
  dynamic unit;
  dynamic price;
  dynamic product_name;
  List<AddonCartItem> addon;

  RestaurantCartItem(this.varient_id,this.store_name, this.add_qnty, this.qnty, this.unit,
      this.price, this.product_name, this.addon);

  factory RestaurantCartItem.fromJson(dynamic json){
    return RestaurantCartItem(json['varient_id'], json['store_name'],json['add_qnty'], json['qnty'], json['unit'], json['price'], json['product_name'], []);
  }

  @override
  String toString() {
    return '[{\"varient_id\": $varient_id,\"store_name\": $store_name, \"add_qnty\": $add_qnty, \"qnty\": $qnty, \"unit\": $unit, \"price\": $price, \"product_name\": $product_name, \"addon\": $addon}]';
  }
}

class AddonCartItem{
  dynamic varient_id;
  dynamic addonName;
  dynamic addonid;
  dynamic price;

  AddonCartItem(this.varient_id, this.addonName, this.addonid, this.price);

  factory AddonCartItem.fromJson(dynamic json){
    return AddonCartItem(json['varient_id'], json['addonname'], json['addonid'], json['price']);
  }

  @override
  String toString() {
    return '[{\"varient_id\": $varient_id, \"addonname\": $addonName, \"addonid\": $addonid, \"price\": $price}]';
  }
}