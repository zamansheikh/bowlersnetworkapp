import 'package:json_annotation/json_annotation.dart';
import 'conversation_model.dart';

part 'chat_rooms_response_model.g.dart';

@JsonSerializable()
class ChatRoomsResponseModel {
  final List<ConversationModel> private;
  final List<ConversationModel> group;

  const ChatRoomsResponseModel({required this.private, required this.group});

  factory ChatRoomsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomsResponseModelToJson(this);

  List<ConversationModel> get allConversations => [...private, ...group];
}
