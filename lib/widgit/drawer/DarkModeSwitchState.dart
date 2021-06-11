import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/widgit/alarm_list/bloc/ThemeBloc.dart';

class DarkModeSwitchView extends StatefulWidget{
  @override
  DarkModeSwitchState createState() => DarkModeSwitchState();
}

class DarkModeSwitchState extends State<DarkModeSwitchView>{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeBlocState>(
        buildWhen: (previous, current) => previous.darkEnable != current.darkEnable,
        builder: (context, state) {
          return ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: state.darkEnable,
              onChanged: (value) {
                BlocProvider.of<ThemeBloc>(context).add(ToggleEnable());
              },
            ),
          );
        },
    );
  }

}