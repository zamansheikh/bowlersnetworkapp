import 'package:equatable/equatable.dart';

/// One brand the user can favorite. Backend endpoint: GET /api/brands.
class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    required this.type,
    required this.logoUrl,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final String type;
  final String logoUrl;
  final bool isFavorite;

  @override
  List<Object?> get props => [id, name, type, logoUrl, isFavorite];
}
