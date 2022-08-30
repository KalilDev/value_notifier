import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:value_listenables/value_listenables.dart';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class TextController extends ControllerBase<TextController> {
  final rawA = ValueNotifier(1);
  ValueListenable<String> get aString => rawA.view().map((e) => e.toString());
  ValueListenable<Text> get aText => aString.map(Text.new);

  final b = TextEditingController(text: 'b');
  ValueListenable<String> get bString => b.view().map((e) => e.text);

  final rawC = ValueNotifier(2.0);
  ValueListenable<String> get cString => rawC.view().map((e) => e.toString());
  ValueListenable<Text> get cText => cString.map(Text.new);

  ValueListenable<Slider> get cSlider => rawC.view().map(
        (e) => Slider(
          value: e,
          min: 0,
          max: 3,
          onChanged: (v) => rawC.value = v,
        ),
      );

  ValueListenable<String> get c =>
      rawC.view().map((e) => e * -1).map((e) => e.toStringAsFixed(2));

  ValueListenable<String> get text => aString.view().bind(
      (a) => bString.view().bind((b) => c.view().map((c) => '$a, $b, $c')));
  ValueListenable<Text> get textWidget => text.map(Text.new);

  void incrementA() => rawA.value = rawA.value + 1;
  void decrementA() => rawA.value = rawA.value - 1;

  void init() {
    print("init");
    super.init();
  }

  void dispose() {
    print("dispose");
    b.dispose();
    rawC.dispose();
    super.dispose();
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
      body: ControllerInjectorBuilder<TextController>(
        factory: (context) => ControllerBase.create(() => TextController()),
        builder: (context, controller) => Body(
          controller: controller,
        ),
      ),
    );
  }
}

class Body extends ControllerWidget<TextController> {
  const Body({
    Key? key,
    required ControllerHandle<TextController> controller,
  }) : super(key: key, controller: controller);

  @override
  Widget build(ControllerContext<TextController> context) {
    return Column(
      children: [
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: controller.textWidget.build(),
        ),
        SizedBox(height: 16),
        TextField(
          controller: controller.b,
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
                    onPressed: controller.incrementA,
                    child: Text('+'),
                  ),
                  controller.aText.build(),
                  TextButton(
                    onPressed: controller.decrementA,
                    child: Text('-'),
                  ),
                ],
              ),
              Text('C:'),
              controller.cText.build(),
              controller.cSlider.build(),
            ],
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
