import 'package:animated_to/src/action.dart';
import 'package:animated_to/src/action_composer.dart';
import 'package:animated_to/src/helper.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================================
// Custom Matchers for Behavior-Focused Testing
// ============================================================================

/// Matcher that checks if actions contain AnimationStart
Matcher startsAnimation() => _ContainsActionMatcher<AnimationStart>();

/// Matcher that checks if actions contain AnimationCancel
Matcher cancelsAnimation() => _ContainsActionMatcher<AnimationCancel>();

/// Matcher that checks if actions contain AnimationEnd
Matcher endsAnimation() => _ContainsActionMatcher<AnimationEnd>();

/// Matcher that checks if actions contain PaintChild with specific offset
Matcher paintsChildAt(Offset offset) => _PaintsAtMatcher(offset);

/// Matcher that checks if actions contain JourneyMutation with specific from/to
Matcher hasJourney({Offset? from, Offset? to}) =>
    _HasJourneyMatcher(from: from, to: to);

// ============================================================================
// Matcher Implementations
// ============================================================================

class _ContainsActionMatcher<T extends MutationAction> extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<MutationAction>) return false;
    return item.whereType<T>().isNotEmpty;
  }

  @override
  Description describe(Description description) =>
      description.add('contains action of type $T');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) =>
      mismatchDescription.add('does not contain action of type $T');
}

class _PaintsAtMatcher extends Matcher {
  final Offset expectedOffset;

  _PaintsAtMatcher(this.expectedOffset);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<MutationAction>) return false;
    final paintChild = item.whereType<PaintChild>().firstOrNull;
    if (paintChild == null) {
      matchState['error'] = 'No PaintChild action found';
      return false;
    }
    if (paintChild.offset != expectedOffset) {
      matchState['actualOffset'] = paintChild.offset;
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('paints child at $expectedOffset');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState['error'] != null) {
      return mismatchDescription.add(matchState['error'] as String);
    }
    return mismatchDescription
        .add('paints at ${matchState['actualOffset']} instead');
  }
}

class _HasJourneyMatcher extends Matcher {
  final Offset? expectedFrom;
  final Offset? expectedTo;

  _HasJourneyMatcher({Offset? from, Offset? to})
      : expectedFrom = from,
        expectedTo = to;

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<MutationAction>) return false;
    final journeyMutation = item.whereType<JourneyMutation>().firstOrNull;
    if (journeyMutation == null) {
      matchState['error'] = 'No JourneyMutation action found';
      return false;
    }

    final journey = journeyMutation.value;
    if (expectedFrom != null && journey.from != expectedFrom) {
      matchState['actualFrom'] = journey.from;
      matchState['expectedFrom'] = expectedFrom;
      return false;
    }
    if (expectedTo != null && journey.to != expectedTo) {
      matchState['actualTo'] = journey.to;
      matchState['expectedTo'] = expectedTo;
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    final parts = <String>[];
    if (expectedFrom != null) parts.add('from: $expectedFrom');
    if (expectedTo != null) parts.add('to: $expectedTo');
    return description.add('has journey with ${parts.join(', ')}');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (matchState['error'] != null) {
      return mismatchDescription.add(matchState['error'] as String);
    }
    if (matchState['actualFrom'] != null) {
      return mismatchDescription.add(
          'has journey from ${matchState['actualFrom']} instead of ${matchState['expectedFrom']}');
    }
    if (matchState['actualTo'] != null) {
      return mismatchDescription.add(
          'has journey to ${matchState['actualTo']} instead of ${matchState['expectedTo']}');
    }
    return mismatchDescription;
  }
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  group('composeDisabled', () {
    test('should cancel animation and paint at offset when animating', () {
      const offset = Offset(10, 20);

      final actions = composeDisabled(true, offset);

      expect(actions, cancelsAnimation());
      expect(actions, paintsChildAt(offset));
    });

    test('should paint at offset when not animating', () {
      const offset = Offset(5, 10);

      final actions = composeDisabled(false, offset);

      expect(actions, paintsChildAt(offset));
    });
  });

  group('composeFirstFrame', () {
    test('should start animation from appearingFrom position when provided',
        () {
      const appearingFrom = Offset(0, 0);
      const offset = Offset(10, 20);

      final actions = composeFirstFrame(appearingFrom, null, offset);

      expect(actions, startsAnimation());
      expect(actions, hasJourney(from: appearingFrom, to: offset));
      expect(actions, paintsChildAt(appearingFrom));
    });

    test('should start animation from slidingFrom position when provided', () {
      const slidingFrom = Offset(5, 10);
      const offset = Offset(10, 20);

      final actions = composeFirstFrame(null, slidingFrom, offset);

      expect(actions, startsAnimation());
      expect(actions, hasJourney(from: const Offset(15, 30), to: offset));
      expect(actions, paintsChildAt(const Offset(15, 30)));
    });

    test('should only paint at offset when neither parameter is provided', () {
      const offset = Offset(10, 20);

      final actions = composeFirstFrame(null, null, offset);

      expect(actions, paintsChildAt(offset));

      final journey = actions.whereType<JourneyMutation>().first.value;
      expect(journey.isTightened, true);
    });

    test('should throw UnsupportedError when both parameters are provided', () {
      const appearingFrom = Offset(0, 0);
      const slidingFrom = Offset(5, 10);
      const offset = Offset(10, 20);

      expect(
        () => composeFirstFrame(appearingFrom, slidingFrom, offset),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('hasChangedPosition', () {
    test('should return false when position has not changed', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10, 20),
        currentGlobalOffset: const Offset(10, 20),
      );

      expect(result, false);
    });

    test('should return true when position has changed', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10, 20),
        currentGlobalOffset: const Offset(15, 25),
      );

      expect(result, true);
    });

    test('should return false when both self and ancestor moved by same amount',
        () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10, 20),
        currentGlobalOffset: const Offset(20, 30),
        lastAncestorGlobalOffset: const Offset(5, 10),
        currentAncestorGlobalOffset: const Offset(15, 20),
      );

      expect(result, false);
    });

    test('should return true when self moved relative to ancestor', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10, 20),
        currentGlobalOffset: const Offset(25, 35), // self: 15 pixels gap
        lastAncestorGlobalOffset: const Offset(5, 10),
        currentAncestorGlobalOffset:
            const Offset(15, 20), // ancestor: 10 pixels gap
      );

      expect(result, true);
    });

    test('should handle null ancestor offsets correctly', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10, 20),
        currentGlobalOffset: const Offset(15, 25),
        lastAncestorGlobalOffset: null,
        currentAncestorGlobalOffset: null,
      );

      expect(result, true);
    });

    test('should return false when gap is less than 1 pixel', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10.0, 20.0),
        currentGlobalOffset: const Offset(10.5, 20.5),
      );

      expect(result, false);
    });

    test('should return true when gap is 1 pixel or more', () {
      final result = hasChangedPosition(
        lastGlobalOffset: const Offset(10.0, 20.0),
        currentGlobalOffset: const Offset(11.0, 20.0),
      );

      expect(result, true);
    });
  });

  group('composeAnimation', () {
    test('should paint at offset when not animating and position unchanged',
        () {
      const offset = Offset(10, 20);
      const globalOffset = Offset(100, 200);
      final cache = OffsetCache(
        lastOffset: offset,
        lastGlobalOffset: globalOffset,
        lastBoundaryOffset: globalOffset,
        startOffset: offset,
      );

      final actions = composeAnimation(
        animationValue: null,
        offset: offset,
        globalOffset: globalOffset,
        boundaryOffset: globalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      expect(actions, paintsChildAt(offset));
    });

    test(
        'should start new animation from previous position when not animating and position changed',
        () {
      const offset = Offset(10, 20);
      const previousGlobalOffset = Offset(100, 200);
      const currentGlobalOffset = Offset(120, 210);
      final cache = OffsetCache(
        lastOffset: offset,
        lastGlobalOffset: previousGlobalOffset,
        lastBoundaryOffset: previousGlobalOffset,
        startOffset: offset,
      );

      final actions = composeAnimation(
        animationValue: null,
        offset: offset,
        globalOffset: currentGlobalOffset,
        boundaryOffset: currentGlobalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      expect(actions, startsAnimation());
      expect(actions, hasJourney(from: const Offset(-10, 10), to: offset));
      expect(actions, paintsChildAt(const Offset(-10, 10)));
    });

    test(
        'should continue animation with scroll adjustment when animating and position unchanged',
        () {
      const offset = Offset(10, 20);
      const startOffset = Offset(10, 20);
      const animationValue = Offset(5, 10);
      const globalOffset = Offset(100, 200);
      final cache = OffsetCache(
        lastOffset: offset,
        lastGlobalOffset: globalOffset,
        lastBoundaryOffset: globalOffset,
        startOffset: startOffset,
      );

      final actions = composeAnimation(
        animationValue: animationValue,
        offset: offset,
        globalOffset: globalOffset,
        boundaryOffset: globalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      // When animating without position change, just paints at animation position
      expect(actions, paintsChildAt(const Offset(5, 10)));
    });

    test('should continue animation with different offset due to scrolling',
        () {
      const offset = Offset(15, 25); // offset changed due to scrolling
      const startOffset = Offset(10, 20);
      const animationValue = Offset(5, 10);
      const globalOffset = Offset(100, 200);
      final cache = OffsetCache(
        lastOffset: const Offset(10, 20),
        lastGlobalOffset: globalOffset,
        lastBoundaryOffset: globalOffset,
        startOffset: startOffset,
      );

      final actions = composeAnimation(
        animationValue: animationValue,
        offset: offset,
        globalOffset: globalOffset,
        boundaryOffset: globalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      // Animation continues with scroll adjustment
      expect(actions, paintsChildAt(const Offset(10, 15)));
    });

    test(
        'should start new animation from current position when animating and position changed',
        () {
      const offset = Offset(20, 30);
      const startOffset = Offset(10, 20);
      const animationValue = Offset(12, 22);
      const lastGlobalOffset = Offset(100, 200);
      const currentGlobalOffset = Offset(120, 230);
      final cache = OffsetCache(
        lastOffset: const Offset(10, 20),
        lastGlobalOffset: lastGlobalOffset,
        lastBoundaryOffset: lastGlobalOffset,
        startOffset: startOffset,
      );

      final actions = composeAnimation(
        animationValue: animationValue,
        velocity: const Offset(5, 5),
        offset: offset,
        globalOffset: currentGlobalOffset,
        boundaryOffset: currentGlobalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      expect(actions, cancelsAnimation());
      expect(actions, startsAnimation());
      expect(actions, hasJourney(to: offset));

      // Verify velocity is preserved
      final animationStart = actions.whereType<AnimationStart>().first;
      expect(animationStart.velocity, const Offset(5, 5));
    });

    test('should handle ancestor change correctly', () {
      const offset = Offset(10, 20);
      const boundaryOffset = Offset(50, 60);
      const previousBoundaryOffset = Offset(40, 50);
      const lastGlobalOffset = Offset(100, 200);
      const currentGlobalOffset = Offset(110, 210);
      final cache = OffsetCache(
        lastOffset: offset,
        lastGlobalOffset: lastGlobalOffset,
        lastBoundaryOffset: previousBoundaryOffset,
        startOffset: offset,
      );

      final actions = composeAnimation(
        animationValue: null,
        offset: offset,
        globalOffset: currentGlobalOffset,
        boundaryOffset: boundaryOffset,
        ancestorChanged: true,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      expect(actions, startsAnimation());
      expect(actions, hasJourney(from: const Offset(0, 10), to: offset));
    });

    test('should handle case with ancestor AnimatedTo movement', () {
      const offset = Offset(10, 20);
      const lastGlobalOffset = Offset(100, 200);
      const currentGlobalOffset = Offset(110, 210);
      const lastAncestorGlobalOffset = Offset(50, 100);
      const currentAncestorGlobalOffset = Offset(60, 110);

      final cache = OffsetCache(
        lastOffset: offset,
        lastGlobalOffset: lastGlobalOffset,
        lastBoundaryOffset: lastGlobalOffset,
        lastAncestorGlobalOffset: lastAncestorGlobalOffset,
        startOffset: offset,
      );

      final actions = composeAnimation(
        animationValue: null,
        offset: offset,
        globalOffset: currentGlobalOffset,
        boundaryOffset: currentGlobalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: currentAncestorGlobalOffset,
        cache: cache,
      );

      // Position hasn't changed relative to ancestor, so no animation
      expect(actions, paintsChildAt(offset));
    });

    test('should handle null values in cache correctly', () {
      const offset = Offset(10, 20);
      const globalOffset = Offset(100, 200);
      final cache = OffsetCache(); // all null

      final actions = composeAnimation(
        animationValue: null,
        offset: offset,
        globalOffset: globalOffset,
        boundaryOffset: globalOffset,
        ancestorChanged: false,
        ancestorGlobalOffset: null,
        cache: cache,
      );

      // First frame with empty cache, position considered unchanged
      expect(actions, paintsChildAt(offset));
    });
  });
}
