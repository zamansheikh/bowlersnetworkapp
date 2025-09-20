import 'package:json_annotation/json_annotation.dart';
import 'message_sender_model.dart';
import 'time_details_model.dart';
import 'message_content_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: 'sentByMe')
  final bool sentByMe;
  @JsonKey(name: 'roomID')
  final int roomId;
  final MessageSenderModel sender;
  @JsonKey(name: 'timeDetails')
  final TimeDetailsModel timeDetails;
  final MessageContentModel message;

  const MessageModel({
    required this.sentByMe,
    required this.roomId,
    required this.sender,
    required this.timeDetails,
    required this.message,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId &&
          sender == other.sender &&
          timeDetails.sentAt == other.timeDetails.sentAt;

  @override
  int get hashCode =>
      roomId.hashCode ^ sender.hashCode ^ timeDetails.sentAt.hashCode;
}
