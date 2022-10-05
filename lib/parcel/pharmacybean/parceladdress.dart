
class ParcelAddress{
  dynamic houseno;
  dynamic pincode;
  dynamic city;
  dynamic landmark;
  dynamic address;
  dynamic state;
  dynamic lat;
  dynamic lng;
  dynamic sendername;
  dynamic sendercontact;

  ParcelAddress(this.houseno, this.pincode, this.city, this.landmark,
      this.address, this.state,this.lat,this.lng,this.sendername,this.sendercontact);

  @override
  String toString() {
    return 'Name : $sendername\nContact Number : $sendercontact\nHouse No : $houseno\nLandmark : $landmark\nAddress : $address\nCity : $city\nState : $state ($pincode)';
  }
}