import 'dart:ui';

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

  AnimationStart(this.journey);
}

final class AnimationEnd extends AnimationMutation {}

final class AnimationCancel extends AnimationMutation {}

final class PaintChild extends AnimationMutation {
  final Offset offset;
  final PaintingContext context;

  PaintChild(this.offset, this.context);
}

class PositionCacheMutation extends MutationAction {
  final double? scrollOffset;
  final double? scrollOffsetWhenAnimationStarted;
  final Offset? lastOffset;

  PositionCacheMutation({
    this.scrollOffset,
    this.scrollOffsetWhenAnimationStarted,
    this.lastOffset,
  });
}
