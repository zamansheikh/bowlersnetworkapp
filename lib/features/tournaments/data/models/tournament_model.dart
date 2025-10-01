import '../../domain/entities/tournament.dart';

class TournamentModel extends Tournament {
  const TournamentModel({
    required int id,
    required String name,
    required String startDate,
    required String regDeadline,
    required String address,
    required double regFee,
    required String accessType,
    required String format,
    required int alreadyEnrolled,
    required String tournamentType,
    int? participantsCount,
    String? description,
    String? status,
    double? average,
    double? percentage,
  }) : super(
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
         description: description,
         status: status,
         tournamentType: tournamentType,
         average: average,
         percentage: percentage,
       );

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
      tournamentType: json['tournament_type'] as String? ?? 'Handicap',
      participantsCount: json['participants_count'] as int?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      average: json['average'] != null ? (json['average'] as num).toDouble() : null,
      percentage: json['percentage'] != null ? (json['percentage'] as num).toDouble() : null,
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
      'description': description,
      'status': status,
      'tournament_type': tournamentType,
      'average': average,
      'percentage': percentage,
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
    description: description,
    status: status,
    tournamentType: tournamentType,
    average: average,
    percentage: percentage,
  );
}
