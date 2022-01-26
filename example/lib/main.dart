import 'package:flutter/material.dart';
import 'package:value_notifier/value_notifier.dart';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class TextController {
  final rawA = ValueNotifier(1);
  late final aString = rawA.map((e) => e.toString());
  late final aText = aString.view().map(Text.new);
  final b = TextEditingController(text: 'b');
  late final bString = b.view().map((e) => e.text);
  final rawC = ValueNotifier(2.0);
  late final cString = rawC.map((e) => e.toString());
  late final cText = cString.map(Text.new);
  late final cSlider = TextController.instance.rawC.view().map(
        (e) => Slider(
          value: e,
          min: 0,
          max: 3,
          onChanged: (v) => TextController.instance.rawC.value = v,
        ),
      );
  late final c =
      rawC.view().map((e) => e * -1).map((e) => e.toStringAsFixed(2));
  late final text = aString.view().bind(
      (a) => bString.view().bind((b) => c.view().map((c) => '$a, $b, $c')));
  late final textWidget = text.map(Text.new);
  static final instance = TextController();
  void incrementA() => rawA.value = rawA.value + 1;
  void decrementA() => rawA.value = rawA.value - 1;
  void dispose() {
    aString.dispose();
    b.dispose();
    rawC.dispose();
    bString.dispose();
    c.dispose();
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextController.instance.textWidget.build(),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: TextController.instance.incrementA,
                    child: Text('+'),
                  ),
                  TextController.instance.aText.build(),
                  TextButton(
                    onPressed: TextController.instance.decrementA,
                    child: Text('-'),
                  ),
                ],
              ),
              Text('C:'),
              TextController.instance.cText.build(),
              TextController.instance.cSlider.build(),
            ],
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
