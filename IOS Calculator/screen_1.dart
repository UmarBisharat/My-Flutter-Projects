import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:practice/componetns/my_buttons.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  var userInput = '';
  var answer = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 300),
                        child: Text(
                          userInput.toString(),
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        answer.toString(),
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        MyButton(
                          title: 'AC',
                          onPress: () {
                            userInput = '';
                            answer = '';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '+/-',
                          onPress: () {
                            userInput += '+/-';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '%',
                          onPress: () {
                            userInput += '%';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '/',
                          color: Color(0xffffa00a),
                          onPress: () {
                            userInput += '/';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        MyButton(
                          title: '7',
                          onPress: () {
                            userInput += '7';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '8',
                          onPress: () {
                            userInput += '8';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '9',
                          onPress: () {
                            userInput += '9';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: 'x',
                          color: Color(0xffffa00a),
                          onPress: () {
                            userInput += 'x';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        MyButton(
                          title: '4',
                          onPress: () {
                            userInput += '4';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '5',
                          onPress: () {
                            userInput += '5';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '6',
                          onPress: () {
                            userInput += '6';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '-',
                          color: Color(0xffffa00a),
                          onPress: () {
                            userInput += '-';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        MyButton(
                          title: '1',
                          onPress: () {
                            userInput += '1';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '2',
                          onPress: () {
                            userInput += '2';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '3',
                          onPress: () {
                            userInput += '3';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '+',
                          color: Color(0xffffa00a),
                          onPress: () {
                            userInput += '+';
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        MyButton(
                          title: '0',
                          onPress: () {
                            userInput += '0';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '.',
                          onPress: () {
                            userInput += '.';
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: 'DEL',
                          onPress: () {
                            userInput = userInput.substring(
                              0,
                              userInput.length - 1,
                            );
                            setState(() {});
                          },
                        ),
                        SizedBox(width: 10),
                        MyButton(
                          title: '=',
                          color: Color(0xffffa00a),
                          onPress: () {
                            equalPress();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void equalPress() {
    // Replace x and % to be understood by math_expressions
    String finalInput = userInput.replaceAll('x', '*').replaceAll('%', '/100');

    Parser p = Parser(); // Create parser
    try {
      Expression expression = p.parse(finalInput);
      ContextModel contextModel = ContextModel();
      double eval = expression.evaluate(EvaluationType.REAL, contextModel);
      answer = eval.toString();
    } catch (e) {
      answer = 'Error'; // If parsing fails
    }
  }
}
