import 'package:animated_grid/animated_grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _keys = <int>[];
  var _count = 0;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text('Example'), actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    _keys.add(_count);
                    _count++;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
              ),
            ]),
            backgroundColor: Colors.black,
            body: AnimatedGrid(
              keys: _keys,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 44,
              cellRowNum: 2,
              cellColNum: 4,
              pageController: _pageController,
              sortOrder: SortOrder.rightToLeft,
              scrollDirection: Axis.horizontal,
              onPageChanged: (page) {},
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
  const ExampleContent({Key key, this.caption, this.keyVal, this.onDeleteAt})
      : super(key: key);

  final String caption;
  final int keyVal;
  final Function(int) onDeleteAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Spacer(),
          Text(caption),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              onDeleteAt(keyVal);
            },
            child: Text('Delete'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
