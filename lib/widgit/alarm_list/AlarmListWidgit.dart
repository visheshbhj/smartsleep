import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/model/NativeAlarms.dart';
import 'package:smartsleep/model/StringModel.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';
import 'package:smartsleep/utils/TimeUtils.dart';
import 'package:smartsleep/utils/db/AlarmRepository.dart';
import 'package:smartsleep/widgit/alarmForm/AlarmFormBloc.dart';
import 'package:smartsleep/widgit/alarmForm/AlarmFormWidgit.dart';
import 'package:smartsleep/widgit/alarm_list/bloc/AlarmListDevicesBloc.dart';
import 'package:smartsleep/widgit/alarm_list/bloc/FABBloc.dart';
import 'package:smartsleep/widgit/alarm_list/bloc/ThemeBloc.dart';
import 'package:smartsleep/widgit/drawer/AppDrawerBloc.dart';
import 'package:smartsleep/widgit/drawer/AppDrawerState.dart';
import 'package:smartsleep/widgit/loading.dart';

import 'bloc/AlarmListAlarmBloc.dart';

class AlarmListWidget extends StatelessWidget {
  final HttpClient httpClient;
  final StringModel stringModel;
  final AlarmRepository repository;

  AlarmListWidget({this.httpClient, this.stringModel})
      : repository = AlarmRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AlarmListDeviceBloc>(
            create: (context) =>
                AlarmListDeviceBloc(httpClient: this.httpClient)
                  ..add(LoadDevices()),
          ),
          BlocProvider(
            create: (context) => FABBloc(),
          ),
          BlocProvider<AlarmListAlarmBloc>(
            create: (context) => AlarmListAlarmBloc(
                httpClient: this.httpClient, repository: repository),
          ),
          BlocProvider<AlarmFormBloc>(
            create: (context) => AlarmFormBloc(
                httpClient: this.httpClient,
                alarmListAlarmBloc:
                    BlocProvider.of<AlarmListAlarmBloc>(context),
                repository: repository),
          ),
          BlocProvider<DrawerBloc>(
            create: (context) => DrawerBloc(httpClient: this.httpClient)
              ..add(DrawerInitialize(stringModel)),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc()..add(InitTheme()),
          )
        ],
        child: BlocBuilder<ThemeBloc, ThemeBlocState>(
          builder: (context, state) {
            return MaterialApp(
              theme: state.themeData,
              home: AlarmListView(),
            );
          },
        ));
  }
}

class AlarmListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarms'),
        centerTitle: true,
        actions: <Widget>[DevicesAppBar()],
      ),
      drawer: AppDrawerView(),
      body: AlarmsList(),
      floatingActionButton: FAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FAB extends StatefulWidget {
  @override
  FABState createState() => FABState();
}

class FABState extends State<FAB> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FABBloc, FABBlocState>(
      builder: (context, state) {
        if (state is FABNotInitialized) {
          return Visibility(
            visible: false,
            child: Container(),
          );
        }
        if (state is FABInitialized) {
          return FloatingActionButton(
            onPressed: () async {
              AlarmPayload payload = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AlarmFormWidget(
                          alarm: NativeAlarms(
                              time: TimeUtils.getTimeNow(),
                              enabled: true,
                              recurring: false,
                              weekDays: [],
                              isSynced: false,
                              isDifferentTime: false,
                              differentTime: TimeUtils.getTimeNow()),
                          selectedDevice: state.selectedDevice,
                          createAlarm: true,
                        )),
              );

              if (payload != null) {
                BlocProvider.of<AlarmFormBloc>(context).add(SaveAlarm(
                    alarm: payload.alarm,
                    selectedDevice: payload.selectedDevice,
                    createAlarm: true));
              }
            },
            tooltip: 'Create Alarm',
            child: Icon(Icons.alarm_add),
          );
        }
        return Container();
      },
    );
  }
}

class AlarmsList extends StatefulWidget {
  @override
  AlarmListState createState() => AlarmListState();
}

class AlarmListState extends State<AlarmsList> {
  Completer<void> refreshCompleter;

  @override
  void initState() {
    super.initState();
    refreshCompleter = Completer();
  }

  @override
  Widget build(BuildContext context) {
    _onAlarmTap(BuildContext context, AlarmListAlarmState state,
        NativeAlarms alarm, Device selectedDevice) async {
      NativeAlarms oldData = alarm;
      AlarmPayload payload = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AlarmFormWidget(
                    alarm: alarm,
                    selectedDevice: selectedDevice,
                    createAlarm: false,
                  )));

      if (payload != null) {
        if (payload.delete) {
          BlocProvider.of<AlarmFormBloc>(context)
              .add(DeleteAlarm(payload.selectedDevice, payload.alarm));
        } else {
          BlocProvider.of<AlarmFormBloc>(context).add(SaveAlarm(
              alarm: payload.alarm,
              selectedDevice: payload.selectedDevice,
              createAlarm: false,
              oldAlarm: oldData));
        }
      }
    }

    Widget getMinifiedWeekDays(NativeAlarms alarm) {
      String text;
      if (alarm.weekDays.isEmpty && alarm.recurring == false) {
        TimeOfDay day = TimeUtils.getTimeOfDay(alarm);
        DateTime current = new DateTime(DateTime.now().year,
            DateTime.now().month, DateTime.now().day, day.hour, day.minute);
        if (current.isAfter(DateTime.now())) {
          text = 'Today';
        }
        if (current.isBefore(DateTime.now())) {
          text = 'Tommorow';
        }
        //Check Today or Tommorow
      } else {
        // Check everyday or weekdays or weekends
        String weeks =
            alarm.weekDays.map((value) => value.substring(0, 3)).toString();
        text = weeks.substring(1, weeks.length - 1);
      }
      return Text(text);
    }

    Widget enableAlarmIcon(NativeAlarms alarm) {
      if (alarm.enabled) {
        return Icon(
          Icons.alarm_on,
        );
      } else {
        return Icon(
          Icons.alarm_off,
        );
      }
    }

    Future<void> onRefresh(Device selectedDevice) {
      BlocProvider.of<AlarmListAlarmBloc>(context)
          .add(LoadAlarms(selectedDevice: selectedDevice));
      return refreshCompleter.future;
    }

    return BlocListener<AlarmListAlarmBloc, AlarmListAlarmState>(
        listener: (context, state) {
      if (state is AlarmLoaded) {
        refreshCompleter?.complete();
        refreshCompleter = Completer();
      }
      if (state is AlarmFormNotificationState) {
        Flushbar(
          message: state.message,
          duration: Duration(seconds: 3),
        )..show(context);
      }
    }, child: BlocBuilder<AlarmListAlarmBloc, AlarmListAlarmState>(
      builder: (context, state) {
        if (state is AlarmListStateAlarmsUnInitialized) {
          return Center(
            child: Text('Loading Devices'),
          );
        }
        if (state is AlarmListStateAlarmsLoading) {
          return LoadingIndicator();
        }
        if (state is NoAlarmLoaded) {
          return Center(
            child: Text('No Alarms Found, Create an Alarm !'),
          );
        }
        if (state is AlarmLoaded) {
          return RefreshIndicator(
              onRefresh: () => onRefresh(state.selectedDevice),
              child: ListView.builder(
                itemCount: state.alarms.length,
                itemBuilder: (context, index) {
                  NativeAlarms alarm = state.alarms[index];
                  return ListTile(
                      title: Text(
                        TimeUtils.get12HrFormatedTime(alarm),
                      ),
                      leading: Icon(Icons.alarm),
                      subtitle: getMinifiedWeekDays(alarm),
                      trailing: enableAlarmIcon(alarm),
                      onTap: () => _onAlarmTap(
                          context, state, alarm, state.selectedDevice));
                },
              ));
        }
        return Container();
      },
    ));
  }
}

class DevicesAppBar extends StatefulWidget {
  @override
  DevicesAppBarState createState() => DevicesAppBarState();
}

class DevicesAppBarState extends State<DevicesAppBar> {
  Device selectedDevice;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmListDeviceBloc, AlarmListDeviceState>(
        listener: (context, state) {
      if (state is AlarmListStateDevices) {
        BlocProvider.of<FABBloc>(context).add(FABDevices(
            selectedDevice: state.devices[0], devices: state.devices));
        BlocProvider.of<AlarmListAlarmBloc>(context)
            .add(LoadAlarms(selectedDevice: state.devices[0]));
        setState(() {
          selectedDevice = state.devices[0];
        });
      }
    }, child: BlocBuilder<AlarmListDeviceBloc, AlarmListDeviceState>(
      builder: (context, state) {
        if (state is AlarmListStateAlarmsUnInitialized) {
          return DropdownButton<Device>(
            icon: Icon(Icons.arrow_downward),
            items: null,
            onChanged: null,
            disabledHint: Text("Loading Devices"),
            hint: Text("Loading Devices"),
          );
        }
        if (state is AlarmListStateDevices) {
          return DropdownButton<Device>(
            icon: Icon(Icons.arrow_downward),
            items: state.devices
                .map((device) => new DropdownMenuItem(
                      child: Text(device.deviceVersion),
                      value: device,
                    ))
                .toList(),
            hint: selectedDevice == null
                ? Text(state.devices[0].deviceVersion)
                : Text(selectedDevice.deviceVersion),
            onChanged: (device) {
              BlocProvider.of<AlarmListAlarmBloc>(context)
                  .add(LoadAlarms(selectedDevice: device));
              setState(() {
                selectedDevice = device;
              });
            },
          );
        }
        return Container();
      },
    ));
  }
}
