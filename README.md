# animated_to

animated_to provides a widget named `AnimatedTo` which enables its child widget **to change its position with animation** when its position is updated for any reason, typically for rebuilding.

![AnimatedTo Preview](https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to_1.gif)

No calculation is required. Because every calculation is `RenderObject`'s business in the Flutter framework, `AnimatedTo` just hires the calculated position and starts animation there.

## Usage

First, place whatever widget you want to animate when its position changes.

```dart
Container(
  width: 60,
  height: 60,
  color: Colors.blue,
)
```

Then, wrap the widget with `AnimatedTo.curve` or `AnimatedTo.spring` passing `GlobalKey`.

```dart
AnimatedTo.curve(
  globalKey: _globalKey,
  child: Container(
    width: 60,
    height: 60,
    color: Colors.blue,
  ),
)
```

Note that `GlobalKey` is necessary to keep its `RenderObject` alive even when the widget's depth or position changes.

And, that's it!

All what you need to do is causing rebuilds using whatever state management packages or just `setState` and change its position. `AnimatedTo` will automatically leads the `child` to the new position with animation.

## Spring animation

`animated_to` provides `AnimatedTo.spring` which animates its child using `SpringSimulation`.

https://api.flutter.dev/flutter/physics/SpringSimulation-class.html

This simulates its position transition based on the physical simulation, which make the animations smooth and natural.

What you have to do is just switch `AnimatedTo.curve` into `AnimatedTo.spring` to activate spring simulation. You can also configure your own `SpringDescription` using `description` argument, or you can use pre-defined configuration using [@timcreatedit](https://github.com/timcreatedit)'s `motor` package. 

https://pub.dev/packages/motor

```dart
AnimatedTo.spring(
  globalKey: _globalKey,
  // you can retrieve SpringDescription from CupertinoMotion like below
  description: CupertinoMotion.smooth().description,
),
```

As `motor` is also used inside `animated_to` package(thanks @timcreatedit!), make sure you may have potential risk of dependency conflicts when directly depending on the package on your app side.

![spring demo](https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to_4.gif)

## Some more features

`appearingFrom` lets you specify the start position of the animation in the first frame. By providing an absolute position in the global coordinate system, the widget will appear there and then animate to the original position.

![appearingFrom demo](https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to_2.gif)

`slidingFrom` lets you specify the start position of the animation in the first frame as well. By providing a relative position to the child's intrinsic position, the widget will slide from the specified position and then animate to the original position.

![slidingFrom demo](https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to_3.gif)

## Hit Testing

By default, `AnimatedTo` widgets can only receive gestures (taps, drags, etc.) at their **layout position**, not at their **animated position**. This is because Flutter's hit testing system checks widgets at their natural layout position, even though `AnimatedTo` visually paints them at a different location during animation.

### AnimatedToContainer

To enable gesture detection at the animated position, wrap your widget tree with `AnimatedToContainer`. This container intercepts hit tests and properly forwards them to animating widgets at their current animated positions.

```dart
void main() => runApp(
  AnimatedToContainer( // Place near root
    child: MaterialApp(
      home: MyHomePage(),
    ),
  ),
);
```

Note that `AnimatedToContainer` should be placed near the root of your widget tree to properly intercept hit tests for all descendant `AnimatedTo` widgets. In the example app, it wraps the entire `MaterialApp`.

`AnimatedToContainer` is optional. If you don't need to detect gestures on your `AnimatedTo` widgets during animation, you can omit it completely. The animations will work perfectly fine without it.

In addition, `AnimatedToContainer` has another usage to keep accurate animation during transition animation, typically caused by `Navigator.push()`.

Because the offset changes caused by navigation transition also affects the behavior of `AnimatedTo` by default, which results in unexpected animation you want to start before navigation transition ends, you can make `AnimatedTo` ignore the transition by wrapping the entire page widget, typically `Scaffold`, with `AnimatedToContainer`. 

```dart
@override
Widget build(BuildContext context) {
  return AnimatedToContainer(
    child: Scaffold(
      body: AnimatedTo.spring(
        globalKey: _key,
        slidingFrom: Offset(100, 100),
        child: _YourWidget(),
      ),
    ),
  )
}
```

Note that `AnimatedToContainer` can be nested, so you don't have to remove the other `AnimatedToContainer` you placed at the root of the widget tree.

## Limitations

- `AnimatedTo` doesn't work when it is on Sliver-related widgets, such as `ListView`, and the animation happens _across_ slivers. It is because `RenderSliver`'s layout system is totally different from `RenderBox`'s and there is no way to detect the exact from/to. If the animation happened _inside_ a single sliver, it works.

![animation inside sliver](https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to_5.gif)

## All arguments

| Argument | Type | Description |
| --- | --- | --- |
| globalKey | GlobalKey | A key to keep the widget alive even when its depth or position changes. |
| child | Widget | The widget you want to animate when its position changes. |
| duration | Duration | (curve only) The duration of the animation. |
| curve | Curve | (curve only) The curve of the animation. |
| description | SpringDescription | (spring only) The configuration of the spring simulation. |
| velocityBuilder | Offset Function()? | (spring only) A function to provide initial velocity to start spring animation. |
| verticalController | AnimationController? | Required if `AnimatedTo` is on the subtree of vertical `SingleChildScrollView`. Share the controller with the `SingleChildScrollView` to properly animate the widget. Don't provide one when `AnimatedTo` is on `ListView`. |
| horizontalController | AnimationController? | Required if `AnimatedTo` is on the subtree of horizontal `SingleChildScrollView`. Share the controller with the `SingleChildScrollView` to properly animate the widget. Don't provide one when `AnimatedTo` is on `ListView`. |
| appearingFrom` | Offset? | The start position of the animation in the first frame. This offset is an absolute position in the global coordinate system. |
| slidingFrom | Offset? | The start position of the animation in the first frame. This offset is a relative position to the child's intrinsic position. |
| enabled | bool | Whether the animation is enabled. |
| onEnd | void Function(AnimationEndCause cause)? | The callback when the animation is completed. `cause` shows the reason why the animation is completed. |
| sizeWidget | Widget | A widget for calculating desired size and position regardless of animations. |

See [example](example) for more details.

Author's X account [@tsuyoshi_chujo](https://x.com/tsuyoshi_chujo) also posts some example screenshots.

# Contact

If you have anything you want to inform me ([@chooyan-eng](https://github.com/chooyan-eng)), such as suggestions to enhance this package or functionalities you want etc, feel free to make [issues on GitHub](https://github.com/chooyan-eng/animated_to/issues) or send messages on X [@tsuyoshi_chujo](https://x.com/tsuyoshi_chujo) (Japanese [@chooyan_i18n](https://x.com/chooyan_i18n)).
