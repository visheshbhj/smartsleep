import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/model/Device.dart';

///
/// State
///

abstract class FABBlocState extends Equatable {
  const FABBlocState();

  @override
  List<Object> get props => [];
}

class FABNotInitialized extends FABBlocState{}
class FABInitialized extends FABBlocState{

  final List<Device> devices;
  final Device selectedDevice;

  FABInitialized({this.devices, this.selectedDevice});

  @override
  List<Object> get props => [devices,selectedDevice];
}

///
/// Event
///

abstract class FABEvent extends Equatable {
  const FABEvent();

  @override
  List<Object> get props => [];
}

class FABDevices extends FABEvent{

  final List<Device> devices;
  final Device selectedDevice;

  FABDevices({this.devices, this.selectedDevice});

  @override
  List<Object> get props => [devices,selectedDevice];
}

///
/// Bloc
///

class FABBloc extends Bloc<FABEvent,FABBlocState>{

  FABBloc(): super(FABNotInitialized());

  @override
  Stream<FABBlocState> mapEventToState(FABEvent event) async* {
    if(event is FABDevices){
      yield FABInitialized(devices: event.devices,selectedDevice: event.selectedDevice);
    }
  }

}