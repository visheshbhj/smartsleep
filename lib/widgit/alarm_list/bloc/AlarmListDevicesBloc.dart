import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';

import 'package:equatable/equatable.dart';

/**
 * Events
 **/
abstract class AlarmListDeviceEvent extends Equatable {
  const AlarmListDeviceEvent();

  @override
  List<Object> get props => [];
}

class LoadDevices extends AlarmListDeviceEvent{}

/**
 * State
 **/

abstract class AlarmListDeviceState extends Equatable {
  const AlarmListDeviceState();

  @override
  List<Object> get props => [];
}

class AlarmListStateUnInitialized extends AlarmListDeviceState{}
class AlarmListStateLoading extends AlarmListDeviceState{}

class AlarmListStateDevices extends AlarmListDeviceState{
  final List<Device> devices;

  const AlarmListStateDevices({this.devices});

  @override
  List<Object> get props => [devices];

  @override
  String toString() => 'AlarmListStateDevices { devices: $devices }';

}

/**
 * Bloc
 **/

class AlarmListDeviceBloc extends Bloc<AlarmListDeviceEvent,AlarmListDeviceState>{
  final HttpClient httpClient;

  AlarmListDeviceBloc({this.httpClient}) : super(AlarmListStateUnInitialized());

  @override
  Stream<AlarmListDeviceState> mapEventToState(AlarmListDeviceEvent event) async* {

    if(event is LoadDevices){
      yield AlarmListStateLoading();

      final response = await httpClient.authRequest(new Request('GET', Uri.parse(HttpClient.baseURI+'/1/user/-/devices.json')));
      List<Device> devices = json
          .decode(response.body)
          .map<Device>((json) => Device.fromJson(json))
          .toList();
      devices.removeWhere((device) => device.deviceVersion == 'MobileTrack');
      yield AlarmListStateDevices(devices: devices);
    }
  }

}