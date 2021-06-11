class Device {
  String battery;
  String deviceVersion;
  String id;
  String lastSyncTime;
  String type;

  Device(
      {this.battery,
      this.deviceVersion,
      this.id,
      this.lastSyncTime,
      this.type});

  Device.fromJson(Map<String, dynamic> json) {
    battery = json['battery'];
    deviceVersion = json['deviceVersion'];
    id = json['id'];
    lastSyncTime = json['lastSyncTime'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['battery'] = this.battery;
    data['deviceVersion'] = this.deviceVersion;
    data['id'] = this.id;
    data['lastSyncTime'] = this.lastSyncTime;
    data['type'] = this.type;
    return data;
  }
}

