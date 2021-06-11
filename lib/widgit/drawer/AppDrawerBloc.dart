import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:smartsleep/model/StringModel.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';

///
/// State
///

abstract class DrawerBlocEvent extends Equatable {
  const DrawerBlocEvent();

  @override
  List<Object> get props => [];
}

class DrawerInitialize extends DrawerBlocEvent{
  final StringModel stringModel;

  DrawerInitialize(this.stringModel);

  @override
  List<Object> get props => [stringModel];
}

class Logout extends DrawerBlocEvent{}
///
///Event
///

abstract class DrawerBlocState extends Equatable {
  const DrawerBlocState();

  @override
  List<Object> get props => [];
}

class DrawerBlocStateUnInitialized extends DrawerBlocState{}
class DrawerBlocStateInitialized extends DrawerBlocState{
  final StringModel stringModel;

  DrawerBlocStateInitialized({this.stringModel});

  @override
  List<Object> get props => [stringModel];
}
///
/// Bloc
///

class DrawerBloc extends Bloc<DrawerBlocEvent,DrawerBlocState>{
  final HttpClient httpClient;

  DrawerBloc({this.httpClient}) : super(DrawerBlocStateUnInitialized());

  @override
  Stream<DrawerBlocState> mapEventToState(DrawerBlocEvent event) async* {

    if(event is DrawerInitialize){
      if(event.stringModel.user == null){
        final response = await httpClient.authRequest(new Request('GET', Uri.parse(HttpClient.baseURI + '/1/user/-/profile.json')));
        event.stringModel.user = response.body;
      }
      yield DrawerBlocStateInitialized(stringModel: event.stringModel);
    }

  }

}