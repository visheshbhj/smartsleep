import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:smartsleep/model/Alarms.dart';
import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/model/NativeAlarms.dart';
import 'package:smartsleep/model/TrackerAlarms.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';

import 'package:equatable/equatable.dart';
import 'package:smartsleep/utils/db/AlarmRepository.dart';

/// Events
///*/
abstract class AlarmListAlarmEvent extends Equatable {
  const AlarmListAlarmEvent();

  @override
  List<Object> get props => [];
}

class LoadAlarms extends AlarmListAlarmEvent{
  final Device selectedDevice;

  const LoadAlarms({this.selectedDevice});

  @override
  List<Object> get props => [this.selectedDevice];

  @override
  String toString() => 'Load Alarms from : $selectedDevice';
}

class AlarmFormNotification extends AlarmListAlarmEvent{
  final Device selectedDevice;
  final String message;
  final bool sync;

  const AlarmFormNotification({this.message,this.sync,this.selectedDevice});

  @override
  List<Object> get props => [this.message];

  @override
  String toString() => 'Alarm Form Notification : $message';
}

/// State
///*/

abstract class AlarmListAlarmState extends Equatable {
  const AlarmListAlarmState();

  @override
  List<Object> get props => [];
}

class AlarmListStateAlarmsUnInitialized extends AlarmListAlarmState{}
class AlarmListStateAlarmsLoading extends AlarmListAlarmState{}

class AlarmLoaded extends AlarmListAlarmState{
  final Device selectedDevice;
  final List<NativeAlarms> alarms;

  const AlarmLoaded({this.selectedDevice,this.alarms});

  @override
  List<Object> get props => [selectedDevice,alarms];

  @override
  String toString() => 'AlarmLoaded { selectedDevice: $selectedDevice, alarms: $alarms }';
}

class NoAlarmLoaded extends AlarmListAlarmState{
  final Device selectedDevice;

  const NoAlarmLoaded({this.selectedDevice});

  @override
  List<Object> get props => [selectedDevice];

  @override
  String toString() => 'AlarmLoaded { selectedDevice: $selectedDevice}';

}

class AlarmFormNotificationState extends AlarmListAlarmState{
  final String message;
  const AlarmFormNotificationState({this.message});

  @override
  List<Object> get props => [this.message];

  @override
  String toString() => 'Alarm Form Notification : $message';
}

/// Bloc

///*/

class AlarmListAlarmBloc extends Bloc<AlarmListAlarmEvent,AlarmListAlarmState>{
  final HttpClient httpClient;
  final AlarmRepository repository;

  AlarmListAlarmBloc({this.httpClient,this.repository}): super(AlarmListStateAlarmsUnInitialized());

  @override
  Stream<AlarmListAlarmState> mapEventToState(AlarmListAlarmEvent event) async* {

    if(event is LoadAlarms){//check if alarm present
      yield AlarmListStateAlarmsLoading();

      String nativeAlarmsData = await repository.getAll();
      final response = await httpClient.authRequest(new Request('GET', Uri.parse(HttpClient.baseURI + '/1/user/-/devices/tracker/' + event.selectedDevice.id + '/alarms.json')));
      Alarms alarms = Alarms.fromJson(jsonDecode(response.body));
      print('###################### Native Data ########################');
      print(nativeAlarmsData);
      print('###########################################################');
      List<NativeAlarms> nativeAlarms = jsonDecode(nativeAlarmsData).map<NativeAlarms>((data) => NativeAlarms.fromJson(data)).toList();
      print(nativeAlarms);

      List<NativeAlarms> responseAlarms = List();

      Map<String,dynamic> emptyData = Map();
      emptyData.putIfAbsent('deviceId', () =>event.selectedDevice.id);
      emptyData.putIfAbsent('isSynced', () =>false);
      emptyData.putIfAbsent('differentTime', () =>'');
      emptyData.putIfAbsent('isDifferentTime', () =>false);

      if(nativeAlarms.length==0){
        for(TrackerAlarms alarm in alarms.trackerAlarms){
          Map<String,dynamic> newData = Map();
          newData.addAll(emptyData);
          newData.addAll(alarm.toJson());
          responseAlarms.add(NativeAlarms.fromJson(newData));
        }
      }else{

        //1) Check if Alarm Present in Native
        for(TrackerAlarms alarm in alarms.trackerAlarms){

          bool found = false;
          for(NativeAlarms nativeAlarm in nativeAlarms){
            if(alarm.alarmId==nativeAlarm.alarmId){
              responseAlarms.add(nativeAlarm);//Check If Fitbit has changed any thing & make it reflect on NativeAlarms
              found=true;
              break;
            }
          }

          if(!found){  //If Alarm Not Found
            Map<String,dynamic> newData = Map();
            newData.addAll(emptyData);
            newData.addAll(alarm.toJson());
            responseAlarms.add(NativeAlarms.fromJson(newData));
          }

        }

        //Delete Alarms in Native if deleted from backend
        Set<int> alarmsIds = alarms.trackerAlarms.map((alarm) => alarm.alarmId).toSet();
        Set<int> nativeIds = nativeAlarms.map((alarm) => alarm.alarmId).toSet();
        Set<int> toDelete = nativeIds.difference(alarmsIds);

        for(int alarmId in toDelete){
          nativeAlarms.removeWhere((alarm) => alarm.alarmId == alarmId);
        }

      }

      if(responseAlarms.length==0){
        yield NoAlarmLoaded(selectedDevice: event.selectedDevice);
      }else{
        yield AlarmLoaded(selectedDevice: event.selectedDevice ,alarms: responseAlarms);
      }
    }
    if(event is AlarmFormNotification){
      if(event.sync){
        this.add(LoadAlarms(selectedDevice: event.selectedDevice));
      }
      yield AlarmFormNotificationState(message: event.message);
    }
  }

}