import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A container widget that enables hit testing for animating [AnimatedTo] descendants.
///
/// When [AnimatedTo] widgets are animating, they visually move to new positions but
/// their hit test areas remain at their layout positions. [AnimatedToContainer] solves
/// this by intercepting hit tests and checking animating descendants at their animated
/// positions first.
///
/// Example:
/// ```dart
/// AnimatedToContainer(
///   child: Column(
///     children: [
///       AnimatedTo.spring(
///         globalKey: GlobalObjectKey(item1),
///         child: MyWidget(),
///       ),
///       AnimatedTo.spring(
///         globalKey: GlobalObjectKey(item2),
///         child: MyWidget(),
///       ),
///     ],
///   ),
/// )
/// ```
class AnimatedToContainer extends StatefulWidget {
  const AnimatedToContainer({
    super.key,
    required this.child,
  });

  /// The child widget that may contain [AnimatedTo] descendants.
  final Widget child;

  /// Retrieves the nearest [RenderAnimatedToContainer] from the given [context].
  ///
  /// Returns null if no [AnimatedToContainer] ancestor is found.
  static RenderAnimatedToContainer? of(BuildContext context) {
    return context.findAncestorRenderObjectOfType<RenderAnimatedToContainer>();
  }

  @override
  State<AnimatedToContainer> createState() => _AnimatedToContainerState();
}

class _AnimatedToContainerState extends State<AnimatedToContainer> {
  final GlobalKey _renderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return _AnimatedToContainerRenderWidget(
      key: _renderKey,
      child: widget.child,
    );
  }
}

/// RenderObjectWidget that creates [RenderAnimatedToContainer].
class _AnimatedToContainerRenderWidget extends SingleChildRenderObjectWidget {
  const _AnimatedToContainerRenderWidget({
    super.key,
    required super.child,
  });

  @override
  RenderAnimatedToContainer createRenderObject(BuildContext context) {
    return RenderAnimatedToContainer();
  }
}

/// A [RenderProxyBox] that performs custom hit testing for animating descendants.
///
/// This render object maintains a list of currently animating [RenderAnimatedTo]
/// objects and performs hit testing on them at their animated positions before
/// falling back to normal hit testing.
class RenderAnimatedToContainer extends RenderProxyBox {
  /// List of currently animating render objects.
  final List<RenderAnimatedTo> _animatingWidgets = [];

  /// Registers an animating render object.
  ///
  /// Called by [RenderAnimatedTo] when it starts animating.
  void registerAnimatingWidget(RenderAnimatedTo renderObject) {
    if (!_animatingWidgets.contains(renderObject)) {
      _animatingWidgets.add(renderObject);
    }
  }

  /// Unregisters an animating render object.
  ///
  /// Called by [RenderAnimatedTo] when animation ends or is cancelled.
  void unregisterAnimatingWidget(RenderAnimatedTo renderObject) {
    _animatingWidgets.remove(renderObject);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // First, check animating widgets at their animated positions
    for (final animatingWidget in _animatingWidgets) {
      // Get current animated state from the widget
      final animatedOffset = animatingWidget.currentAnimatedOffset;
      final size = animatingWidget.size;

      // Convert global animated position to local coordinates
      final localPosition = animatedOffset;

      // Check if hit position is within the animated bounds
      final hitRect = localPosition & size;
      if (hitRect.contains(position)) {
        // Transform hit position to the widget's coordinate space
        final childPosition = position - localPosition;

        // Perform hit test on the animating widget
        if (animatingWidget.hitTest(result, position: childPosition)) {
          return true; // First hit wins, stop checking
        }
      }
    }

    // No animating widget was hit, fall back to normal hit testing
    return super.hitTest(result, position: position);
  }
}

/// Base interface for render objects that can be registered with [RenderAnimatedToContainer].
///
/// This is implemented by both spring and curve versions of [RenderAnimatedTo].
abstract class RenderAnimatedTo extends RenderProxyBox {
  /// The current animated position in global coordinates.
  Offset get currentAnimatedOffset;
}
