import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:animated_grid/animated_grid.dart';

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _keys = <int>[];
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
                title: Text('Example'),
                actions: [
                  IconButton(
                    key: Key('plus'),
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _keys.add(_count);
                        _count++;
                      });
                    },
                  ),
                ]
            ),
            backgroundColor: Colors.black,
            body: AnimatedGrid(
              keys: _keys,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 44,
              cellRowNum: 2,
              cellColNum: 2,
              sortOrder: SortOrder.topToBottom,
              scrollDirection: Axis.vertical,
              onPageChanged: (page) {
                print(page);
              },
              builder: (ctx, index, _) {
                return ExampleContent(
                  caption: '${_keys[index]}',
                  keyVal: _keys[index],
                  onDeleteAt: (key) {
                    setState(() {
                      _keys.remove(key);
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ExampleContent extends StatelessWidget {
  const ExampleContent({Key? key, this.caption, this.keyVal, this.onDeleteAt}) : super(key: key);

  final String? caption;
  final int? keyVal;
  final Function(int?)? onDeleteAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(caption!),
          FlatButton(
            key: Key(caption!),
            onPressed: () {
              print('deleted $caption');
              onDeleteAt!(keyVal);
            },
            child: Text('Delete $caption'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('add cell and delete cell', (tester) async {
    await tester.pumpWidget(ExampleApp());

    await tester.tap(find.byKey(Key('plus')));
    await tester.pump();
    await tester.tap(find.byKey(Key('plus')));
    await tester.pump();
    await tester.tap(find.byKey(Key('plus')));
    await tester.pump();
    await tester.tap(find.byKey(Key('plus')));
    await tester.pump();
    await tester.tap(find.byKey(Key('plus')));
    await tester.pump();

    final c0 = find.text('0');
    expect(c0, findsOneWidget);
    final c3 = find.text('3');
    expect(c3, findsOneWidget);
    // No.4 is on the next page.
    var c4 = find.text('4');
    expect(c4, findsNothing);

    FlatButton button = find.widgetWithText(FlatButton, 'Delete 1').evaluate().first.widget as FlatButton;
    button.onPressed!();
    await tester.pump();

    c4 = find.text('4');
    expect(c4, findsOneWidget);

  });
}
