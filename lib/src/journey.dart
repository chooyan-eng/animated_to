import 'dart:ui';

/// [Journey] preserves the start and end position of the animation.
class Journey {
  const Journey({
    required this.from,
    required this.to,
  });

  /// Creates a [Journey] that preserves given [offset] as both start and end position.
  factory Journey.tighten(Offset offset) {
    return Journey(
      from: offset,
      to: offset,
    );
  }

  /// The start position of the animation.
  final Offset from;

  /// The end position of the animation.
  final Offset to;

  /// Whether the widget is preparing, meaning in the first frame.
  bool get isPreparing => from == Offset.zero && to == Offset.zero;

  /// Whether the animation is tightened.
  bool get isTightened => from == to;
}
