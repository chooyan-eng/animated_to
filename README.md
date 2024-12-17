# animated_to

animated_to provides a widget named `AnimatedTo`. 

<img src="https://github.com/chooyan-eng/animated_to/raw/main/assets/animated_to.gif" alt="AnimatedTo Preview" width="300"/>

`AnimatedTo` enables you to animate whatever widget you want to animate to the next position when rebuild happens and the rebuild updates the position of the widget.

No calculation is necessary. Every calculation is done by Flutter framework, and `AnimatedTo` just _animates_ to the calculated position.

## Usage

First, place whatever widget you want to animate when its position changes.

```dart
Container(
  width: 60,
  height: 60,
  color: Colors.blue,
)
```

Then, wrap the widget with `AnimatedTo` with some required arguments.

```dart
AnimatedTo(
  key: _globalKey,
  vsync: this,
  child: Container(
    width: 60,
    height: 60,
    color: Colors.blue,
  ),
)
```

`key` is `GlobalKey` to keep its `Element` and `RenderObject` alive even when the widget is placed at another branch of the widget tree.

`vsync` requires `TickerProviderStateMixin` for animation. You may typically mixin `TickerProviderStateMixin` in your `State` class of `StatefulWidget`.

That's it!

All what you need to do is causing rebuilds using whatever state management packages or just `setState` and change its position. `AnimatedTo` will automatically leads the `child` to the new position with animation.

## All arguments

| Argument | Type | Description |
| --- | --- | --- |
| `key` | `GlobalKey` | A key to identify the widget even when it's placed at another branch of the widget tree. |
| `vsync` | `TickerProviderStateMixin` | A ticker provider to provide animation. |
| `child` | `Widget` | The widget to animate. |
| `duration` | `Duration` | The duration of the animation. |
| `curve` | `Curve` | The curve of the animation. |
| `appearingFrom` | `Offset?` | The start position of the animation in the first frame. This offset is an absolute position in the global coordinate system. |
| `slidingFrom` | `Offset?` | The start position of the animation in the first frame. This offset is a relative position to the child's intrinsic position. |
| `enabled` | `bool` | Whether the animation is enabled. Be sure to set `false` when scrolling. Otherwise, the scrolling will look like jerky. |
| `onEnd` | `void Function(AnimationEndCause cause)?` | The callback when the animation is completed. `cause` shows the reason why the animation is completed. |

See [example](example) for more details.

Or, see my X account [@chooyan_i18n](https://x.com/chooyan_i18n) posting some example screenshots.

# Contact

If you have anything you want to inform me ([@chooyan-eng](https://github.com/chooyan-eng)), such as suggestions to enhance this package or functionalities you want etc, feel free to make [issues on GitHub](https://github.com/chooyan-eng/animated_to/issues) or send messages on X [@tsuyoshi_chujo](https://x.com/tsuyoshi_chujo) (Japanese [@chooyan_i18n](https://x.com/chooyan_i18n)).
