
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/model/NativeAlarms.dart';
import 'package:smartsleep/model/TrackerAlarms.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';
import 'package:smartsleep/utils/db/AlarmRepository.dart';
import 'package:smartsleep/widgit/alarmForm/WeekDays.dart';
import 'package:smartsleep/widgit/alarm_list/bloc/AlarmListAlarmBloc.dart';

///
/// State
///

abstract class AlarmFormState extends Equatable {
  const AlarmFormState();

  @override
  List<Object> get props => [];
}

class AlarmFormStateNotInitialized extends AlarmFormState{}
/*class AlarmFormStateSaved extends AlarmFormState{
  final Device selectedDevice;

  AlarmFormStateSaved(this.selectedDevice);

  @override
  List<Object> get props => [this.selectedDevice];
}
class AlarmFormStateDeleted extends AlarmFormState{
  final Device selectedDevice;

  AlarmFormStateDeleted(this.selectedDevice);

  @override
  List<Object> get props => [this.selectedDevice];
}
class AlarmFormStateError extends AlarmFormState{}*/

///
///Event
///

abstract class AlarmFormEvent extends Equatable {
  const AlarmFormEvent();

  @override
  List<Object> get props => [];
}

class SaveAlarm extends AlarmFormEvent{
  final bool createAlarm;
  final Device selectedDevice;
  final NativeAlarms alarm;
  final NativeAlarms oldAlarm;

  SaveAlarm({this.createAlarm, this.selectedDevice, this.alarm,this.oldAlarm});

  @override
  List<Object> get props => [selectedDevice,alarm];

}
class DeleteAlarm extends AlarmFormEvent{
  final Device selectedDevice;
  final NativeAlarms alarm;

  DeleteAlarm(this.selectedDevice, this.alarm);

  @override
  List<Object> get props => [selectedDevice,alarm];
}

///
///Bloc
///

class AlarmFormBloc extends Bloc<AlarmFormEvent,AlarmFormState>{

  final HttpClient httpClient;
  final AlarmListAlarmBloc alarmListAlarmBloc;
  final AlarmRepository repository;

  AlarmFormBloc({this.httpClient,this.alarmListAlarmBloc,this.repository}) :super(AlarmFormStateNotInitialized());

  @override
  Stream<AlarmFormState> mapEventToState(AlarmFormEvent event) async* {
    if(event is SaveAlarm){

      Request request;
      String uriParameters = 'time='+Uri.encodeComponent(event.alarm.time)+'&enabled='+event.alarm.enabled.toString()+'&recurring='+event.alarm.recurring.toString()+'&weekDays='+WeekDayWidget.getString(event.alarm.weekDays);
      if(event.createAlarm){ //Creating Alarm
        request = new Request('POST', Uri.parse(HttpClient.baseURI + '/1/user/-/devices/tracker/'+event.selectedDevice.id+'/alarms.json?'+uriParameters));
      }else{  //Modifying Existing
        String additionalParams = uriParameters+'&snoozeLength='+event.alarm.snoozeLength.toString()+'&snoozeCount='+event.alarm.snoozeCount.toString();
        request = new Request('POST', Uri.parse(HttpClient.baseURI + '/1/user/-/devices/tracker/'+event.selectedDevice.id+'/alarms/'+event.alarm.alarmId.toString()+'.json?'+additionalParams));
      }

      final response = await httpClient.authRequest(request);
      if(event.createAlarm ? response.statusCode==201 : response.statusCode==200){// Insert is 201 & update is 200

        if(event.createAlarm && event.alarm.isSynced){//Create Alarm
          Map<String,dynamic> extraData = Map();
          extraData.putIfAbsent('deviceId', () =>event.selectedDevice.id);
          extraData.putIfAbsent('isSynced', () =>event.alarm.isSynced);
          extraData.putIfAbsent('differentTime', () =>event.alarm.differentTime);
          extraData.putIfAbsent('isDifferentTime', () =>event.alarm.isDifferentTime);

          TrackerAlarms alarms = TrackerAlarms.fromJson(jsonDecode(response.body)['trackerAlarm']);
          extraData.addAll(alarms.toJson());
          repository.insert(NativeAlarms.fromJson(extraData));//Insert
        }

        if( !event.createAlarm){//Update Alarm

          //If Alarm is present in db
          // Its Obvious if alarm is present in db then sync is true
          try{
            String data = await repository.get(event.alarm.alarmId);
            NativeAlarms alarm = NativeAlarms.fromJson(jsonDecode(data));

            if(alarm.isSynced){
              if(event.alarm.isSynced){
                repository.update(event.alarm);
              }else{
                repository.delete(event.alarm);
              }
            }

          }catch(err){
            if(event.alarm.isSynced){
              repository.insert(event.alarm);
            }
          }
        }

        alarmListAlarmBloc.add(AlarmFormNotification(message: 'Alarm Saved !',sync: true,selectedDevice: event.selectedDevice));
      }else{
        alarmListAlarmBloc.add(AlarmFormNotification(message: 'Issue while saving !',sync: false));
      }
    }

    if(event is DeleteAlarm){
      Request request  = new Request('DELETE', Uri.parse(HttpClient.baseURI + '/1/user/-/devices/tracker/'+event.selectedDevice.id+'/alarms/'+event.alarm.alarmId.toString()+'.json'));
      final response = await httpClient.authRequest(request);

      if(response.statusCode==204){
        alarmListAlarmBloc.add(AlarmFormNotification(message: 'Alarm Deleted !',sync: true,selectedDevice: event.selectedDevice));
        if(event.alarm.isSynced) {
          repository.delete(event.alarm);
        }
      }else{
        alarmListAlarmBloc.add(AlarmFormNotification(message: 'Unable to delete !',sync: false));
      }
    }
  }

}