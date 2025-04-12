// pubsec yaml file
// 
// name: calculator_app
// description: A simple Flutter calculator app.
// publish_to: 'none' 

// version: 1.0.0+1

// environment:
//   sdk: '>=3.0.0 <4.0.0'

// dependencies:
//   flutter:
//     sdk: flutter
//   math_expressions: ^2.4.0

// dev_dependencies:
//   flutter_test:
//     sdk: flutter

// flutter:
//   uses-material-design: true

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final TextEditingController _mainText = TextEditingController();

  final List<String> ops = [
    '1',
    '2',
    '3',
    '+',
    '4',
    '5',
    '6',
    '-',
    '7',
    '8',
    '9',
    '*',
    '0',
    '/',
    '←',
    '='
  ];

  final List<String> functions = [
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'toadd',
    'clear',
    'calculate',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF007F73),
        title: const Center(child: Text('Calculator')),
        elevation: 5,
      ),
      body: Center(
        child: Container(
          height: 550,
          width: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3FDFD),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(4, 4),
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _mainText,
                  readOnly: true,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: ops.length,
                  itemBuilder: (context, index) {
                    return CalcButton(
                      text: ops[index],
                      mainText: _mainText,
                      pressed: functions[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final TextEditingController mainText;
  final String pressed;

  const CalcButton({
    super.key,
    required this.text,
    required this.mainText,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (text == "=") return const Color(0xFF00C897);
      if (text == "←") return const Color(0xFFF24C4C);
      if (["+", "-", "*", "/"].contains(text)) return const Color(0xFF59C1BD);
      return Colors.white;
    }

    Color getTextColor() {
      if (text == "=" || text == "←" || ["+", "-", "*", "/"].contains(text)) {
        return Colors.white;
      }
      return Colors.black;
    }

    return ElevatedButton(
      onPressed: () {
        if (pressed == "toadd") {
          mainText.text = mainText.text + text;
        } else if (pressed == "clear") {
          if (mainText.text.isNotEmpty) {
            mainText.text =
                mainText.text.substring(0, mainText.text.length - 1);
          }
        } else if (pressed == "calculate") {
          try {
            Parser p = Parser();
            Expression exp = p.parse(mainText.text);
            ContextModel cm = ContextModel();
            double ans = exp.evaluate(EvaluationType.REAL, cm);
            mainText.text = ans.toString();
          } catch (e) {
            mainText.text = "Invalid Expression";
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: getColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(16),
        elevation: 6,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: getTextColor(),
        ),
      ),
    );
  }
}
