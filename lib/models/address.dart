import 'dart:convert';

class Address {
  String postcode;
  String postTown;
  String thoroughfare;
  String line1;
  String line2;
  String line3;
  double longitude;
  double latitude;
  String buildingName;
  String buildingNumber;
  String country;
  String county;
  String district;

  Address(
      {this.postcode,
      this.postTown,
      this.thoroughfare,
      this.line1,
      this.line2,
      this.line3,
      this.longitude,
      this.latitude,
      this.buildingName,
      this.buildingNumber,
      this.country,
      this.county,
      this.district});

  Address.fromJson(Map<String, dynamic> json) {
    postcode = json['postcode'];
    postTown = json['post_town'];
    thoroughfare = json['thoroughfare'];
    line1 = json['line_1'];
    line2 = json['line_2'];
    line3 = json['line_3'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    buildingName = json['building_name'];
    buildingNumber = json['building_number'];
    country = json['country'];
    county = json['county'];
    district = json['district'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postcode'] = this.postcode;
    data['post_town'] = this.postTown;
    data['thoroughfare'] = this.thoroughfare;
    data['line_1'] = this.line1;
    data['line_2'] = this.line2;
    data['line_3'] = this.line3;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['building_name'] = this.buildingName;
    data['building_number'] = this.buildingNumber;
    data['country'] = this.country;
    data['county'] = this.county;
    data['district'] = this.district;
    return data;
  }
}

List<Address> builderAddresses(List<dynamic> data) {
  return data.map((value) => new Address.fromJson(value)).toList();
}

String builderAddressesToJson(List<Address> addresses) =>
    json.encode(addresses);
