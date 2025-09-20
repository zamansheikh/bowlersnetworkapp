import 'package:json_annotation/json_annotation.dart';
import 'conversation_model.dart';

part 'chat_rooms_response_model.g.dart';

@JsonSerializable()
class ChatRoomsResponseModel {
  final List<ConversationModel> private;
  final List<ConversationModel> group;

  const ChatRoomsResponseModel({required this.private, required this.group});

  factory ChatRoomsResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse private conversations and add type
    final privateList =
        (json['private'] as List<dynamic>?)
            ?.map(
              (item) => ConversationModel.fromJson({
                ...item as Map<String, dynamic>,
                'type': 'private',
              }),
            )
            .toList() ??
        [];

    // Parse group conversations and add type
    final groupList =
        (json['group'] as List<dynamic>?)
            ?.map(
              (item) => ConversationModel.fromJson({
                ...item as Map<String, dynamic>,
                'type': 'group',
              }),
            )
            .toList() ??
        [];

    return ChatRoomsResponseModel(private: privateList, group: groupList);
  }

  Map<String, dynamic> toJson() => _$ChatRoomsResponseModelToJson(this);

  List<ConversationModel> get allConversations => [...private, ...group];
}
