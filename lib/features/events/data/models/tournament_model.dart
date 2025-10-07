import '../../domain/entities/tournament.dart';

class TournamentModel extends Tournament {
  const TournamentModel({
    required super.id,
    required super.name,
    required super.startDate,
    required super.regDeadline,
    required super.address,
    required super.regFee,
    required super.accessType,
    required super.format,
    required super.alreadyEnrolled,
    super.participantsCount,
    super.lat,
    super.long,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: json['start_date'] as String,
      regDeadline: json['reg_deadline'] as String,
      address: json['address'] as String? ?? '',
      regFee: (json['reg_fee'] as num).toDouble(),
      accessType: json['access_type'] as String,
      format: json['format'] as String,
      alreadyEnrolled: json['already_enrolled'] as int? ?? 0,
      participantsCount: json['participants_count'] as int?,
      lat: json['lat'] as String?,
      long: json['long'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'reg_deadline': regDeadline,
      'address': address,
      'reg_fee': regFee,
      'access_type': accessType,
      'format': format,
      'already_enrolled': alreadyEnrolled,
      'participants_count': participantsCount,
      'lat': lat,
      'long': long,
    };
  }

  Tournament toEntity() => Tournament(
    id: id,
    name: name,
    startDate: startDate,
    regDeadline: regDeadline,
    address: address,
    regFee: regFee,
    accessType: accessType,
    format: format,
    alreadyEnrolled: alreadyEnrolled,
    participantsCount: participantsCount,
    lat: lat,
    long: long,
  );
}
