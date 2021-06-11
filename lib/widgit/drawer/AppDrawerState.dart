import 'package:dart_json_path/dart_json_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/auth/authentication_bloc.dart';
import 'package:smartsleep/auth/authentication_event.dart';
import 'package:smartsleep/widgit/drawer/AppDrawerBloc.dart';
import 'package:smartsleep/widgit/drawer/DarkModeSwitchState.dart';

class AppDrawerView extends StatefulWidget {
  AppDrawerView({Key key}) : super(key: key);

  @override
  _AppDrawer createState() => _AppDrawer();
}


class _AppDrawer extends State<AppDrawerView>{

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawerBloc,DrawerBlocState>(
        builder: (context,state){
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                profilePic(context,state),
                DarkModeSwitchView(),
                logout(context)
              ],
            ),
          );
        },
      );
  }

  Widget profilePic(BuildContext context,DrawerBlocState state) {
    if(state is DrawerBlocStateInitialized){
      return DrawerHeader(
          child: CircleAvatar(
              child: Image.network(JsonPath.getInsatnce().read(state.stringModel.user, "\$.user.avatar150"))
          )
      );
    }
    return ListTile(
      title: LinearProgressIndicator(value: null,),
    );
  }

  Widget logout(BuildContext context){
    return ListTile(
      title: Text('Logout',textAlign: TextAlign.center,),
      onTap: () {
        BlocProvider.of<AuthenticationBloc>(context)..add(LoggedOut());
      },
    );
  }

}