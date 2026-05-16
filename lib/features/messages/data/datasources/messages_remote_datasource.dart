import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/messages_dtos.dart';

part 'messages_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class MessagesRemoteDatasource {
  @factoryMethod
  factory MessagesRemoteDatasource(Dio dio) = _MessagesRemoteDatasource;

  @GET(Endpoints.conversationsList)
  Future<ConversationsPageDto> getConversations({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/messages/conversations/{uid}')
  Future<ConversationDetailDto> getConversation(@Path('uid') String uid);

  @GET('/api/messages/conversations/{uid}/messages')
  Future<MessagesPageDto> getMessages(
    @Path('uid') String uid, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/messages/conversations/{uid}/messages/send')
  Future<MessageDto> sendMessage(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/messages/conversations/{uid}/read')
  Future<void> markRead(@Path('uid') String uid);

  @GET(Endpoints.usersSearch)
  Future<SearchUsersResponseDto> searchUsers(@Query('q') String q);

  @POST(Endpoints.createPrivateConversation)
  Future<ConversationListItemDto> createPrivateConversation(
    @Body() Map<String, dynamic> body,
  );

  @POST(Endpoints.createGroupConversation)
  Future<ConversationListItemDto> createGroupConversation(
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/messages/{uid}/delete')
  Future<void> deleteMessage(@Path('uid') String uid);

  @POST('/api/messages/conversations/{uid}/mute')
  Future<MuteResponseDto> toggleMute(@Path('uid') String uid);

  @POST('/api/messages/conversations/{uid}/leave')
  Future<void> leaveGroup(@Path('uid') String uid);

  @DELETE('/api/messages/conversations/{uid}/delete')
  Future<void> deleteConversation(@Path('uid') String uid);

  @PUT('/api/messages/conversations/{uid}/update')
  Future<ConversationDetailDto> updateConversation(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/messages/conversations/{uid}/members')
  Future<ConversationDetailDto> addMembers(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/messages/conversations/{uid}/members/{userId}')
  Future<void> removeMember(
    @Path('uid') String uid,
    @Path('userId') int userId,
  );

  @GET('/api/messages/conversations/{uid}')
  Future<ConversationDetailDto> getConversationDetail(
    @Path('uid') String uid,
  );
}
