import '../../domain/entities/tournament.dart';

class TournamentModel extends Tournament {
  const TournamentModel({
    required int id,
    required String name,
    required String startDate,
    required String regDeadline,
    required String address,
    String? lat,
    String? long,
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
         lat: lat,
         long: long,
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
      id: _parseInt(json['id']) ?? 0,
      name: json['name'] as String,
      startDate: json['start_date'] as String,
      regDeadline: json['reg_deadline'] as String,
      address: json['address'] as String? ?? '',
      lat: json['lat'] as String?,
      long: json['long'] as String?,
      regFee: _parseDouble(json['reg_fee']),
      accessType: json['access_type'] as String,
      format: json['format'] as String,
      alreadyEnrolled: _parseInt(json['already_enrolled']) ?? 0,
      tournamentType: json['tournament_type'] as String? ?? 'Handicap',
      participantsCount: _parseInt(json['participants_count']),
      description: json['description'] as String?,
      status: json['status'] as String?,
      average: json['average'] != null ? _parseDouble(json['average']) : null,
      percentage: json['percentage'] != null
          ? _parseDouble(json['percentage'])
          : null,
    );
  }

  // Helper method to safely parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse int from various types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'reg_deadline': regDeadline,
      'address': address,
      'lat': lat,
      'long': long,
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
    lat: lat,
    long: long,
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
