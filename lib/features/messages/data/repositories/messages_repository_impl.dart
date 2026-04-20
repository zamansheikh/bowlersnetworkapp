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
