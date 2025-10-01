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
  final int alreadyEnrolled; // 0 = not enrolled, 1 = enrolled
  final int? participantsCount;
  final String? description;
  final String? status; // 'active', 'premium', 'cancelled'

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
    this.description,
    this.status,
  });

  Tournament copyWith({
    int? id,
    String? name,
    String? startDate,
    String? regDeadline,
    String? address,
    double? regFee,
    String? accessType,
    String? format,
    int? alreadyEnrolled,
    int? participantsCount,
    String? description,
    String? status,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      regDeadline: regDeadline ?? this.regDeadline,
      address: address ?? this.address,
      regFee: regFee ?? this.regFee,
      accessType: accessType ?? this.accessType,
      format: format ?? this.format,
      alreadyEnrolled: alreadyEnrolled ?? this.alreadyEnrolled,
      participantsCount: participantsCount ?? this.participantsCount,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  bool get isRegistered => alreadyEnrolled > 0;

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get regDeadlineDateTime => DateTime.parse(regDeadline);
  
  bool get isRegistrationOpen => DateTime.now().isBefore(regDeadlineDateTime);

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
        description,
        status,
      ];
}