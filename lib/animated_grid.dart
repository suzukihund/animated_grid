library animated_grid;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Represents the order in which cells are placed in the grid
enum SortOrder {
  /// [1][2][3]
  /// [4][5]6]
  lightToLeft,
  /// [1][3][5]
  /// [2][4][6]
  topToBottom,
}

/// Provides a grid view with animation.
///
/// Pass [keys] that uniquely identifies the item to be placed in the grid.
/// Newly added [keys] appear with the animation and disappear with the animation when deleted
class AnimatedGrid extends StatefulWidget {
  AnimatedGrid({
    @required this.keys,
    @required this.builder,
    this.width,
    this.height,
    this.cellColNum = 4,
    this.cellRowNum = 2,
    this.perCellMargin = 3,
    this.sortOrder = SortOrder.lightToLeft,
    this.scrollDirection = Axis.horizontal,
    this.pageController,
    this.onPageChanged,
  });

  final List<Object> keys;
  final IndexedWidgetBuilder builder;
  final double width;
  final double height;
  final int cellRowNum;
  final int cellColNum;
  final double perCellMargin;
  final SortOrder sortOrder;
  final Axis scrollDirection;
  final Function(int) onPageChanged;
  final PageController pageController;

  @override
  _AnimatedGridState createState() => _AnimatedGridState();
}

class _AnimatedGridState extends State<AnimatedGrid> {
  PageController _pageController;
  final _dimensions = <Rect>[];
  int get cellNum => widget.cellRowNum * widget.cellColNum;
  var _prevLen = 0;

  @override
  void initState() {
    super.initState();

    if(widget.pageController == null)
      _pageController = PageController();
    else
      _pageController = widget.pageController;

    switch(widget.sortOrder) {
      case SortOrder.lightToLeft:
        _createDimensionLeftToRight();
        break;
      case SortOrder.topToBottom:
        _createDimensionTopToBottom();
        break;
    }
  }

  void _createDimensionLeftToRight() {
    final gridW = widget.width ?? MediaQuery.of(context).size.width;
    final gridH = widget.height ?? MediaQuery.of(context).size.height;
    final w = (gridW - widget.perCellMargin) / widget.cellColNum - widget.perCellMargin;
    final h = (gridH - widget.perCellMargin) / widget.cellRowNum - widget.perCellMargin;
    double xPos = widget.perCellMargin;
    double yPos = widget.perCellMargin;
    for(var y=0; y<widget.cellRowNum; y++) {
      for(var x=0; x<widget.cellColNum; x++) {
        _dimensions.add(Rect.fromLTWH(xPos, yPos, w, h));
        xPos += w + widget.perCellMargin;
      }
      xPos = widget.perCellMargin;
      yPos += h + widget.perCellMargin;
    }
  }

  void _createDimensionTopToBottom() {
    final gridW = widget.width ?? MediaQuery.of(context).size.width;
    final gridH = widget.height ?? MediaQuery.of(context).size.height;
    final w = (gridW - widget.perCellMargin) / widget.cellColNum - widget.perCellMargin;
    final h = (gridH - widget.perCellMargin) / widget.cellRowNum - widget.perCellMargin;
    double xPos = widget.perCellMargin;
    double yPos = widget.perCellMargin;
    for(var x=0; x<widget.cellColNum; x++) {
      for(var y=0; y<widget.cellRowNum; y++) {
        _dimensions.add(Rect.fromLTWH(xPos, yPos, w, h));
        yPos += h + widget.perCellMargin;
      }
      xPos += w + widget.perCellMargin;
      yPos = widget.perCellMargin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: widget.scrollDirection,
      controller: _pageController,
      onPageChanged: (page) {
        if(widget.onPageChanged != null)
          widget.onPageChanged(page);
      },
      itemBuilder: (ctx, index) {
        final st = index * cellNum;
        final ed = min(widget.keys.length, st + cellNum);
        final keys = widget.keys.sublist(st, ed);

        var _enableSlideIn = false;
        if(_prevLen != widget.keys.length) {
          _enableSlideIn = true;
        }
        _prevLen = widget.keys.length;

        return SizedBox.expand(
          child: Container(
            padding: EdgeInsets.only(left: widget.perCellMargin, top: widget.perCellMargin),
            child: PageGridBoard(dimensions: _dimensions, keys: keys, page: index, cellNum: cellNum, builder: widget.builder, enableSlideIn: _enableSlideIn,),
          ),
        );
      },
      itemCount: (widget.keys.length / cellNum).ceil(),
    );
  }
}

class PageGridBoard extends StatefulWidget {
  final List<Rect> dimensions;
  final List<Object> keys;
  final int page;
  final int cellNum;
  final IndexedWidgetBuilder builder;
  final bool enableSlideIn;

  const PageGridBoard({@required this.dimensions, @required this.keys, @required this.page, @required this.cellNum, @required this.builder, this.enableSlideIn});

  @override
  _PageGridBoardState createState() => _PageGridBoardState();
}

class _PageGridBoardState extends State<PageGridBoard> {
  final _cells = <Widget>[];
  final _cellKeys = <GlobalKey>[];
  final _currentCellsMap = <Object, Widget>{};

  @override
  Widget build(BuildContext context) {
    for(var i=0; i<widget.keys.length; i++) {
      if(!_currentCellsMap.containsKey(widget.keys[i])) {
        final child = widget.builder(context, widget.page * widget.cellNum + i);
        final cell = PositionedCell(
          key: GlobalKey(),
          allDimensions: widget.dimensions,
          targetKey: widget.keys[i],
          allKeys: widget.keys,
          child: child,
          enableSlideIn: widget.enableSlideIn,
          onDeleted: (key) {
            final cell = _currentCellsMap.remove(key);
            _cellKeys.remove(cell.key);
            _cells.remove(cell);
          },
        );
        _cells.add(cell);
        _cellKeys.add(cell.key);
        _currentCellsMap[widget.keys[i]] = cell;
      }
    }
    for(var k in _cellKeys) {
      if(k.currentState != null) {
        (k.currentState as _PositionedCellState).updateKeys(widget.keys);
      }
    }

    return Stack(
      children: _cells,
    );
  }
}

class PositionedCell extends StatefulWidget {
  final List<Rect> allDimensions;
  final Object targetKey;
  final List<Object> allKeys;
  final Widget child;
  final Function(Object) onDeleted;
  final bool enableSlideIn;

  const PositionedCell({Key key, @required this.allDimensions, this.targetKey, this.allKeys, this.child, this.onDeleted, this.enableSlideIn}) : super(key: key);

  @override
  _PositionedCellState createState() => _PositionedCellState(targetKey, allKeys);
}

class _PositionedCellState extends State<PositionedCell> with SingleTickerProviderStateMixin {
  _PositionedCellState(this._targetKey, this._allKeys);

  var _deleted = false;
  Rect _prevRect = Rect.zero;
  Object _targetKey;
  List<Object> _allKeys;

  AnimationController _animationController;
  Animation<Offset> _animation;

  Object get tagetKey => _targetKey;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {setState((){});});
    _animation = Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateKeys(List<Object> keys) {
    setState(() {
      _allKeys = keys;
    });
  }

  @override
  Widget build(BuildContext context) {
    Rect rect;
    for(var i=0; i<_allKeys.length; i++) {
      if(_allKeys[i] == _targetKey) {
        rect = widget.allDimensions[i];
        break;
      }
    }

    // deleted.
    if(rect == null) {
      rect = Rect.fromLTWH(_prevRect.left, -600, _prevRect.width, _prevRect.height);
      _deleted = true;
    } else {
      _prevRect = rect;
    }

    final child = widget.enableSlideIn ?
        SlideTransition(
          position: _animation,
          child: widget.child,
        ) : widget.child ;

    return AnimatedPositioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      duration: const Duration(milliseconds: 300),
      child: child,
      onEnd: () {
        if(_deleted)
          widget.onDeleted(widget.targetKey);
      },
    );
  }
}