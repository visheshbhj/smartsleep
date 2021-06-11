import 'package:smartsleep/model/TrackerAlarms.dart';

class Alarms {
  List<TrackerAlarms> trackerAlarms;

  Alarms({this.trackerAlarms});

  Alarms.fromJson(Map<String, dynamic> json) {
    if (json['trackerAlarms'] != null) {
      trackerAlarms = new List<TrackerAlarms>();
      json['trackerAlarms'].forEach((v) {
        trackerAlarms.add(new TrackerAlarms.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.trackerAlarms != null) {
      data['trackerAlarms'] =
          this.trackerAlarms.map((v) => v.toJson()).toList();
    }
    return data;
  }

}