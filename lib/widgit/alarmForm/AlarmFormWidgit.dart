import 'package:flutter/material.dart';
import 'package:smartsleep/model/Device.dart';
import 'package:smartsleep/model/NativeAlarms.dart';
import 'package:smartsleep/model/StringModel.dart';
import 'package:smartsleep/utils/TimeUtils.dart';
import 'package:smartsleep/widgit/alarmForm/WeekDays.dart';

class AlarmFormWidget extends StatefulWidget {
  AlarmFormWidget({Key key, this.alarm, this.selectedDevice,this.createAlarm}) : super(key: key);

  final Device selectedDevice;
  final NativeAlarms alarm;
  final bool createAlarm;

  @override
  _AlarmFormState createState() => _AlarmFormState();
}

class _AlarmFormState extends State<AlarmFormWidget> {
  WeekDayWidget weekDayArray;
  String title;

  @override
  void initState() {
    super.initState();
    if(widget.alarm.recurring){ //True
      weekDayArray = WeekDayWidget(days: widget.alarm.weekDays);
    }else{
      weekDayArray = WeekDayWidget();
    }

    if(widget.createAlarm){// Alarm created from FAB
      title = 'Create Alarm';
    }else{// Alarm being edited
      title = 'Edit Alarm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            onPressed: () => _saveAlarm(context),
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Turn Alarm On'),
            trailing: Switch(
              onChanged: (enable) {
                setState(() {
                  widget.alarm.enabled = enable;
                });
              },
              value: widget.alarm.enabled,
            ),
          ),
          ListTile(
            title: Text('Set Time'),
            trailing: Text(TimeUtils.get12HrFormatedTime(widget.alarm)),
            onTap: () {
              _getTimePicker(context, widget.alarm);
            },
          ),
          ListTile(
            title: Text('Repeats'),
            trailing: Switch(
              onChanged: (enable) {
                setState(() {
                  widget.alarm.recurring = enable;
                  if(DateTime.now().weekday==7){
                    weekDayArray.enable[6]=enable;
                  }else{
                    weekDayArray.enable[DateTime.now().weekday-1]=enable;
                  }
                });
              },
              value: widget.alarm.recurring,
            ),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: widget.alarm.recurring,
            child: ListTile(
              //title: Text('Repeats'),
              title: Center(child: weekdayDrawer()),
            ),
          ),
          ListTile(
            title: Text('Sync to Device'),
            trailing: Switch(
              onChanged: (enable) {
                setState(() {
                  widget.alarm.isSynced = enable;
                });
              },
              value: widget.alarm.isSynced,
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !widget.createAlarm,
        child: FloatingActionButton(
          child: Icon(Icons.delete),
          onPressed: () => _deleteAlarm(context),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _saveAlarm(BuildContext context){
    if(widget.alarm.recurring){
      widget.alarm.weekDays = weekDayArray.getActiveDays();
    }else{
      widget.alarm.weekDays = [];
    }
    Navigator.pop(context,AlarmPayload(selectedDevice: widget.selectedDevice,alarm: widget.alarm,delete: false));
  }

  _deleteAlarm(BuildContext context){
    Navigator.pop(context,AlarmPayload(selectedDevice: widget.selectedDevice,alarm: widget.alarm, delete: true));
  }

  Future<void> _getTimePicker(BuildContext context, NativeAlarms alarm) async {
    TimeOfDay picked = await showTimePicker(
        context: context, initialTime: TimeUtils.getTimeOfDay(alarm));

    if (picked != null) {
      setState(() {
        widget.alarm.time = TimeUtils.getTimeFromTimeOfDay(picked);
      });
    }
  }

  Widget weekdayDrawer() {
    List<String> days = MaterialLocalizations.of(context).narrowWeekdays;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        commonButtonTheme(days[0], 6),
        commonButtonTheme(days[1], 0),
        commonButtonTheme(days[2], 1),
        commonButtonTheme(days[3], 2),
        commonButtonTheme(days[4], 3),
        commonButtonTheme(days[5], 4),
        commonButtonTheme(days[6], 5),
      ],
    );
  }

  Widget commonButtonTheme(String day,int index){
    return ButtonTheme(
      height: 36,
      minWidth: 36,
      child: RaisedButton(
        child: Text(
          day,
        ),
        onPressed: () {
          setState(() {
            weekDayArray.enable[index] = !weekDayArray.enable[index];
          });

          bool isRepeatCheck = true;
          for(int i=0; i<weekDayArray.enable.length;i++){
            if(weekDayArray.enable[i]==true){
              isRepeatCheck=false;
              break;
            }
          }

          setState(() {
            if(isRepeatCheck){
              widget.alarm.recurring = false;
            }
          });

        },
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(36.0),
            side: BorderSide(color: Colors.black)
        ),
        color: weekDayArray.enable[index] ? Theme.of(context).accentColor : Theme.of(context).canvasColor,
        highlightElevation: 2,
      ),
    );
  }
}
