# AnimatedTo AI Code Generation Guide

This guide helps AI systems generate correct code patterns for the `animated_to` Flutter package. AnimatedTo enables widgets to automatically animate to new positions when their layout changes, requiring no manual calculation.

## Package Overview

**Core Concept**: AnimatedTo automatically animates widgets to new positions when rebuilds cause layout changes. The animation is handled by the RenderObject system, requiring only a GlobalKey to track the widget.

**Key Features**:
- Automatic position animation on layout changes
- Two animation types: curve-based and spring-based
- No manual position calculations required
- Hit testing support during animation
- ScrollView integration

## Essential Import Statement

```dart
import 'package:animated_to/animated_to.dart';
```

## Quick Decision Matrix

| Use Case | Animation Type | Key Requirements |
|----------|---------------|------------------|
| Simple position changes | `AnimatedTo.curve` | GlobalKey |
| Natural, physics-based motion | `AnimatedTo.spring` | GlobalKey |
| Gesture interaction during animation | Either + `AnimatedToBoundary` | GlobalKey, Container wrapper |
| Inside ScrollView | Either + scroll controllers | GlobalKey, ScrollController |
| Appearing from specific position in the first frame | Either + `appearingFrom`/`slidingFrom` | GlobalKey, Offset |

## Code Generation Templates

### 1. Basic Position Animation

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _isLeft = true;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _isLeft = !_isLeft),
        child: Align(
          alignment: _isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: AnimatedTo.curve(
            globalKey: _key,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2. Spring Animation

```dart
class SpringWidget extends StatefulWidget {
  @override
  State<SpringWidget> createState() => _SpringWidgetState();
}

class _SpringWidgetState extends State<SpringWidget> {
  bool _moved = false;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => setState(() => _moved = !_moved),
        child: Align(
          alignment: _moved ? Alignment.topRight : Alignment.bottomLeft,
          child: AnimatedTo.spring(
            globalKey: _key,
            // Optional: Use motor package for predefined springs
            // description: CupertinoMotion.smooth().description,
            // Or, you can manually build SpringDescription
            // description: SpringDescription(
            //   mass: 1.0,
            //   stiffness: 500.0,
            //   damping: 25.0,
            // ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3. Hit Testing with AnimatedToBoundary

```dart
class InteractiveWidget extends StatefulWidget {
  @override
  State<InteractiveWidget> createState() => _InteractiveWidgetState();
}

class _InteractiveWidgetState extends State<InteractiveWidget> {
  int _tapCount = 0;
  bool _moved = false;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(  // Required for hit testing during animation
      child: Scaffold(
        body: Align(
          alignment: _moved ? Alignment.topCenter : Alignment.bottomCenter,
          child: AnimatedTo.spring(
            globalKey: _key,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tapCount++;
                  _moved = !_moved;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: Center(
                  child: Text('$_tapCount'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4. ScrollView Integration

```dart
class ScrollableAnimatedWidget extends StatefulWidget {
  @override
  State<ScrollableAnimatedWidget> createState() => _ScrollableAnimatedWidgetState();
}

class _ScrollableAnimatedWidgetState extends State<ScrollableAnimatedWidget> {
  final _scrollController = ScrollController();
  bool _isLeft = true;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedToBoundary(
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(height: 100),
              SizedBox(
                height: 1000,
                child: GestureDetector(
                  onTap: () => setState(() => _isLeft = !_isLeft),
                  child: Align(
                    alignment: _isLeft ? Alignment.centerLeft : Alignment.centerRight,
                    child: AnimatedTo.curve(
                      globalKey: _key,
                      verticalController: _scrollController,  // Required for vertical scroll
                      // horizontalController: _scrollController,  // Use for horizontal scroll
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. ListView Usage (Limited Support)

```dart
class ListViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        // DO NOT provide ScrollController for ListView
        itemCount: 20,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(8.0),
          child: AnimatedTo.spring( // AnimatedTo works as long as animating inside each Sliver
            globalKey: GlobalObjectKey('item-$index'),
            slidingFrom: Offset(200, 0),  // Slide in from right
            child: ListTile(
              title: Text('Item $index'),
              tileColor: Colors.grey[200],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 6. Appearing/Sliding Animations

```dart
class AppearingWidget extends StatefulWidget {
  @override
  State<AppearingWidget> createState() => _AppearingWidgetState();
}

class _AppearingWidgetState extends State<AppearingWidget> {
  bool _show = false;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => setState(() => _show = !_show),
            child: Text('Toggle'),
          ),
          if (_show)
            AnimatedTo.curve(
              globalKey: _key,
              // Don't specify appearingFrom and slidingFrom at the same time
              // appearingFrom: Offset(100, 100),  // Absolute position
              slidingFrom: Offset(0, -50),  // Relative to final position
              child: Container(
                width: 100,
                height: 100,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}
```

### 7. Drag and Drop with Velocity

```dart
class DraggableWidget extends StatefulWidget {
  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  Offset _position = Offset(100, 100);
  Offset? _velocity;
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanEnd: (details) {
                setState(() {
                  _velocity = details.velocity.pixelsPerSecond;
                  _position = Offset(200, 200);  // New target position
                });
              },
              child: AnimatedTo.spring(
                globalKey: _key,
                velocityBuilder: _velocity != null ? () => _velocity! : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### AnimatedTo.curve Parameters

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `globalKey` | `GlobalKey` | ✅ | Keeps widget alive during position changes | `GlobalKey()` or `GlobalObjectKey('id')` |
| `child` | `Widget?` | ❌ | Widget to animate | `Container(...)` |
| `duration` | `Duration` | ❌ | Animation duration | `Duration(milliseconds: 300)` |
| `curve` | `Curve` | ❌ | Animation curve | `Curves.easeInOut` |
| `appearingFrom` | `Offset?` | ❌ | Absolute start position (global coordinates) | `Offset(100, 200)` |
| `slidingFrom` | `Offset?` | ❌ | Relative start position | `Offset(0, -50)` |
| `enabled` | `bool` | ❌ | Enable/disable animation | `true` (default) |
| `onEnd` | `Function?` | ❌ | Callback when animation ends | `(cause) => print(cause)` |
| `verticalController` | `ScrollController?` | ❌ | For vertical SingleChildScrollView | `_scrollController` |
| `horizontalController` | `ScrollController?` | ❌ | For horizontal SingleChildScrollView | `_scrollController` |
| `sizeWidget` | `Widget?` | ❌ | Widget for size calculation during size animations | `SizedBox(width: 100, height: 100)` |

### AnimatedTo.spring Parameters

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `globalKey` | `GlobalKey` | ✅ | Keeps widget alive during position changes | `GlobalKey()` |
| `child` | `Widget?` | ❌ | Widget to animate | `Container(...)` |
| `description` | `SpringDescription?` | ❌ | Spring physics configuration | `SpringDescription(mass: 1, stiffness: 100, damping: 10)` |
| `velocityBuilder` | `Offset Function()?` | ❌ | Initial velocity provider | `() => Offset(100, 0)` |
| `appearingFrom` | `Offset?` | ❌ | Absolute start position | `Offset(100, 200)` |
| `slidingFrom` | `Offset?` | ❌ | Relative start position | `Offset(0, -50)` |
| `enabled` | `bool` | ❌ | Enable/disable animation | `true` (default) |
| `onEnd` | `Function?` | ❌ | Callback when animation ends | `(cause) => print(cause)` |
| `verticalController` | `ScrollController?` | ❌ | For vertical SingleChildScrollView | `_scrollController` |
| `horizontalController` | `ScrollController?` | ❌ | For horizontal SingleChildScrollView | `_scrollController` |
| `sizeWidget` | `Widget?` | ❌ | Widget for size calculation | `SizedBox(width: 100, height: 100)` |

### AnimatedToBoundary

```dart
AnimatedToBoundary(
  child: MaterialApp(
    home: YourWidget(),
  ),
)
```

**Purpose**: Enables hit testing for AnimatedTo widgets during animation and isolates navigation transition effects.

**Placement**: 
- Near app root for global hit testing
- Around individual pages to isolate navigation transitions
- Can be nested

## Common Patterns

### GlobalKey Management

```dart
// For single widgets
final _key = GlobalKey();

// For dynamic lists - use unique identifiers
final _keys = <String, GlobalKey>{};
GlobalKey _getKey(String id) => _keys.putIfAbsent(id, () => GlobalKey());

// For known items with IDs
GlobalObjectKey(anKnownItem.id)
```

### State Management Integration

You can use any state management packages as long as it causes rebuild.

```dart
// With setState
onTap: () => setState(() => _position = newPosition),
```

### Animation Chaining

```dart
AnimatedTo.curve(
  globalKey: _key,
  onEnd: (cause) {
    if (cause == AnimationEndCause.completed) {
      // Start next animation
      setState(() => _nextPosition = true);
    }
  },
  child: Container(...),
)
```

## Common Mistakes and Solutions

### ❌ Using default constructor
```dart
// WRONG - default constructor
AnimatedTo(
  globalKey: _key,
  child: Container(...),
)
```

```dart
// CORRECT - AnimatedTo.spring / AnimatedTo.curve
AnimatedTo.curve(
  globalKey: _key,
  child: Container(...),
)
```

### ❌ Missing GlobalKey
```dart
// WRONG - No GlobalKey
AnimatedTo.curve(
  child: Container(...),
)
```

```dart
// CORRECT - Always provide GlobalKey
AnimatedTo.curve(
  globalKey: GlobalKey(),
  child: Container(...),
)
```

### ❌ Reusing GlobalKey
```dart
// WRONG - Same key for different widgets
final _sharedKey = GlobalKey();
AnimatedTo.curve(globalKey: _sharedKey, child: Widget1()),
AnimatedTo.curve(globalKey: _sharedKey, child: Widget2()),
```

```dart
// CORRECT - Unique keys for each widget
final _key1 = GlobalKey();
final _key2 = GlobalKey();
AnimatedTo.curve(globalKey: _key1, child: Widget1()),
AnimatedTo.curve(globalKey: _key2, child: Widget2()),
```

### ❌ ScrollController with ListView
```dart
// WRONG - Don't provide ScrollController for ListView
ListView.builder(
  controller: _controller,
  itemBuilder: (context, index) => AnimatedTo.curve(
    globalKey: GlobalObjectKey(index),
    verticalController: _controller,  // Don't do this
    child: ListTile(...),
  ),
)
```

```dart
// CORRECT - No ScrollController for ListView
ListView.builder(
  itemBuilder: (context, index) => AnimatedTo.curve(
    globalKey: GlobalObjectKey(index),
    // No controller needed
    child: ListTile(...),
  ),
)
```

### ❌ Missing AnimatedToBoundary for Hit Testing
```dart
// WRONG - Can't tap during animation
Scaffold(
  body: AnimatedTo.curve(
    globalKey: _key,
    child: GestureDetector(
      onTap: () => print('tapped'),
      child: Container(...),
    ),
  ),
)
```

```dart
// CORRECT - Wrap with AnimatedToBoundary
AnimatedToBoundary(
  child: Scaffold(
    body: AnimatedTo.curve(
      globalKey: _key,
      child: GestureDetector(
        onTap: () => print('tapped'),
        child: Container(...),
      ),
    ),
  ),
)
```

### ❌ Incorrect ScrollController Usage
```dart
// WRONG - Using wrong controller direction
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  controller: _controller,
  child: AnimatedTo.curve(
    globalKey: _key,
    verticalController: _controller,  // Should be horizontalController
    child: Container(...),
  ),
)
```

```dart
// CORRECT - Match controller direction
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  controller: _controller,
  child: AnimatedTo.curve(
    globalKey: _key,
    horizontalController: _controller,  // Correct direction
    child: Container(...),
  ),
)
```

### ❌ Switching Between Different Layout Widgets
```dart
// WRONG - Switching between GridView and ListView breaks AnimatedTo
class GridDemo extends StatefulWidget {
  @override
  State<GridDemo> createState() => _GridDemoState();
}

class _GridDemoState extends State<GridDemo> {
  bool _isGrid = true;
  final _keys = List.generate(6, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isGrid ? _buildGrid() : _buildList(),  // Different parent widgets
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(6, (index) => _buildItem(index)),
    );
  }

  Widget _buildList() {
    return ListView(
      children: List.generate(6, (index) => _buildItem(index)),
    );
  }

  Widget _buildItem(int index) {
    return AnimatedTo.spring(
      globalKey: _keys[index],
      child: Container(...),
    );
  }
}
```

```dart
// CORRECT - Use consistent layout widget (Wrap) that changes properties
class GridDemo extends StatefulWidget {
  @override
  State<GridDemo> createState() => _GridDemoState();
}

class _GridDemoState extends State<GridDemo> {
  bool _isGrid = true;
  final _keys = List.generate(6, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(  // Single consistent parent
                spacing: 16,
                runSpacing: 16,
                children: List.generate(6, (index) => _buildItem(index, constraints)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index, BoxConstraints constraints) {
    // Calculate width dynamically for grid/list
    final double itemWidth = _isGrid
        ? (constraints.maxWidth - 16) / 2  // Grid: 2 columns
        : constraints.maxWidth;            // List: full width

    return AnimatedTo.spring(
      globalKey: _keys[index],
      child: Container(
        width: itemWidth,
        height: _isGrid ? itemWidth : 100,
        color: Colors.primaries[index % Colors.primaries.length],
      ),
    );
  }
}
```

**Why this happens**: Switching between completely different parent widgets (GridView ↔ ListView) creates new widget tree structures. Even with GlobalKeys, AnimatedTo can't track position changes across different parent widget types because the layout context changes entirely.

**Solution**: Use a single consistent layout widget (like `Wrap`, `Stack`, or custom layout) that remains the same while its children's positions change based on state.

## ListView/ScrollView Limitations

- ✅ **Works**: Animation within a single sliver/viewport
- ❌ **Doesn't work**: Animation across different slivers
- ✅ **Use**: `SingleChildScrollView` with proper controllers
- ❌ **Avoid**: Providing `ScrollController` to `ListView`

## Hit Testing Requirements

- **Without AnimatedToBoundary**: Hit testing only works at layout position
- **With AnimatedToBoundary**: Hit testing works at animated position
- **Placement**: Near root for global coverage, or around specific pages
- **Nesting**: AnimatedToBoundary can be nested safely

## Motor Package Integration

For enhanced spring animations, use the `motor` package (already included in the animated_to package, but you have to install and directly depend on it if you want to use):

```dart
import 'package:motor/motor.dart';

AnimatedTo.spring(
  globalKey: _key,
  description: CupertinoMotion.smooth().description,
  // or CupertinoMotion.bouncy().description
  // or CupertinoMotion.snappy().description
  child: Container(...),
)
```

## Code Generation Checklist

When generating AnimatedTo code, ensure:

- [ ] `GlobalKey` is provided and unique
- [ ] Import statement is included
- [ ] `AnimatedToBoundary` is used when hit testing is needed
- [ ] Correct `ScrollController` direction for `SingleChildScrollView`
- [ ] No `ScrollController` for `ListView`
- [ ] `appearingFrom` uses absolute coordinates
- [ ] `slidingFrom` uses relative coordinates
- [ ] State management triggers rebuilds thazt change widget position
