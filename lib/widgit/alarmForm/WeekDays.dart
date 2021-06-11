class WeekDayWidget{
  static final List<String> weekDays = ['MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'];
  List<bool> enable; //If True Means Selected

  WeekDayWidget({List<String> days}){
    if(days==null){
      enable = List.filled(7, false);
    }else{
      enable = List.filled(7, false);
      for( int i = 0; i<days.length;i++){
        int activate = weekDays.indexOf(days[i]);
        enable[activate] = true;
      }
    }
  }

  List<String> getActiveDays(){
    List<String> active = new List();
    for(int i =0; i<enable.length;i++){
      if(enable[i]) active.add(weekDays[i]);
    }
    return active;
  }

  static String getString(List<String> days){
    return days.toString().replaceAll('[','').replaceAll(']','').replaceAll(' ','');
  }

}