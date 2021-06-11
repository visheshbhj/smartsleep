import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartsleep/model/NativeAlarms.dart';

class AlarmRepository{
  static final DB_CHANNEL = new MethodChannel('app://smartsleep/db');
  static final BATTERY_CHANNEL = new EventChannel('app://smartsleep/battery');

  Future<String> getAll() {
    return DB_CHANNEL.invokeMethod('getAll');
  }

  Future<String> get(int id) {
    return DB_CHANNEL.invokeMethod('get',id);
  }

  void insert(NativeAlarms alarm) async{
    return DB_CHANNEL.invokeMethod('insert',jsonEncode(alarm.toJson()));
  }

  void update(NativeAlarms alarm) async{
    return DB_CHANNEL.invokeMethod('update',jsonEncode(alarm.toJson()));
  }

  void delete(NativeAlarms alarm) async{
    return DB_CHANNEL.invokeMethod('delete',jsonEncode(alarm.toJson()));
  }

  void deleteById(int id) async{
    return DB_CHANNEL.invokeMethod('deleteById',id);
  }

}