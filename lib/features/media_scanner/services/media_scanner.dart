import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/media_data_source.dart';
import '../../../data/models/media_item.dart';
import '../../../services/media/media_service.dart';

/// Incremental MediaStore scanner. It upserts only newly-seen rows and marks
/// rows that disappeared from MediaStore as trashed — no full re-index each
/// run. Batches work to keep the UI responsive.
class MediaScanner {
  MediaScanner(this._ref);
  final Ref _ref;

  int _scanVersion = 0;
  bool _running = false;

  bool get isRunning => _running;

  /// Scans the device media and syncs the local DB. Returns the number of
  /// rows upserted.
  Future<int> scan() async {
    if (_running) return 0;
    _running = true;
    try {
      _scanVersion++;
      final albums = await MediaService.instance.getAlbums();
      var upserted = 0;
      for (final album in albums) {
        final name = album.name;
        var page = 0;
        while (true) {
          final assets = await album.getAssetListPaged(page: page, size: 200);
          if (assets.isEmpty) break;
          for (final a in assets) {
            final item = MediaItem.fromAsset(a, name);
            await MediaDataSource.instance.upsertScanRow(item, _scanVersion);
            upserted++;
          }
          if (assets.length < 200) break;
          page++;
        }
        // Yield to the event loop between albums.
        await Future.delayed(Duration.zero);
      }
      await MediaDataSource.instance.markMissingAsTrashed(_scanVersion);
      _ref.read(scanStateProvider.notifier).state = ScanState(
        lastScan: DateTime.now(),
        upserted: upserted,
        running: false,
      );
      return upserted;
    } finally {
      _running = false;
    }
  }
}

@immutable
class ScanState {
  const ScanState({this.lastScan, this.upserted = 0, this.running = false});
  final DateTime? lastScan;
  final int upserted;
  final bool running;
}

final scanStateProvider = StateProvider<ScanState>((_) => const ScanState());

final mediaScannerProvider = Provider<MediaScanner>((ref) => MediaScanner(ref));
