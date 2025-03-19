import 'package:animated_to/src/curve_widget.dart';
import 'package:animated_to/src/spring_widget.dart';
import 'package:flutter/material.dart';
import 'package:springster/springster.dart';

/// [AnimatedTo] is a widget that animates a given [child] when its position changes for any reason.
/// You don't need to calculate any animation values, as the calculation is always done by [RenderObject].
///
/// Example:
/// ```dart
/// final widget = AnimatedTo.curve(
///   globalKey: GlobalObjectKey(item),
///   child: Container(
///     width: 100,
///     height: 100,
///     color: Colors.blue,
///   ),
/// );
///
/// // if _horizontal is true, the widget is in Row.
/// // otherwise, the widget is in Column.
/// return _horizontal ? Row(children: [widget, widget])
///   : Column(children: [widget, widget]);
/// ```
///
/// In the example above, the widget is automatically animated when _horizontal is changed and rebuilt.
///
/// Because [AnimatedTo] need to be kept alive even if its position or depth in the widget tree is changed,
/// [GlobalKey] must be provided to avoid the Flutter framework from disposing of it.
///
/// [AnimatedTo] has two types of animation:
/// - [AnimatedTo.curve] for curve animation.
/// - [AnimatedTo.spring] for spring animation.
///
/// Either way, the usage is the same, just wrapping whatever widget with [AnimatedTo].
class AnimatedTo extends StatelessWidget {
  const AnimatedTo._({
    required this.globalKey,
    this.curve,
    this.duration,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.onEnd,
    this.controller,
    this.description,
    this.child,
  });

  /// [AnimatedTo.curve] animates the child with a given [curve] and [duration].
  factory AnimatedTo.curve({
    required GlobalKey globalKey,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    Offset? appearingFrom,
    Offset? slidingFrom,
    bool enabled = true,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? controller,
    Widget? child,
  }) {
    return AnimatedTo._(
      globalKey: globalKey,
      curve: curve,
      duration: duration,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      onEnd: onEnd,
      controller: controller,
      child: child,
    );
  }

  /// [AnimatedTo.spring] animates the child with a given [SpringDescription].
  factory AnimatedTo.spring({
    required GlobalKey globalKey,
    SpringDescription? description,
    Offset? appearingFrom,
    Offset? slidingFrom,
    bool enabled = true,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? controller,
    Widget? child,
  }) {
    return AnimatedTo._(
      globalKey: globalKey,
      description: description,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      onEnd: onEnd,
      controller: controller,
      child: child,
    );
  }

  /// [GlobalKey] to keep the widget alive even if its position or depth in the widget tree is changed.
  final GlobalKey globalKey;

  /// [AnimatedTo.curve] only.
  /// [Duration] to animate the child to the new position.
  final Duration? duration;

  /// [AnimatedTo.curve] only.
  /// [Curve] to animate the child to the new position.
  final Curve? curve;

  /// [AnimatedTo.spring] only.
  /// [SpringDescription] to animate the child to the new position.
  final SpringDescription? description;

  /// If [appearingFrom] is given, [child] will start animation from [appearingFrom] in the first frame.
  /// This indicates absolute position in the global coordinate system.
  final Offset? appearingFrom;

  /// If [slidingFrom] is given, [child] will start animation from [slidingFrom] in the first frame.
  /// This indicates relative position to child's intrinsic position.
  final Offset? slidingFrom;

  /// Whether the animation is enabled.
  /// If false, the [child] will update its position without animation.
  final bool enabled;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? controller;

  /// [child] to animate.
  final Widget? child;

  bool get isCurve => curve != null;

  @override
  Widget build(BuildContext context) => isCurve
      ? CurveAnimatedTo(
          globalKey: globalKey,
          curve: curve!,
          duration: duration,
          appearingFrom: appearingFrom,
          slidingFrom: slidingFrom,
          enabled: enabled,
          onEnd: onEnd,
          controller: controller,
          child: child,
        )
      : SpringAnimatedTo(
          globalKey: globalKey,
          description: description ?? Spring.defaultIOS,
          appearingFrom: appearingFrom,
          slidingFrom: slidingFrom,
          enabled: enabled,
          onEnd: onEnd,
          controller: controller,
          child: child,
        );
}

/// Cause of animation end.
enum AnimationEndCause {
  /// animation is interrupted by another animation
  interrupted,

  /// widget achieves its goal
  completed,
}
