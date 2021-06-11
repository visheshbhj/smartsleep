import 'package:flutter/material.dart';
import 'package:smartsleep/model/NativeAlarms.dart';

class TimeUtils {

  static String get12HrFormatedTime(NativeAlarms alarm){
    String hour = alarm.time.substring(0, alarm.time.indexOf(':'));
    String hourClock;

    if (int.parse(hour) >= 12) {
      hour = (int.parse(hour) - 12).toString();
      hourClock = ' PM';
    } else {
      if(hour.startsWith('0')){
        hour = hour.substring(1);
      }
      hourClock = ' AM';
    }
    String minute = alarm.time.substring(3, 5);
    return hour +':'+minute+hourClock;
  }

  static String getTimeNow(){
    String hour;
    String minute;
    if(DateTime.now().hour <=9){
    hour = '0'+DateTime.now().hour.toString();
    }else{
      hour = DateTime.now().hour.toString();
    }
    if(DateTime.now().minute <= 9){
      minute = '0'+DateTime.now().minute.toString();
    }else{
      minute = DateTime.now().minute.toString();
    }
    return hour +':'+minute+getTimeOffset();
  }

  static TimeOfDay getTimeOfDay(NativeAlarms alarm){
    String hour = alarm.time.substring(0, alarm.time.indexOf(':'));
    String minute = alarm.time.substring(3, 5);
    return new TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
  }

  static String getTimeFromTimeOfDay(TimeOfDay timeOfDay){

    String hour;
    String minute;

    if(timeOfDay.hour<=9){
      hour = '0'+timeOfDay.hour.toString();
    }else{
      hour = timeOfDay.hour.toString();
    }

    if(timeOfDay.minute<=9){
      minute = '0'+timeOfDay.minute.toString();
    }else{
      minute = timeOfDay.minute.toString();
    }

    return hour+":"+minute+getTimeOffset();
  }

  static String getTimeOffset(){
    String offset = DateTime.now().timeZoneOffset.toString();
    offset = offset.substring(0,offset.lastIndexOf(':'));

    String newOffset;

    if(offset.startsWith('-') || offset.startsWith('+')){
      newOffset = offset.substring(0,1);
      offset = offset.substring(1);
    }else{
      newOffset = '+';
    }

    if(offset.substring(0,offset.lastIndexOf(':')).length==2){
      newOffset = newOffset +offset.substring(0,offset.lastIndexOf(':'));
    }else{
      newOffset = newOffset +'0'+offset.substring(0,offset.lastIndexOf(':'));
    }

    offset = offset.substring(offset.lastIndexOf(':'),offset.length);
    //print(newOffset+offset);
    return newOffset+offset;
  }

}