class CartItem{
  dynamic store_name;
  dynamic vendor_id;

  dynamic _id;
  dynamic product_name;
  dynamic qnty;
  dynamic price;
  dynamic unit;
  dynamic add_qnty;
  dynamic varient_id;
  dynamic product_img;

  dynamic is_id;
  dynamic is_pres;
  dynamic isBasket;
  dynamic addedBasket;

  CartItem(this.store_name,this.vendor_id,this._id, this.product_name, this.qnty, this.price, this.unit,
      this.add_qnty, this.varient_id, this.product_img,this.is_id,this.is_pres,this.isBasket,this.addedBasket);

  factory CartItem.fromJson(dynamic json){
    return CartItem(json['store_name'],json['vendor_id'],json['_id'], json['product_name'], json['qnty'], json['price'], json['unit'], json['add_qnty'], json['varient_id'], json['product_img'],json['is_id'],json['is_pres'],json['isBasket'],json['addedBasket']);
  }

  @override
  String toString() {
    return 'CartItem{store_name:$store_name,vendor_id:$vendor_id, _id: $_id, product_name: $product_name, qnty: $qnty, price: $price, unit: $unit, add_qnty: $add_qnty, varient_id: $varient_id, product_img: $product_img},is_id: $is_id},is_pres: $is_pres,isBasket:$isBasket,addedBasket:$addedBasket}';
  }
}