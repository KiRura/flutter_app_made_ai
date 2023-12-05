import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time), text: '世界時計'),
                Tab(icon: Icon(Icons.alarm), text: 'アラーム'),
                Tab(icon: Icon(Icons.timer), text: 'ウォッチ'),
                Tab(icon: Icon(Icons.hourglass_empty), text: 'タイマー'),
              ],
            ),
            title: const Text('時計アプリ'),
          ),
          body: const TabBarView(
            children: [
              WorldClockTab(),
              AlarmTab(),
              StopwatchTab(),
              TimerTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class WorldClockTab extends StatefulWidget {
  const WorldClockTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WorldClockTabState createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  late DateTime now;
  late String formattedDate;
  late DateTime utc;
  late String formattedUtc;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _getTime();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    if (mounted) {
      setState(() {
        now = DateTime.now();
        formattedDate = DateFormat('yyyy-MM-dd – kk:mm:ss').format(now);
        utc = DateTime.now().toUtc();
        formattedUtc = DateFormat('yyyy-MM-dd – kk:mm:ss').format(utc);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Card(
            child: ListTile(
              title: const Text(
                'ローカル時間',
                style: TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                formattedDate,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text(
                'UTC時間',
                style: TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                formattedUtc,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  AlarmTabState createState() => AlarmTabState();
}

class AlarmTabState extends State<AlarmTab> {
  TimeOfDay _time = TimeOfDay.now();
  Timer? _timer;

  void _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
      _setAlarm();
    }
  }

  void _setAlarm() {
    final DateTime now = DateTime.now();
    final DateTime alarmTime =
        DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    final Duration timeDifference = alarmTime.difference(now);

    _timer = Timer(timeDifference, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('アラーム'),
            content: const Text('設定した時間になりました。'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '選択された時間: ${_time.format(context)}',
            style: const TextStyle(fontSize: 30),
          ),
          ElevatedButton(
            onPressed: () {
              _selectTime(context);
            },
            child: const Text('時間を選択'),
          ),
        ],
      ),
    );
  }
}

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  StopwatchTabState createState() => StopwatchTabState();
}

class StopwatchTabState extends State<StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  final _stopwatchTicker =
      Stream<int>.periodic(const Duration(milliseconds: 1), (x) => x);
  String _stopwatchTime = "00:00:00";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<int>(
            stream: _stopwatchTicker,
            builder: (context, snapshot) {
              if (_stopwatch.isRunning) {
                _updateStopwatchTime();
              }
              return Text(
                _stopwatchTime,
                style: const TextStyle(fontSize: 30),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_stopwatch.isRunning) {
                  _stopwatch.stop();
                } else {
                  _stopwatch.start();
                }
              });
            },
            child: Text(_stopwatch.isRunning ? 'ストップ' : 'スタート'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _stopwatch.reset();
                _stopwatchTime = "00:00:00";
              });
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  void _updateStopwatchTime() {
    final milliseconds = _stopwatch.elapsedMilliseconds;
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');

    _stopwatchTime = "$minutesStr:$secondsStr:$hundredsStr";
  }
}

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  TimerTabState createState() => TimerTabState();
}

class TimerTabState extends State<TimerTab> {
  @override
  Widget build(BuildContext context) {
    // Your build implementation here
    return const Center(
        child: Text(
            'タイマー機能')); // Add a return statement at the end of the build method
  }
}

// const TimerTab({Key? key}) : super(key: key);

  // @override
  // TimerTabState createState() => TimerTabState();
// class TimerTabState extends State<TimerTab> {
//   Timer? _timer;
//   int _start = 0;
//   TimeOfDay pickedTime = TimeOfDay.now();

//   void startTimer() {
//     _timer?.cancel(); // 既存のタイマーをキャンセルする
//     _start = pickedTime.hour * 3600 + pickedTime.minute * 60;
//     _timer = Timer.periodic(
//       const Duration(seconds: 1),
//       (Timer timer) {
//         if (_start == 0) {
//           setState(() {
//             timer.cancel();
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('タイマー'),
//                   content: const Text('時間が経過しました。'),
//                   actions: <Widget>[
//                     TextButton(
//                       child: const Text('OK'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           });
//         } else {
//           setState(() {
//             _start--;
//           });
//         }
//       },
//     );
//   }

//   Future<void> selectTime(BuildContext context) async {
//     final TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialEntryMode: TimePickerEntryMode.inputOnly,
//       initialTime: pickedTime,
//       builder: (BuildContext context, Widget? child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//           child: child!,
//         );
//       },
//     );
//     if (time != null && time != pickedTime) {
//       setState(() {
//         pickedTime = time;
//         _start = pickedTime.hour * 3600 +
//             pickedTime.minute * 60; // 出している数字を選択された時間に変える
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text('$_start'),
//           ElevatedButton(
//             onPressed: () {
//               selectTime(context);
//             },
//             child: const Text('時間を選択'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               startTimer();
//             },
//             child: const Text('タイマーをスタート'),
//           ),
//         ],
//       ),
//     );
//   }
// }
