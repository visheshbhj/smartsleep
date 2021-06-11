import 'package:hive/hive.dart';

@HiveType()
class NativeAlarms{

  @HiveField(0)
  int alarmId;

  @HiveField(1)
  bool deleted;

  @HiveField(2)
  bool enabled;

  @HiveField(3)
  bool recurring;

  @HiveField(4)
  int snoozeCount;

  @HiveField(5)
  int snoozeLength;

  @HiveField(6)
  bool syncedToDevice;

  @HiveField(7)
  String time;

  @HiveField(8)
  String vibe;

  @HiveField(9)
  List<String> weekDays;

  //Custom Data
  @HiveField(10)
  String deviceId;

  @HiveField(11)
  bool isSynced;

  @HiveField(12)
  String differentTime;

  @HiveField(13)
  bool isDifferentTime;

  NativeAlarms(
      {this.alarmId,
        this.deleted,
        this.enabled,
        this.recurring,
        this.snoozeCount,
        this.snoozeLength,
        this.syncedToDevice,
        this.time,
        this.vibe,
        this.weekDays,
        this.deviceId,
        this.isSynced,
        this.isDifferentTime,
        this.differentTime
      });

  ///
  /// Model for Device
  ///
  NativeAlarms.fromJson(Map<String, dynamic> json) {
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

    deviceId = json['deviceId'];
    isSynced = json['isSynced'];
    differentTime = json['differentTime'];
    isDifferentTime = json['isDifferentTime'];
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

    data['deviceId'] = this.deviceId;
    data['isSynced'] = this.isSynced;
    data['differentTime'] = this.differentTime;
    data['isDifferentTime'] = this.isDifferentTime;
    return data;
  }

}

class NativeAlarmsTypeAdapter extends TypeAdapter<NativeAlarms>{
  @override
  NativeAlarms read(BinaryReader reader) {
    return NativeAlarms(
      alarmId: reader.readInt(),
      deleted: reader.readBool(),
      deviceId: reader.readString(),
      differentTime: reader.readString(),
      enabled: reader.readBool(),
      isDifferentTime: reader.readBool(),
      isSynced: reader.readBool(),
      recurring: reader.readBool(),
      snoozeCount: reader.readInt(),
      snoozeLength: reader.readInt(),
      syncedToDevice: reader.readBool(),
      time: reader.readString(),
      vibe: reader.readString(),
      weekDays: reader.readStringList()
    );
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, NativeAlarms alarm) {
    writer.writeBool(alarm.isDifferentTime);
    writer.writeBool(alarm.isSynced);
    writer.writeBool(alarm.deleted);
    writer.writeBool(alarm.enabled);
    writer.writeBool(alarm.syncedToDevice);
    writer.writeBool(alarm.recurring);
    writer.writeInt(alarm.alarmId);
    writer.writeInt(alarm.snoozeCount);
    writer.writeInt(alarm.snoozeLength);
    writer.writeString(alarm.differentTime);
    writer.writeString(alarm.deviceId);
    writer.writeString(alarm.time);
    writer.writeString(alarm.vibe);
    writer.writeStringList(alarm.weekDays);
  }

}