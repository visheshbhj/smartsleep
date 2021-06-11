import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

///
/// Event
///

abstract class ThemeBlocEvent extends Equatable {
  const ThemeBlocEvent();

  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeBlocEvent {}
class ToggleEnable extends ThemeBlocEvent {}

class InitTheme extends ThemeBlocEvent {}

///
/// State
///

class ThemeBlocState extends Equatable {
  final ThemeData themeData;
  final bool darkEnable;
  const ThemeBlocState({this.themeData, this.darkEnable});

  @override
  List<Object> get props => [themeData];
}

///
/// Bloc
///

class ThemeBloc extends Bloc<ThemeBlocEvent, ThemeBlocState> {
  ThemeBloc() : super(ThemeBlocState(themeData: ThemeData.light(),darkEnable: false));

  @override
  Stream<ThemeBlocState> mapEventToState(ThemeBlocEvent event) async* {
    var settings = await Hive.openBox('settings');
    bool current = settings.get('theme.darkMode.enable', defaultValue: false);

    if (event is ToggleEnable) {
      settings.put('theme.darkMode.enable', !current);

      if (!current) {
        yield ThemeBlocState(themeData: ThemeData.dark(), darkEnable: true);
      } else {
        yield ThemeBlocState(themeData: ThemeData.light(), darkEnable: false);
      }
    }

    if (event is InitTheme) {
      if (current) {
        yield ThemeBlocState(themeData: ThemeData.dark(), darkEnable: true);
      } else {
        yield ThemeBlocState(themeData: ThemeData.light(), darkEnable: false);
      }
    }

    settings.close();
  }

}
