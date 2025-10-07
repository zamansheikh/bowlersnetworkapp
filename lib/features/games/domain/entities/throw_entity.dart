import 'package:equatable/equatable.dart';

class ThrowEntity extends Equatable {
  final Set<int> knockedPins;
  final bool isFoul;

  const ThrowEntity({
    required this.knockedPins,
    this.isFoul = false,
  });

  int get pinsKnocked => isFoul ? 0 : knockedPins.length;

  @override
  List<Object> get props => [knockedPins, isFoul];
}