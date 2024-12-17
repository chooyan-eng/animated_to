import 'dart:ui';

class Journey {
  const Journey({
    required this.from,
    required this.to,
  });

  factory Journey.tighten(Offset offset) {
    return Journey(
      from: offset,
      to: offset,
    );
  }

  final Offset from;
  final Offset to;

  Journey next(Offset offset) {
    return Journey(
      from: to,
      to: offset,
    );
  }

  bool get isPreparing => from == Offset.zero && to == Offset.zero;

  bool get isTightened => from == to;
}
