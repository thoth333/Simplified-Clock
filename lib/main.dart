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

// SimplifyButton
class SimplifyButton extends StatefulWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onSelectionChanged;

  const SimplifyButton({
    super.key,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  State<SimplifyButton> createState() => _SimplifyButtonState();
}

class _SimplifyButtonState extends State<SimplifyButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment(
            value: 'A',
            label: Text(
              '通常',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ButtonSegment(
            value: 'B',
            label: Text(
              '約分',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ButtonSegment(
            value: 'C',
            label: Text(
              '小数',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        selected: widget.selected,
        onSelectionChanged: widget.onSelectionChanged,
        showSelectedIcon: false,
        style: ButtonStyle(
          visualDensity: VisualDensity(horizontal: 2, vertical: 2),
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: bgBlack, // 線の色
              width: 2, // 線の太さ（ここを調整）
            ),
          ),
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
  final List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  Set<String> selected = {'A'};

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

  @override
  Widget build(BuildContext context) {
    final Widget clock;
    if (selected.contains('A')) {
      clock = Column(
        children: <Widget>[
          Text(
            '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 100),
          ),
          Text(
            '${_now.month.toString().padLeft(2, '0')}/${_now.day.toString().padLeft(2, '0')} ${weekdays[_now.weekday - 1]}',
            style: TextStyle(fontSize: 30),
          ),
        ],
      );
    } else if (selected.contains('B')) {
      int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
      int reducedHour = _now.hour ~/ gcd(_now.hour, _now.minute);
      int reducedMin = _now.minute ~/ gcd(_now.hour, _now.minute);
      int reducedMonth = _now.month ~/ gcd(_now.month, _now.day);
      int reducedDay = _now.day ~/ gcd(_now.month, _now.day);
      clock = Column(
        children: <Widget>[
          Text(
            _now.minute == 0
                ? '∞'
                : '${reducedHour.toString().padLeft(2, '0')}:${reducedMin.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 100),
          ),
          Text(
            _now.day == 0
                ? '∞'
                : '${reducedMonth.toString().padLeft(2, '0')}/${reducedDay.toString().padLeft(2, '0')} ${weekdays[_now.weekday - 1]}',
            style: TextStyle(fontSize: 30),
          ),
        ],
      );
    } else {
      double decimalTime = _now.minute == 0 ? 0 : _now.hour / _now.minute;
      double decimalDate = _now.day == 0 ? 0 : _now.month / _now.day;
      // 必要な桁数だけ表示させる関数
      String formatDecimal(double value) {
        if (value == value.toInt()) {
          return value.toInt().toString();
        }
        String oneDigit = value.toStringAsFixed(1);
        String twoDigit = value.toStringAsFixed(2);
        if (double.parse(oneDigit) == value) {
          return oneDigit;
        }
        return twoDigit;
      }

      clock = Column(
        children: <Widget>[
          Text(
            _now.minute == 0 ? '∞' : formatDecimal(decimalTime),
            style: TextStyle(fontSize: 100),
          ),
          Text(
            _now.day == 0
                ? '∞'
                : '${_now.day == 0 ? '∞' : formatDecimal(decimalDate)} ${weekdays[_now.weekday - 1]}',
            style: TextStyle(fontSize: 30),
          ),
        ],
      );
    }

    return Scaffold(
      body: Container(
        color: bgWhite,
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(flex: 4),
              clock,
              Spacer(flex: 1),
              SimplifyButton(
                selected: selected,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    selected = newSelection;
                  });
                },
              ),
              Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
