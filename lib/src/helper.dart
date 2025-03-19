import 'package:animated_to/src/action.dart';
import 'package:flutter/rendering.dart';

/// cached values for calculation
class OffsetCache {
  OffsetCache({
    this.scrollLast,
    this.scrollOriginal,
    this.last,
  });

  final double? scrollLast;
  final double? scrollOriginal;
  final Offset? last;

  OffsetCache copyWith({
    double? scrollLast,
    double? scrollOriginal,
    Offset? last,
  }) =>
      OffsetCache(
        scrollLast: scrollLast ?? this.scrollLast,
        scrollOriginal: scrollOriginal ?? this.scrollOriginal,
        last: last ?? this.last,
      );
}

extension ProvideContextExt on List<MutationAction> {
  List<MutationAction> provided(PaintingContext context) => map(
        (mutation) =>
            mutation is PaintChild ? mutation.provide(context) : mutation,
      ).toList();
}
