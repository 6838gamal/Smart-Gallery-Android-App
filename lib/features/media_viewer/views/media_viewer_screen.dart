import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/media_viewer_controller.dart';

class MediaViewerScreen extends ConsumerWidget {
  const MediaViewerScreen({super.key, required this.mediaId});
  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final asyncItem = ref.watch(mediaViewerProvider(mediaId));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l.editor,
            onPressed: () => context.go('/editor/$mediaId'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l.share,
            onPressed: () async {
              final item = asyncItem.valueOrNull;
              if (item == null) return;
              final file = await AssetEntity.fromId(item.id).then((a) => a?.file);
              if (file != null) await Share.shareXFiles([XFile(file.path)]);
            },
          ),
          IconButton(
            icon: Icon(asyncItem.valueOrNull?.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border),
            tooltip: l.favorite,
            onPressed: () => ref.read(mediaViewerProvider(mediaId).notifier).toggleFavorite(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.delete,
            onPressed: () async {
              await ref.read(mediaViewerProvider(mediaId).notifier).moveToTrash();
              if (context.mounted) context.go('/gallery');
            },
          ),
        ],
      ),
      body: asyncItem.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white))),
        data: (item) => _Body(item: item),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.item});
  final dynamic item;
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  VideoPlayerController? _video;
  TransformationController? _tc;

  @override
  void initState() {
    super.initState();
    if (widget.item.isVideo) {
      _initVideo();
    }
    _tc = TransformationController();
  }

  Future<void> _initVideo() async {
    final asset = await AssetEntity.fromId(widget.item.id);
    final file = await asset?.file;
    if (file != null && mounted) {
      _video = VideoPlayerController.file(File(file.path));
      await _video!.initialize();
      if (mounted) {
        _video!.setLooping(true);
        _video!.play();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    _tc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return PageView(
      children: [
        if (item.isVideo)
          _video != null && _video!.value.isInitialized
              ? Center(child: AspectRatio(aspectRatio: _video!.value.aspectRatio, child: VideoPlayer(_video!)))
              : const Center(child: CircularProgressIndicator())
          else
            InteractiveViewer(
              transformationController: _tc,
              maxScale: 5,
              child: Center(child: _image(item)),
        _Details(item: item),
      ],
    );
  }

  Widget _image(dynamic item) {
    return FutureBuilder<File?>(
      future: AssetEntity.fromId(item.id).then((a) => a?.file),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || snap.data == null) {
          return const CircularProgressIndicator(color: Colors.white);
        }
        return Image.file(snap.data!, fit: BoxFit.contain);
      },
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.item});
  final dynamic item;
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.details, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _row('Name', item.displayName as String),
        _row('Album', item.albumName as String),
        _row('Type', item.type.name.toUpperCase()),
        _row('Size', FileFormatters.bytes(item.sizeBytes as int)),
        _row('Date', DateFormatters.fullDate(item.createdAt as DateTime)),
        if (item.isVideo) _row('Duration', FileFormatters.duration(item.duration as Duration)),
        if (item.width != null) _row('Dimensions', '${item.width} x ${item.height}'),
        if (item.aiTags.isNotEmpty as bool) _row('AI tags', (item.aiTags as List).join(', ')),
      ],
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.white70))),
            Expanded(child: Text(v, style: const TextStyle(color: Colors.white))),
          ],
        ),
      );
}
