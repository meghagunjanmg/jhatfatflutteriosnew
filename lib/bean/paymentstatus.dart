class PaymentVia{

  dynamic payment_id;
  dynamic vendor_id;
  dynamic status;
  dynamic payment_key;
  dynamic payment_mode;

  PaymentVia(this.payment_id, this.vendor_id, this.status, this.payment_key,
      this.payment_mode);

  factory PaymentVia.fromJson(dynamic json){
    return PaymentVia(json['payment_id'], json['vendor_id'], json['status'], json['payment_key'], json['payment_mode']);
  }

  @override
  String toString() {
    return 'PaymentVia{payment_id: $payment_id, vendor_id: $vendor_id, status: $status, payment_key: $payment_key, payment_mode: $payment_mode}';
  }
}

class PaymentViaParcel{

  dynamic paymentvia_id;
  dynamic status;
  dynamic payment_key;
  dynamic payment_mode;

  PaymentViaParcel(this.paymentvia_id, this.status, this.payment_key,
      this.payment_mode);

  factory PaymentViaParcel.fromJson(dynamic json){
    return PaymentViaParcel(json['paymentvia_id'], json['status'], json['payment_key'], json['payment_mode']);
  }

  @override
  String toString() {
    return '{payment_id: $paymentvia_id, status: $status, payment_key: $payment_key, payment_mode: $payment_mode}';
  }
}