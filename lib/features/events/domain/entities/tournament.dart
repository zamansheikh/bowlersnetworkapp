import 'package:equatable/equatable.dart';

class Tournament extends Equatable {
  final int id;
  final String name;
  final String startDate;
  final String regDeadline;
  final String address;
  final double regFee;
  final String accessType;
  final String format; // 'Singles', 'Doubles', 'Teams'
  final int alreadyEnrolled;
  final int? participantsCount;

  const Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.regDeadline,
    required this.address,
    required this.regFee,
    required this.accessType,
    required this.format,
    required this.alreadyEnrolled,
    this.participantsCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        startDate,
        regDeadline,
        address,
        regFee,
        accessType,
        format,
        alreadyEnrolled,
        participantsCount,
      ];
}