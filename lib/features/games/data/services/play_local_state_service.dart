import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../domain/scorer/bowling_scorer.dart';
import '../../presentation/bloc/play_bloc.dart';

/// Persists in-progress [PlayState] to SharedPreferences keyed by
/// `sessionUid` so a force-close mid-game doesn't lose the scorecard.
///
/// Only the inputs the user provided are serialised — score is recomputed
/// on load via [computeGame]. Submitted-game / live broadcast / busy flags
/// are intentionally NOT persisted: those are recovered from the server.
@lazySingleton
class PlayLocalStateService {
  PlayLocalStateService(this._storage);

  final LocalStorageService _storage;

  static String _key(String sessionUid) => 'play_state:$sessionUid';

  /// Snapshot the user-driven slice of [state]. Called after every
  /// state-changing event in [PlayBloc]. Failures are swallowed — this is
  /// best-effort.
  Future<void> save(String sessionUid, PlayState state) async {
    try {
      final json = jsonEncode(_encode(state));
      await _storage.setString(_key(sessionUid), json);
    } catch (_) {/* best-effort */}
  }

  /// Load a previously saved state for [sessionUid], if any.
  /// Returns `null` if nothing is saved or the saved blob is corrupt.
  Future<PlayState?> load(String sessionUid) async {
    final raw = await _storage.getString(_key(sessionUid));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _decode(map);
    } catch (_) {
      return null;
    }
  }

  /// Drop the saved blob — called on submit success.
  Future<void> clear(String sessionUid) async {
    await _storage.remove(_key(sessionUid));
  }

  // ── encoding ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _encode(PlayState s) => {
        'v': 1,
        'frames': [
          for (final f in s.frames)
            [
              for (final d in f.deliveries)
                {
                  'pins': d.pinsStanding,
                  if (d.equipmentId != null) 'eq': d.equipmentId,
                },
            ],
        ],
        'cursor': {
          'frame': s.cursor.frameIndex,
          'delivery': s.cursor.deliveryIndex,
        },
        'handedness': s.handedness,
        'pinDefault': s.pinDefault.index,
        if (s.selectedBallId != null) 'selectedBallId': s.selectedBallId,
        'entryMode': s.entryMode.index,
        'gameNumber': s.gameNumber,
        'quickScoreDraft': s.quickScoreDraft,
      };

  PlayState _decode(Map<String, dynamic> map) {
    final framesRaw = map['frames'] as List?;
    final frames = List<FrameInput>.generate(
      10,
      (i) {
        if (framesRaw == null || i >= framesRaw.length) {
          return const FrameInput();
        }
        final delsRaw = framesRaw[i] as List? ?? const [];
        final dels = <Delivery>[];
        for (final d in delsRaw) {
          if (d is! Map) continue;
          final pinsRaw = d['pins'];
          if (pinsRaw is! List) continue;
          final pins = pinsRaw.whereType<int>().toList()..sort();
          final eq = d['eq'];
          dels.add(Delivery(
            pinsStanding: pins,
            equipmentId: eq is int ? eq : null,
          ));
        }
        return FrameInput(deliveries: dels);
      },
      growable: false,
    );

    final cursorRaw = map['cursor'] as Map<String, dynamic>? ?? const {};
    final cursor = PlayCursor(
      frameIndex: (cursorRaw['frame'] as int?)?.clamp(0, 10) ?? 0,
      deliveryIndex: (cursorRaw['delivery'] as int?) ?? 0,
    );

    final pinDefaultIdx = map['pinDefault'] as int?;
    final entryModeIdx = map['entryMode'] as int?;

    return PlayState(
      frames: frames,
      cursor: cursor,
      score: computeGame(frames),
      handedness: map['handedness'] as String? ?? 'Righty',
      pinDefault: pinDefaultIdx != null &&
              pinDefaultIdx >= 0 &&
              pinDefaultIdx < PinDefaultState.values.length
          ? PinDefaultState.values[pinDefaultIdx]
          : PinDefaultState.standing,
      selectedBallId: map['selectedBallId'] as int?,
      entryMode: entryModeIdx != null &&
              entryModeIdx >= 0 &&
              entryModeIdx < PlayEntryMode.values.length
          ? PlayEntryMode.values[entryModeIdx]
          : PlayEntryMode.full,
      gameNumber: (map['gameNumber'] as int?) ?? 1,
      quickScoreDraft: map['quickScoreDraft'] as String? ?? '',
    );
  }
}
