class BannerDetails {
  dynamic bannerId;
  dynamic bannerName;
  dynamic bannerImage;
  dynamic vendorId;
  dynamic vendorName;
  dynamic owner;
  dynamic cityadminId;
  dynamic vendorEmail;
  dynamic vendorPhone;
  dynamic vendorLogo;
  dynamic vendorLoc;
  dynamic lat;
  dynamic lng;
  dynamic openingTime;
  dynamic closingTime;
  dynamic vendorPass;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic vendorCategoryId;
  dynamic comission;
  dynamic deliveryRange;
  dynamic deviceId;
  dynamic otp;
  dynamic phoneVerified;
  dynamic uiType;
  dynamic onlineStatus;
  dynamic about;

  BannerDetails(
      {this.bannerId,
        this.bannerName,
        this.bannerImage,
        this.vendorId,
        this.vendorName,
        this.owner,
        this.cityadminId,
        this.vendorEmail,
        this.vendorPhone,
        this.vendorLogo,
        this.vendorLoc,
        this.lat,
        this.lng,
        this.openingTime,
        this.closingTime,
        this.vendorPass,
        this.createdAt,
        this.updatedAt,
        this.vendorCategoryId,
        this.comission,
        this.deliveryRange,
        this.deviceId,
        this.otp,
        this.phoneVerified,
        this.uiType,
        this.onlineStatus,
        this.about});

  BannerDetails.fromJson(dynamic json) {
    bannerId = json['banner_id'];
    bannerName = json['banner_name'];
    bannerImage = json['banner_image'];
    vendorId = json['vendor_id'];
    vendorName = json['vendor_name'];
    owner = json['owner'];
    cityadminId = json['cityadmin_id'];
    vendorEmail = json['vendor_email'];
    vendorPhone = json['vendor_phone'];
    vendorLogo = json['vendor_logo'];
    vendorLoc = json['vendor_loc'];
    lat = json['lat'];
    lng = json['lng'];
    openingTime = json['opening_time'];
    closingTime = json['closing_time'];
    vendorPass = json['vendor_pass'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vendorCategoryId = json['vendor_category_id'];
    comission = json['comission'];
    deliveryRange = json['delivery_range'];
    deviceId = json['device_id'];
    otp = json['otp'];
    phoneVerified = json['phone_verified'];
    uiType = json['ui_type'];
    onlineStatus = json['online_status'];
    about = json['about'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banner_id'] = this.bannerId;
    data['banner_name'] = this.bannerName;
    data['banner_image'] = this.bannerImage;
    data['vendor_id'] = this.vendorId;
    data['vendor_name'] = this.vendorName;
    data['owner'] = this.owner;
    data['cityadmin_id'] = this.cityadminId;
    data['vendor_email'] = this.vendorEmail;
    data['vendor_phone'] = this.vendorPhone;
    data['vendor_logo'] = this.vendorLogo;
    data['vendor_loc'] = this.vendorLoc;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['vendor_pass'] = this.vendorPass;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['vendor_category_id'] = this.vendorCategoryId;
    data['comission'] = this.comission;
    data['delivery_range'] = this.deliveryRange;
    data['device_id'] = this.deviceId;
    data['otp'] = this.otp;
    data['phone_verified'] = this.phoneVerified;
    data['ui_type'] = this.uiType;
    data['online_status'] = this.onlineStatus;
    data['about'] = this.about;
    return data;
  }
}