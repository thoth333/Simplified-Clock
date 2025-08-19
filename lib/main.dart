import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

const Color bgWhite = Color(0xFFEEEEEE);
const Color bgBlack = Color(0xFF3E3E3E);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: '約分時計'),
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP'), Locale('en', 'US')],
    );
  }
}

const List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// MySegmentedButton
class MySegmentedButton extends StatefulWidget {
  const MySegmentedButton({super.key});

  @override
  State<MySegmentedButton> createState() => _MySegmentedButtonState();
}

class _MySegmentedButtonState extends State<MySegmentedButton> {
  Set<String> selected = {'A'};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const <ButtonSegment<String>>[
        ButtonSegment(value: 'A', label: Text('通常')),
        ButtonSegment(value: 'B', label: Text('約分')),
        ButtonSegment(value: 'C', label: Text('小数')),
      ],
      selected: selected,
      onSelectionChanged: (newSelection) {
        setState(() {
          selected = newSelection;
        });
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return bgBlack; // 選択されたときの色
          }
          return bgWhite; // 非選択の色
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return bgWhite; // 選択中のテキスト色
          }
          return bgBlack; // 非選択のテキスト色
        }),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DateTime _now;
  late final StreamSubscription<DateTime> ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    ticker = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
        .listen((dateTime) {
          setState(() {
            _now = dateTime;
          });
        });
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFEEEEEE),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('現在時刻', style: TextStyle(fontSize: 24)),
              Text(
                '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bgWhite,
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 100),
              ),
              Text(
                '${_now.month.toString().padLeft(2, '0')}/${_now.day.toString().padLeft(2, '0')} ${weekdays[_now.weekday - 1]}',
                style: TextStyle(fontSize: 30),
              ),
              MySegmentedButton(),
            ],
          ),
        ),
      ),
    );
  }

  /*
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFEEEEEE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          */
}
