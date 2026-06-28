import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'api_service.dart';

class VideoPreloadResult {
  const VideoPreloadResult({
    required this.exerciseCount,
    required this.videoCount,
    required this.missingVideoCount,
    required this.cachedThumbnailCount,
    required this.failedThumbnailCount,
  });

  final int exerciseCount;
  final int videoCount;
  final int missingVideoCount;
  final int cachedThumbnailCount;
  final int failedThumbnailCount;
}

class VideoPreloadService {
  static Future<VideoPreloadResult> prepareExerciseVideos({
    void Function(int completed, int total)? onProgress,
  }) async {
    final exercises = await ApiService.getExercises();
    final videoIds = <String>{};
    var missingVideoCount = 0;

    for (final exercise in exercises) {
      final videoUrl = (exercise['videoUrl'] ?? '').toString().trim();
      final videoId = YoutubePlayer.convertUrlToId(videoUrl);

      if (videoUrl.isEmpty || videoId == null) {
        missingVideoCount++;
      } else {
        videoIds.add(videoId);
      }
    }

    var cachedThumbnailCount = 0;
    var failedThumbnailCount = 0;
    var completed = 0;

    onProgress?.call(completed, videoIds.length);

    for (final videoId in videoIds) {
      try {
        await _cacheThumbnail(videoId);
        cachedThumbnailCount++;
      } catch (_) {
        failedThumbnailCount++;
      } finally {
        completed++;
        onProgress?.call(completed, videoIds.length);
      }
    }

    return VideoPreloadResult(
      exerciseCount: exercises.length,
      videoCount: videoIds.length,
      missingVideoCount: missingVideoCount,
      cachedThumbnailCount: cachedThumbnailCount,
      failedThumbnailCount: failedThumbnailCount,
    );
  }

  static Future<void> _cacheThumbnail(String videoId) {
    final thumbnailUrl = YoutubePlayer.getThumbnail(
      videoId: videoId,
      quality: ThumbnailQuality.medium,
    );
    final imageProvider = NetworkImage(thumbnailUrl);
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (_, _) {
        stream.removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    stream.addListener(listener);

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        stream.removeListener(listener);
        throw TimeoutException('Tiempo agotado al preparar miniatura');
      },
    );
  }
}
