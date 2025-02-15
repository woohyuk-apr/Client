import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'addEvent.dart';
import 'model/ServerProp.dart';

import 'package:myapp/Properties.dart' as prop;

final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  Future<List<Schedule>> scheduleList;
  int flag=0;
  DateTime twinkle_day;

  @override
  void initState() {
    print(DateTime.now());
    super.initState();
    DateTime _selectedDay = DateTime.now();
    String ss = _selectedDay.toString().substring(0,10);
    _selectedDay = DateTime.parse(ss);
    twinkle_day=_selectedDay;
    scheduleList = fetchSchedule();


    _events = {
      /*_selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],*/
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events,List t) {
    print('CALLBACK: _onDaySelected');
    twinkle_day = day;
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xFFFD8183),
        shadowColor: Color(0xFFFB425A),
        title: Text("Calendar"),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh),
                onPressed: () => {
                  //fetchSchedule(),build(context)
                  setState(() {
                    scheduleList = fetchSchedule();
                    flag=0;
                  })
                },
            ),
            new IconButton(
              icon: new Icon(Icons.add),
              onPressed: () => {
                Navigator.push(context, MaterialPageRoute(builder: (context) => addEvent(twinkle_day)))
              },
            ),
          ]
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          //_buildTableCalendar(),
          _bb(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }
  Widget _bb(){
    if(flag==0) {
      flag=1;
      return FutureBuilder<List<Schedule>>(
          future: scheduleList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Schedule> posting = snapshot.data ?? [];
              if(_events.length!=0)_events.clear();//이유는 모르지만, 새로 고침 버튼을 연속 두번 눌렀을 때 이 메소드를 두번 들어가서 모든 이벤트가 두개씩 뜬다. 그래서 그걸 방지하기 위함.
              for (int i = 0; i < posting.length; i++) {
                if (_events.containsKey(posting[i].moment) == true) {
                  _events[posting[i].moment].add([posting[i].title,posting[i].description,posting[i].schedule_no]);
                }
                else {
                  List<List> temp_list = [];
                  List<Object> tmp_list2 = [];
                  tmp_list2.add(posting[i].title);
                  tmp_list2.add(posting[i].description);
                  tmp_list2.add(posting[i].schedule_no);
                  temp_list.add(tmp_list2);
                  _events.putIfAbsent(posting[i].moment, () => temp_list);
                  //List<String> temp_list = List<String>();
                  //temp_list.add(posting[i].title);
                  //_events.putIfAbsent(posting[i].moment, () => temp_list);
                }
              }
              //print(_events);
              //_events.keys.forEach((element) => print(element));
              return _buildTableCalendar();
            }
            else
              return CircularProgressIndicator();
          }
      );
    }
    else return _buildTableCalendar();
  }
  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      initialSelectedDay: twinkle_day,
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  /*Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pl_PL',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }*/

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date) ? Colors.brown[300] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    //final dateTime = _events.keys.elementAt(_events.length);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            ElevatedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            ElevatedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        /*RaisedButton(
          child: Text('Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),*/
      ],
    );
  }

  Widget _buildEventList() {

    return  ListView.builder(
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final item = _selectedEvents[index][0];
        return Dismissible(
          key: Key(item),
          direction: DismissDirection.startToEnd,
          child: ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text(_selectedEvents[index][0].toString()),
                content: new Text(_selectedEvents[index][1].toString()),
                actions: <Widget>[
                  new TextButton(
                    child: new Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                      },
                  ),
                ],
              );
              }
              ),
            title: Text(item),
            trailing: IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () {
                showDialog(context: context,builder : (BuildContext context){
                  return AlertDialog(
                    content:new Text("삭제하시겠습니까?"),
                    actions:<Widget>[
                      new TextButton(
                        child: new Text("예"),
                        onPressed: (){
                          setState(() {
                            //delete_list(_selectedEvents[index][2],twinkle_day,_selectedEvents[index][0],_selectedEvents[index][1]);
                            delete_list(_selectedEvents[index][2]);
                            _selectedEvents.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      new TextButton(
                        child: new Text("아니요"),
                        onPressed: (){
                          Navigator.pop(context);
                        }
                      )
                    ]
                  );
                });
              },
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _selectedEvents.removeAt(index);
            });
          },
        );
      },
    );
    /*ListView(
      children: _selectedEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event[0].toString()),
          onTap: () => /*print('$event tapped!'),*/showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text(event[0].toString()),
              content: new Text(event[1].toString()),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
        ),
      ))
          .toList(),
    );*/
  }

  void delete_list(int schedule_no){
    ServerProp serverProp=ServerProp();
    final msg = jsonEncode({'schedule_no':schedule_no});//jsonEncode({'moment':DateFormat('yyyy-MM-dd').format(date),'title':title,'description':description});
    http.post(Uri.parse(serverProp.server+'/schedule/deleteEvent'),headers:{'content-type':'application/json','Authorization': prop.token},body: msg);
  }
}
Future<List<Schedule>> fetchSchedule() async{
  ServerProp serverProp=ServerProp();
  final response = await http.get(Uri.parse(serverProp.server+'/schedule/all'),headers: {'Authorization':prop.token});//http.get('http://localhost:8080/schedule/all');
  if(response.statusCode==200){
    return ScheduleImpl().fromJson(json.decode(utf8.decode(response.bodyBytes)));
  }
  else{
    throw Exception('Failed to load post');
  }
}

class Schedule{
  final int schedule_no;
  final DateTime moment;
  final String title;
  final String description;

  Schedule({this.schedule_no,this.moment,this.title,this.description});
}
class ScheduleImpl{

  List<Schedule> fromJson(List<dynamic> json){
    List<Schedule> scheduleList = [];
    print(DateTime.parse(json[0]['moment'].toString().substring(0,10)));
    for(int i=0;i<json.length;i++){
      scheduleList.add(Schedule(schedule_no:json[i]['schedule_no'],moment:DateTime.parse(json[i]['moment'].toString().substring(0,10)),title: json[i]['title'],description: json[i]['description']));
    }
    return scheduleList;
  }
}