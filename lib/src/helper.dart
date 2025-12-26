import 'package:animated_to/src/action.dart';
import 'package:flutter/rendering.dart';

/// cached values for calculation
class OffsetCache {
  OffsetCache({
    this.startOffset,
    this.lastOffset,
    this.lastGlobalOffset,
    this.lastContainerOffset,
    this.lastAncestorGlobalOffset,
  });

  final Offset? startOffset;
  final Offset? lastOffset;
  final Offset? lastGlobalOffset;
  final Offset? lastContainerOffset;
  final Offset? lastAncestorGlobalOffset;

  OffsetCache copyWith({
    Offset? startOffset,
    Offset? lastOffset,
    Offset? lastGlobalOffset,
    Offset? lastContainerOffset,
    Offset? lastAncestorGlobalOffset,
  }) =>
      OffsetCache(
        startOffset: startOffset ?? this.startOffset,
        lastOffset: lastOffset ?? this.lastOffset,
        lastGlobalOffset: lastGlobalOffset ?? this.lastGlobalOffset,
        lastContainerOffset: lastContainerOffset ?? this.lastContainerOffset,
        lastAncestorGlobalOffset:
            lastAncestorGlobalOffset ?? this.lastAncestorGlobalOffset,
      );
}

extension ProvideContextExt on List<MutationAction> {
  List<MutationAction> contextPovided(PaintingContext context) => map(
        (mutation) =>
            mutation is PaintChild ? mutation.provide(context) : mutation,
      ).toList();
}
