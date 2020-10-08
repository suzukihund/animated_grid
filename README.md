# animated_grid

Animated grid view.
Currently, it is only available in page mode.
Scrolling to switch pages is not supported.

![OverView](https://github.com/suzukihund/animated_grid/blob/master/sample_gif/overview.gif?raw=true)

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:
```yaml
animated_grid:
```
In your library add the following import:

```dart
import 'package:animated_grid/animated_grid.dart';
```

Pass an array of key values that identify the elements of the grid. 
It animates the elements in this array as they change.
```dart
var _keys = [1, 2, 3];
AnimatedGrid(
    keys: _keys,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height - 44,
    cellRowNum: 2,
    cellColNum: 4,
    sortOrder: SortOrder.lightToLeft,
    scrollDirection: Axis.horizontal,
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
)
```
