class TrackerAlarms {
  int alarmId;
  bool deleted;
  bool enabled;
  bool recurring;
  int snoozeCount;
  int snoozeLength;
  bool syncedToDevice;
  String time;
  String vibe;
  List<String> weekDays;

  TrackerAlarms(
      {this.alarmId,
      this.deleted,
      this.enabled,
      this.recurring,
      this.snoozeCount,
      this.snoozeLength,
      this.syncedToDevice,
      this.time,
      this.vibe,
      this.weekDays});

  TrackerAlarms.fromJson(Map<String, dynamic> json) {
    alarmId = json['alarmId'];
    deleted = json['deleted'];
    enabled = json['enabled'];
    recurring = json['recurring'];
    snoozeCount = json['snoozeCount'];
    snoozeLength = json['snoozeLength'];
    syncedToDevice = json['syncedToDevice'];
    time = json['time'];
    vibe = json['vibe'];
    weekDays = json['weekDays'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alarmId'] = this.alarmId;
    data['deleted'] = this.deleted;
    data['enabled'] = this.enabled;
    data['recurring'] = this.recurring;
    data['snoozeCount'] = this.snoozeCount;
    data['snoozeLength'] = this.snoozeLength;
    data['syncedToDevice'] = this.syncedToDevice;
    data['time'] = this.time;
    data['vibe'] = this.vibe;
    data['weekDays'] = this.weekDays;
    return data;
  }

}
