class TodayOrderParcel {
  dynamic parcelId;
  dynamic sourceAddressId;
  dynamic sourceLat;
  dynamic sourceLng;
  dynamic sourcePhone;
  dynamic sourceName;
  dynamic destinationLat;
  dynamic destinationLng;
  dynamic destinationName;
  dynamic destinationPhone;
  dynamic destinationAddressId;
  dynamic cartId;
  dynamic userId;
  dynamic vendorId;
  dynamic weight;
  dynamic length;
  dynamic height;
  dynamic width;
  dynamic pickupTime;
  dynamic pickupDate;
  dynamic lat;
  dynamic lng;
  dynamic charges;
  dynamic distance;
  dynamic paymentMethod;
  dynamic orderStatus;
  dynamic paymentStatus;
  dynamic wallet;
  dynamic dboyId;
  dynamic userName;
  dynamic userEmail;
  dynamic userImage;
  dynamic userPhone;
  dynamic userPassword;
  dynamic deviceId;
  dynamic walletCredits;
  dynamic rewards;
  dynamic otp;
  dynamic phoneVerified;
  dynamic referralCode;
  dynamic sourcePincode;
  dynamic sourceHouseno;
  dynamic sourceLandmark;
  dynamic sourceAdd;
  dynamic sourceState;
  dynamic destinationPincode;
  dynamic destinationHouseno;
  dynamic destinationLandmark;
  dynamic destinationAdd;
  dynamic destinationState;
  dynamic vendorName;
  dynamic owner;
  dynamic vendorEmail;
  dynamic vendorPhone;
  dynamic vendorLogo;
  dynamic vendorLoc;
  dynamic openingTime;
  dynamic closingTime;
  dynamic vendorPass;
  dynamic vendorCategoryId;
  dynamic comission;
  dynamic deliveryRange;
  dynamic uiType;
  dynamic onlineStatus;
  dynamic deliveryBoyId;
  dynamic deliveryBoyName;
  dynamic deliveryBoyPhone;
  dynamic parcelDescription;
  dynamic surgecharge;
  dynamic nightcharge;
  dynamic convcharge;

  TodayOrderParcel(
      {this.parcelId,
        this.sourceAddressId,
        this.sourceLat,
        this.sourceLng,
        this.sourcePhone,
        this.sourceName,
        this.destinationLat,
        this.destinationLng,
        this.destinationName,
        this.destinationPhone,
        this.destinationAddressId,
        this.cartId,
        this.userId,
        this.vendorId,
        this.weight,
        this.length,
        this.height,
        this.width,
        this.pickupTime,
        this.pickupDate,
        this.lat,
        this.lng,
        this.charges,
        this.distance,
        this.paymentMethod,
        this.orderStatus,
        this.paymentStatus,
        this.wallet,
        this.dboyId,
        this.userName,
        this.userEmail,
        this.userImage,
        this.userPhone,
        this.userPassword,
        this.deviceId,
        this.walletCredits,
        this.rewards,
        this.otp,
        this.phoneVerified,
        this.referralCode,
        this.sourcePincode,
        this.sourceHouseno,
        this.sourceLandmark,
        this.sourceAdd,
        this.sourceState,
        this.destinationPincode,
        this.destinationHouseno,
        this.destinationLandmark,
        this.destinationAdd,
        this.destinationState,
        this.vendorName,
        this.owner,
        this.vendorEmail,
        this.vendorPhone,
        this.vendorLogo,
        this.vendorLoc,
        this.openingTime,
        this.closingTime,
        this.vendorPass,
        this.vendorCategoryId,
        this.comission,
        this.deliveryRange,
        this.uiType,
        this.onlineStatus,
        this.deliveryBoyId,
        this.deliveryBoyName,
        this.deliveryBoyPhone,
        this.parcelDescription,
        this.surgecharge,
        this.nightcharge,
        this.convcharge});

  TodayOrderParcel.fromJson(Map<String, dynamic> json) {
    parcelId = json['parcel_id'];
    sourceAddressId = json['source_address_id'];
    sourceLat = json['source_lat'];
    sourceLng = json['source_lng'];
    sourcePhone = json['source_phone'];
    sourceName = json['source_name'];
    destinationLat = json['destination_lat'];
    destinationLng = json['destination_lng'];
    destinationName = json['destination_name'];
    destinationPhone = json['destination_phone'];
    destinationAddressId = json['destination_address_id'];
    cartId = json['cart_id'];
    userId = json['user_id'];
    vendorId = json['vendor_id'];
    weight = json['weight'];
    length = json['length'];
    height = json['height'];
    width = json['width'];
    pickupTime = json['pickup_time'];
    pickupDate = json['pickup_date'];
    lat = json['lat'];
    lng = json['lng'];
    charges = json['charges'];
    distance = json['distance'];
    paymentMethod = json['payment_method'];
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];
    wallet = json['wallet'];
    dboyId = json['dboy_id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userImage = json['user_image'];
    userPhone = json['user_phone'];
    userPassword = json['user_password'];
    deviceId = json['device_id'];
    walletCredits = json['wallet_credits'];
    rewards = json['rewards'];
    otp = json['otp'];
    phoneVerified = json['phone_verified'];
    referralCode = json['referral_code'];
    sourcePincode = json['source_pincode'];
    sourceHouseno = json['source_houseno'];
    sourceLandmark = json['source_landmark'];
    sourceAdd = json['source_add'];
    sourceState = json['source_state'];
    destinationPincode = json['destination_pincode'];
    destinationHouseno = json['destination_houseno'];
    destinationLandmark = json['destination_landmark'];
    destinationAdd = json['destination_add'];
    destinationState = json['destination_state'];
    vendorName = json['vendor_name'];
    owner = json['owner'];
    vendorEmail = json['vendor_email'];
    vendorPhone = json['vendor_phone'];
    vendorLogo = json['vendor_logo'];
    vendorLoc = json['vendor_loc'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    vendorPass = json['vendor_pass'];
    vendorCategoryId = json['vendor_category_id'];
    comission = json['comission'];
    deliveryRange = json['delivery_range'];
    uiType = json['ui_type'];
    onlineStatus = json['online_status'];
    deliveryBoyId = json['delivery_boy_id'];
    deliveryBoyName = json['delivery_boy_name'];
    deliveryBoyPhone = json['delivery_boy_phone'];
    parcelDescription = json['parcel_description'];
    surgecharge = json['surgecharge'];
    nightcharge = json['nightcharge'];
    convcharge = json['convcharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parcel_id'] = this.parcelId;
    data['source_address_id'] = this.sourceAddressId;
    data['source_lat'] = this.sourceLat;
    data['source_lng'] = this.sourceLng;
    data['source_phone'] = this.sourcePhone;
    data['source_name'] = this.sourceName;
    data['destination_lat'] = this.destinationLat;
    data['destination_lng'] = this.destinationLng;
    data['destination_name'] = this.destinationName;
    data['destination_phone'] = this.destinationPhone;
    data['destination_address_id'] = this.destinationAddressId;
    data['cart_id'] = this.cartId;
    data['user_id'] = this.userId;
    data['vendor_id'] = this.vendorId;
    data['weight'] = this.weight;
    data['length'] = this.length;
    data['height'] = this.height;
    data['width'] = this.width;
    data['pickup_time'] = this.pickupTime;
    data['pickup_date'] = this.pickupDate;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['charges'] = this.charges;
    data['distance'] = this.distance;
    data['payment_method'] = this.paymentMethod;
    data['order_status'] = this.orderStatus;
    data['payment_status'] = this.paymentStatus;
    data['wallet'] = this.wallet;
    data['dboy_id'] = this.dboyId;
    data['user_name'] = this.userName;
    data['user_email'] = this.userEmail;
    data['user_image'] = this.userImage;
    data['user_phone'] = this.userPhone;
    data['user_password'] = this.userPassword;
    data['device_id'] = this.deviceId;
    data['wallet_credits'] = this.walletCredits;
    data['rewards'] = this.rewards;
    data['otp'] = this.otp;
    data['phone_verified'] = this.phoneVerified;
    data['referral_code'] = this.referralCode;
    data['source_pincode'] = this.sourcePincode;
    data['source_houseno'] = this.sourceHouseno;
    data['source_landmark'] = this.sourceLandmark;
    data['source_add'] = this.sourceAdd;
    data['source_state'] = this.sourceState;
    data['destination_pincode'] = this.destinationPincode;
    data['destination_houseno'] = this.destinationHouseno;
    data['destination_landmark'] = this.destinationLandmark;
    data['destination_add'] = this.destinationAdd;
    data['destination_state'] = this.destinationState;
    data['vendor_name'] = this.vendorName;
    data['owner'] = this.owner;
    data['vendor_email'] = this.vendorEmail;
    data['vendor_phone'] = this.vendorPhone;
    data['vendor_logo'] = this.vendorLogo;
    data['vendor_loc'] = this.vendorLoc;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['vendor_pass'] = this.vendorPass;
    data['vendor_category_id'] = this.vendorCategoryId;
    data['comission'] = this.comission;
    data['delivery_range'] = this.deliveryRange;
    data['ui_type'] = this.uiType;
    data['online_status'] = this.onlineStatus;
    data['delivery_boy_id'] = this.deliveryBoyId;
    data['delivery_boy_name'] = this.deliveryBoyName;
    data['delivery_boy_phone'] = this.deliveryBoyPhone;
    data['parcel_description'] = this.parcelDescription;
    data['surgecharge'] = this.surgecharge;
    data['nightcharge'] = this.nightcharge;
    data['convcharge'] = this.convcharge;
    return data;
  }
}