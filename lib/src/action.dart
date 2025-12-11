import 'package:animated_to/src/journey.dart';
import 'package:flutter/rendering.dart';

sealed class MutationAction {}

sealed class ValueMutationAction<T> extends MutationAction {
  final T value;

  ValueMutationAction(this.value);
}

final class JourneyMutation extends ValueMutationAction<Journey> {
  JourneyMutation(super.value);
}

sealed class AnimationMutation extends MutationAction {}

final class AnimationStart extends AnimationMutation {
  final Journey journey;
  final Offset? velocity;

  AnimationStart(this.journey, this.velocity);
}

final class AnimationEnd extends AnimationMutation {}

final class AnimationCancel extends AnimationMutation {}

final class PaintChild extends AnimationMutation {
  final Offset offset;
  final PaintingContext? context;

  factory PaintChild.requireContext(Offset offset) => PaintChild(offset, null);
  PaintChild provide(PaintingContext context) => PaintChild(offset, context);

  PaintChild(this.offset, this.context);
}

class OffsetCacheMutation extends MutationAction {
  final Offset? startOffset;
  final Offset? lastOffset;
  final Offset? lastGlobalOffset;
  final Offset? lastAncestorGlobalOffset;

  OffsetCacheMutation({
    this.startOffset,
    this.lastOffset,
    this.lastGlobalOffset,
    this.lastAncestorGlobalOffset,
  });
}
