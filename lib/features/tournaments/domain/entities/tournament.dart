import 'package:equatable/equatable.dart';

class Tournament extends Equatable {
  final int id;
  final String name;
  final String startDate;
  final String regDeadline;
  final String address;
  final String? lat; // Optional latitude
  final String? long; // Optional longitude
  final double regFee;
  final String accessType; // 'Open', 'Invitational'
  final String format; // 'Singles', 'Doubles', 'Teams'
  final int alreadyEnrolled; // 0 = not enrolled, 1 = enrolled
  final int? participantsCount;
  final String? description;
  final String? status; // 'active', 'premium', 'cancelled'
  final String tournamentType; // 'Handicap', 'Scratch'
  final double? average; // Required for both types
  final double? percentage; // Only required for Handicap type

  const Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.regDeadline,
    required this.address,
    this.lat,
    this.long,
    required this.regFee,
    required this.accessType,
    required this.format,
    required this.alreadyEnrolled,
    required this.tournamentType,
    this.participantsCount,
    this.description,
    this.status,
    this.average,
    this.percentage,
  });

  Tournament copyWith({
    int? id,
    String? name,
    String? startDate,
    String? regDeadline,
    String? address,
    String? lat,
    String? long,
    double? regFee,
    String? accessType,
    String? format,
    int? alreadyEnrolled,
    int? participantsCount,
    String? description,
    String? status,
    String? tournamentType,
    double? average,
    double? percentage,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      regDeadline: regDeadline ?? this.regDeadline,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      regFee: regFee ?? this.regFee,
      accessType: accessType ?? this.accessType,
      format: format ?? this.format,
      alreadyEnrolled: alreadyEnrolled ?? this.alreadyEnrolled,
      participantsCount: participantsCount ?? this.participantsCount,
      description: description ?? this.description,
      status: status ?? this.status,
      tournamentType: tournamentType ?? this.tournamentType,
      average: average ?? this.average,
      percentage: percentage ?? this.percentage,
    );
  }

  bool get isRegistered => alreadyEnrolled > 0;

  DateTime get startDateTime => DateTime.parse(startDate);
  DateTime get regDeadlineDateTime => DateTime.parse(regDeadline);

  bool get isRegistrationOpen => DateTime.now().isBefore(regDeadlineDateTime);

  // Default coordinates for New York when lat/long are null
  static const String _defaultLat = '40.7128';
  static const String _defaultLong = '-74.0060';

  String get effectiveLat => lat?.isNotEmpty == true ? lat! : _defaultLat;
  String get effectiveLong => long?.isNotEmpty == true ? long! : _defaultLong;

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    regDeadline,
    address,
    lat,
    long,
    regFee,
    accessType,
    format,
    alreadyEnrolled,
    participantsCount,
    description,
    status,
    tournamentType,
    average,
    percentage,
  ];
}
