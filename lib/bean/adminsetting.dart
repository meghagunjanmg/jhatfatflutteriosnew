class Adminsetting {
  int? cityadminId;
  String? cityId;
  String? cityadminName;
  String? cityadminImage;
  String? cityadminPhone;
  String? cityadminEmail;
  String? cityadminPass;
  String? cityadminAddress;
  String? lat;
  String? lng;
  String? deviceId;
  String? createdAt;
  String? updatedAt;
  int? surge;
  int? surgePercent;
  int? status;
  String? topMessage;
  String? bottomMessage;
  String? surgeMsg;

  Adminsetting(
      {this.cityadminId,
        this.cityId,
        this.cityadminName,
        this.cityadminImage,
        this.cityadminPhone,
        this.cityadminEmail,
        this.cityadminPass,
        this.cityadminAddress,
        this.lat,
        this.lng,
        this.deviceId,
        this.createdAt,
        this.updatedAt,
        this.surge,
        this.surgePercent,
        this.status,
        this.topMessage,
        this.bottomMessage,
        this.surgeMsg});

  Adminsetting.fromJson(Map<String, dynamic> json) {
    cityadminId = json['cityadmin_id'];
    cityId = json['city_id'];
    cityadminName = json['cityadmin_name'];
    cityadminImage = json['cityadmin_image'];
    cityadminPhone = json['cityadmin_phone'];
    cityadminEmail = json['cityadmin_email'];
    cityadminPass = json['cityadmin_pass'];
    cityadminAddress = json['cityadmin_address'];
    lat = json['lat'];
    lng = json['lng'];
    deviceId = json['device_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    surge = json['surge'];
    surgePercent = json['surge_percent'];
    status = json['status'];
    topMessage = json['top_message'];
    bottomMessage = json['bottom_message'];
    surgeMsg = json['surge_msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cityadmin_id'] = this.cityadminId;
    data['city_id'] = this.cityId;
    data['cityadmin_name'] = this.cityadminName;
    data['cityadmin_image'] = this.cityadminImage;
    data['cityadmin_phone'] = this.cityadminPhone;
    data['cityadmin_email'] = this.cityadminEmail;
    data['cityadmin_pass'] = this.cityadminPass;
    data['cityadmin_address'] = this.cityadminAddress;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['device_id'] = this.deviceId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['surge'] = this.surge;
    data['surge_percent'] = this.surgePercent;
    data['status'] = this.status;
    data['top_message'] = this.topMessage;
    data['bottom_message'] = this.bottomMessage;
    data['surge_msg'] = this.surgeMsg;
    return data;
  }
}
