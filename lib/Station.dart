class Station {
  int code;
  Data data;

  Station({this.code, this.data});

  Station.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<Bici> bici;

  Data({this.bici});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['bici'] != null) {
      bici = new List<Bici>();
      json['bici'].forEach((v) {
        bici.add(new Bici.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bici != null) {
      data['bici'] = this.bici.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bici {
  String id;
  String name;
  String lat;
  String lon;
  String nearbyStations;

  Bici({this.id, this.name, this.lat, this.lon, this.nearbyStations});

  Bici.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    lat = json['lat'];
    lon = json['lon'];
    nearbyStations = json['nearby_stations'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['nearby_stations'] = this.nearbyStations;
    return data;
  }
}