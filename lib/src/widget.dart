import 'package:animated_to/src/curve_widget.dart';
import 'package:animated_to/src/spring_widget.dart';
import 'package:flutter/material.dart';

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
///
/// If you want to start animation during the navigation transition, wrap the page widget,
/// typically [Scaffold], with [AnimatedToContainer]. This let [AnimatedTo] ignore the
/// position changes caused by navigation transition, which makes the animation accurate.
class AnimatedTo extends StatelessWidget {
  const AnimatedTo._({
    required this.globalKey,
    this.curve,
    this.duration,
    this.appearingFrom,
    this.slidingFrom,
    this.enabled = true,
    this.hitTestEnabled = true,
    this.onEnd,
    this.verticalController,
    this.horizontalController,
    this.description,
    this.velocityBuilder,
    this.child,
    this.sizeWidget,
  });

  /// [AnimatedTo.curve] animates the child with a given [curve] and [duration].
  factory AnimatedTo.curve({
    required GlobalKey globalKey,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    Offset? appearingFrom,
    Offset? slidingFrom,
    bool enabled = true,
    bool hitTestEnabled = true,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? verticalController,
    ScrollController? horizontalController,
    Widget? child,
    Widget? sizeWidget,
  }) {
    return AnimatedTo._(
      globalKey: globalKey,
      curve: curve,
      duration: duration,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      hitTestEnabled: hitTestEnabled,
      onEnd: onEnd,
      verticalController: verticalController,
      horizontalController: horizontalController,
      sizeWidget: sizeWidget,
      child: child,
    );
  }

  /// [AnimatedTo.spring] animates the child with a given [SpringDescription].
  factory AnimatedTo.spring({
    required GlobalKey globalKey,
    SpringDescription? description,
    Offset Function()? velocityBuilder,
    Offset? appearingFrom,
    Offset? slidingFrom,
    bool enabled = true,
    bool hitTestEnabled = true,
    void Function(AnimationEndCause cause)? onEnd,
    ScrollController? verticalController,
    ScrollController? horizontalController,
    Widget? child,
    Widget? sizeWidget,
  }) {
    return AnimatedTo._(
      globalKey: globalKey,
      description: description,
      velocityBuilder: velocityBuilder,
      appearingFrom: appearingFrom,
      slidingFrom: slidingFrom,
      enabled: enabled,
      hitTestEnabled: hitTestEnabled,
      onEnd: onEnd,
      verticalController: verticalController,
      horizontalController: horizontalController,
      sizeWidget: sizeWidget,
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

  /// [AnimatedTo.spring] only.
  /// A function that provides [Offset] of velocity to animate the child to the new position.
  /// This function is called every time [AnimatedTo] decides to start spring animation without previous animation's velocity.
  final Offset Function()? velocityBuilder;

  /// If [appearingFrom] is given, [child] will start animation from [appearingFrom] in the first frame.
  /// This indicates absolute position in the global coordinate system.
  final Offset? appearingFrom;

  /// If [slidingFrom] is given, [child] will start animation from [slidingFrom] in the first frame.
  /// This indicates relative position to child's intrinsic position.
  final Offset? slidingFrom;

  /// Whether the animation is enabled.
  /// If false, the [child] will update its position without animation.
  final bool enabled;

  /// Controls whether hit testing is performed at the animated position during animation.
  ///
  /// When `true`, this widget will respond to hit tests at its current animated position
  /// while animating. When `false`, hit tests will only occur at the widget's layout position.
  ///
  /// Note: This flag only affects behavior during animation. When the widget is not animating,
  /// hit testing always occurs at the widget's normal layout position regardless of this setting.
  ///
  /// Defaults to `true`.
  final bool hitTestEnabled;

  /// callback when animation is completed.
  final void Function(AnimationEndCause cause)? onEnd;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView] with [Axis.vertical].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? verticalController;

  /// [ScrollController] to get scroll offset.
  /// This must be provided if the child is in a [SingleChildScrollView] with [Axis.horizontal].
  ///
  /// Note: [ListView] and its families are not supported currently.
  final ScrollController? horizontalController;

  /// [child] to animate.
  final Widget? child;

  /// [sizeWidget] to maintain the size of the child, regardless of transformation animations.
  ///
  /// Because [AnimatedTo] starts animation at every time when [child] updates its position,
  /// which means if the [child] updates its size with animation, [AnimatedTo] tries to start
  /// its own animation at every frame resulting in [child] doesn't animate as expected.
  ///
  /// [sizeWidget] is used to calculate the size and the position *after* animation so that
  /// [AnimatedTo] recognize the desired destination and prevent from unnecessary animation running.
  /// Thus, [sizeWidget] has to be independent from transition animation.
  final Widget? sizeWidget;

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
          hitTestEnabled: hitTestEnabled,
          onEnd: onEnd,
          verticalController: verticalController,
          horizontalController: horizontalController,
          sizeWidget: sizeWidget,
          child: child,
        )
      : SpringAnimatedTo(
          globalKey: globalKey,
          description: description ?? SpringDescription.withDurationAndBounce(),
          velocityBuilder: velocityBuilder,
          appearingFrom: appearingFrom,
          slidingFrom: slidingFrom,
          enabled: enabled,
          hitTestEnabled: hitTestEnabled,
          onEnd: onEnd,
          verticalController: verticalController,
          horizontalController: horizontalController,
          sizeWidget: sizeWidget,
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
