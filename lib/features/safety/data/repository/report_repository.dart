abstract class ReportRepository {
  Future<void> reportPost({
    required String postId,
    required String reportedUserId,
    required String reason,
    String? description,
  });

  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  });

  Future<void> reportMessage({
    required String messageId,
    required String reportedUserId,
    required String reason,
    String? description,
  });
}

class ReportRepositoryImpl implements ReportRepository {
  // TODO: Inject your API service here when backend is ready

  @override
  Future<void> reportPost({
    required String postId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      // TODO: Implement API call to backend
      // POST /api/reports/post
      // Body: {
      //   post_id: postId,
      //   reported_user_id: reportedUserId,
      //   reason: reason,
      //   description: description,
      // }

      // For now, simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      // TODO: Implement API call to backend
      // POST /api/reports/user

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reportMessage({
    required String messageId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      // TODO: Implement API call to backend
      // POST /api/reports/message

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      rethrow;
    }
  }
}
