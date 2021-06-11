import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/model/NativeAlarms.dart';

class StringModel {
  String user;
}

class AlarmPayload{
  Device selectedDevice;
  NativeAlarms alarm;
  bool delete;
  AlarmPayload({this.delete,this.selectedDevice,this.alarm});
}