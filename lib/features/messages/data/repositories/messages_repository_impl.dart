import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_remote_datasource.dart';
import '../models/messages_dtos.dart';

@LazySingleton(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._remote);

  final MessagesRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<ConversationListItem>>> getConversations({
    int? page,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final page0 = await _remote.getConversations(
          page: page,
          pageSize: pageSize,
        );
        return page0.conversations.map(_conversationToEntity).toList(
              growable: false,
            );
      });

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String conversationUid, {
    int? page,
    int pageSize = 30,
  }) =>
      _guard(() async {
        final res = await _remote.getMessages(
          conversationUid,
          page: page,
          pageSize: pageSize,
        );
        return res.messages.map(_messageToEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationUid,
    required String text,
    List<MessageMedia> media = const [],
  }) =>
      _guard(() async {
        final dto = await _remote.sendMessage(conversationUid, {
          'text': text,
          'media': media
              .map((m) => {'url': m.url, 'type': m.type})
              .toList(growable: false),
        });
        return _messageToEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> markRead(String conversationUid) =>
      _guard(() async {
        await _remote.markRead(conversationUid);
        return unit;
      });

  @override
  ChatMessage parseSocketMessage(Map<String, dynamic> raw) =>
      _messageToEntity(MessageDto.fromJson(raw));

  @override
  Future<Either<Failure, List<SearchUser>>> searchUsers(String q) =>
      _guard(() async {
        final res = await _remote.searchUsers(q);
        return res.users
            .map((u) => SearchUser(
                  id: u.id,
                  username: u.username,
                  firstName: u.firstName,
                  lastName: u.lastName,
                  profilePictureUrl: u.profilePictureUrl,
                  rankDisplay: u.rankDisplay,
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, ConversationListItem>> createPrivateConversation(
    int userId,
  ) =>
      _guard(() async {
        final dto = await _remote.createPrivateConversation({'user_id': userId});
        return _conversationToEntity(dto);
      });

  @override
  Future<Either<Failure, ConversationListItem>> createGroupConversation({
    required List<int> userIds,
    required String name,
  }) =>
      _guard(() async {
        final dto = await _remote.createGroupConversation({
          'user_ids': userIds,
          'name': name,
        });
        return _conversationToEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> deleteMessage(String messageUid) =>
      _guard(() async {
        await _remote.deleteMessage(messageUid);
        return unit;
      });

  @override
  Future<Either<Failure, bool>> toggleMute(String conversationUid) =>
      _guard(() async {
        final res = await _remote.toggleMute(conversationUid);
        return res.isMuted;
      });

  @override
  Future<Either<Failure, Unit>> leaveGroup(String conversationUid) =>
      _guard(() async {
        await _remote.leaveGroup(conversationUid);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteConversation(String conversationUid) =>
      _guard(() async {
        await _remote.deleteConversation(conversationUid);
        return unit;
      });

  @override
  Future<Either<Failure, ConversationDetail>> getConversationDetail(
    String conversationUid,
  ) =>
      _guard(() async {
        final dto = await _remote.getConversationDetail(conversationUid);
        return _detailToEntity(dto);
      });

  @override
  Future<Either<Failure, ConversationDetail>> updateGroupName({
    required String conversationUid,
    required String name,
  }) =>
      _guard(() async {
        final dto = await _remote.updateConversation(
          conversationUid,
          {'name': name},
        );
        return _detailToEntity(dto);
      });

  @override
  Future<Either<Failure, ConversationDetail>> addMembers({
    required String conversationUid,
    required List<int> userIds,
  }) =>
      _guard(() async {
        final dto = await _remote.addMembers(
          conversationUid,
          {'user_ids': userIds},
        );
        return _detailToEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> removeMember({
    required String conversationUid,
    required int userId,
  }) =>
      _guard(() async {
        await _remote.removeMember(conversationUid, userId);
        return unit;
      });

  // ---------------------------------------------------------------------------
  ConversationDetail _detailToEntity(ConversationDetailDto dto) =>
      ConversationDetail(
        uid: dto.uid,
        name: dto.name,
        isGroup: dto.isGroup,
        imageUrl: dto.imageUrl,
        memberCount: dto.memberCount,
        isCreator: dto.isCreator,
        isMuted: dto.isMuted,
        members: dto.members
            .map((m) => ConversationMember(
                  id: m.id,
                  username: m.username,
                  firstName: m.firstName,
                  lastName: m.lastName,
                  profilePictureUrl: m.profilePictureUrl,
                ))
            .toList(growable: false),
        createdAt: dto.createdAt == null
            ? null
            : DateTime.tryParse(dto.createdAt!),
      );

  // ---------------------------------------------------------------------------
  ConversationListItem _conversationToEntity(ConversationListItemDto dto) =>
      ConversationListItem(
        uid: dto.uid,
        name: dto.name,
        isGroup: dto.isGroup,
        imageUrl: dto.imageUrl,
        hasUnread: dto.hasUnread,
        lastMessage: dto.lastMessage == null
            ? null
            : LastMessagePreview(
                senderName: dto.lastMessage!.senderName,
                text: dto.lastMessage!.text,
                createdAt: dto.lastMessage!.createdAt == null
                    ? null
                    : DateTime.tryParse(dto.lastMessage!.createdAt!),
              ),
        memberCount: dto.memberCount,
        isMuted: dto.isMuted,
      );

  ChatMessage _messageToEntity(MessageDto dto) => ChatMessage(
        uid: dto.uid,
        sender: MessageSender(
          id: dto.sender.id,
          username: dto.sender.username,
          firstName: dto.sender.firstName,
          lastName: dto.sender.lastName,
          profilePictureUrl: dto.sender.profilePictureUrl,
        ),
        text: dto.text,
        media: dto.media
            .map((m) => MessageMedia(url: m.url, type: m.type))
            .toList(growable: false),
        isDeleted: dto.isDeleted,
        isOwn: dto.isOwn,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
      );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final parsed = e.error;
      if (parsed is NetworkException) return const Left(NetworkFailure());
      if (parsed is ApiException) {
        if (parsed.statusCode == 401) {
          return Left(UnauthorizedFailure(messages: parsed.messages));
        }
        return Left(ServerFailure(
          messages: parsed.messages,
          statusCode: parsed.statusCode,
        ));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
