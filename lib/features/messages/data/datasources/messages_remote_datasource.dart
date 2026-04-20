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
}
