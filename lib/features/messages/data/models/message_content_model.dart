import 'package:json_annotation/json_annotation.dart';

part 'message_content_model.g.dart';

@JsonSerializable()
class MessageContentModel {
  final String text;
  final List<String> media;

  const MessageContentModel({required this.text, required this.media});

  factory MessageContentModel.fromJson(Map<String, dynamic> json) =>
      _$MessageContentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentModelToJson(this);
}
