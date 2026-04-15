import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';

/// Shared service for uploading files to Cloudflare R2 via the backend's
/// presigned-URL flow. Used across features: profile pictures, post media,
/// event flyers, chat attachments, etc.
///
/// **Upload flow:**
/// 1. `POST /api/cloud/upload/singlepart/requests/initiate` → get presigned URL
/// 2. `PUT` file bytes to the presigned URL (direct to R2, no auth header)
/// 3. Use the `publicUrl` returned from step 1
///
/// **Available buckets:** cdn, profiles, media, chat, events, cards, sponsors
@lazySingleton
class CloudUploadService {
  final Dio _dio;
  final Dio _uploadDio;

  CloudUploadService(
    this._dio,
    @Named('uploadDio') this._uploadDio,
  );

  /// Uploads a file and returns its public CDN URL.
  ///
  /// [fileBytes] — raw file content
  /// [fileName] — original file name (used for extension detection)
  /// [bucket]   — one of: cdn, profiles, media, chat, events, cards, sponsors
  /// [onProgress] — optional upload progress callback (0.0 → 1.0)
  Future<Either<Failure, String>> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String bucket,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // 1. Initiate — get presigned URL + public URL
      final initResponse = await _dio.post(
        Endpoints.uploadSinglepart,
        data: {'file_name': fileName, 'bucket': bucket},
      );
      final data = initResponse.data as Map<String, dynamic>;
      final presignedUrl = data['presigned_url'] as String;
      final publicUrl = data['public_url'] as String;

      // 2. PUT file bytes to presigned URL (no auth header)
      final contentType = _mimeTypeFromName(fileName);
      await _uploadDio.put(
        presignedUrl,
        data: Stream.fromIterable(fileBytes.map((e) => [e])),
        options: Options(
          headers: {
            Headers.contentTypeHeader: contentType,
            Headers.contentLengthHeader: fileBytes.length,
          },
        ),
        onSendProgress: onProgress != null
            ? (sent, total) => onProgress(total > 0 ? sent / total : 0)
            : null,
      );

      return Right(publicUrl);
    } on DioException catch (e) {
      final msg = _extractError(e);
      return Left(
        ServerFailure(messages: [msg], statusCode: e.response?.statusCode),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(messages: [e.message], statusCode: e.statusCode),
      );
    } on NetworkException catch (_) {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(messages: ['Upload failed: $e']));
    }
  }

  /// Uploads multiple files and returns their public URLs.
  Future<Either<Failure, List<String>>> uploadFiles({
    required List<({Uint8List bytes, String name})> files,
    required String bucket,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final result = await uploadFile(
        fileBytes: file.bytes,
        fileName: file.name,
        bucket: bucket,
      );
      final url = result.fold((f) => null, (url) => url);
      if (url == null) {
        return result.map((_) => <String>[]);
      }
      urls.add(url);
    }
    return Right(urls);
  }

  String _mimeTypeFromName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'avi' => 'video/x-msvideo',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List)[0].toString();
      }
    }
    if (data is List && data.isNotEmpty) return data[0].toString();
    return e.message ?? 'Upload failed';
  }
}
