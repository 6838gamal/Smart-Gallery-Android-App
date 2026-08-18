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
  final dynamic item; // يمكن تحسينه لاحقاً باستخدام نوع مخصص
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  VideoPlayerController? _video;
  TransformationController? _tc;

  @override
  void initState() {
    super.initState();
    // تحقق مما إذا كان العنصر فيديو قبل تهيئته
    if (widget.item.isVideo == true) {
      _initVideo();
    }
    _tc = TransformationController();
  }

  Future<void> _initVideo() async {
    try {
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
    } catch (e) {
      print('Error initializing video: $e');
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
    
    // فصل الأجزاء إلى قائمة
    final List<Widget> pages = [];
    
    // إضافة صفحة العرض الرئيسية
    pages.add(
      item.isVideo == true
          ? _video != null && _video!.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _video!.value.aspectRatio,
                    child: VideoPlayer(_video!),
                  ),
                )
              : const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              transformationController: _tc,
              maxScale: 5.0,
              minScale: 0.5,
              child: Center(
                child: _ImageWidget(item: item),
              ),
            ),
    );
    
    // إضافة صفحة التفاصيل
    pages.add(
      _Details(item: item),
    );
    
    return PageView(
      children: pages,
    );
  }
}

// فصل widget الصورة إلى Class منفصل
class _ImageWidget extends StatefulWidget {
  const _ImageWidget({required this.item});
  final dynamic item;

  @override
  State<_ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<_ImageWidget> {
  Future<File?>? _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = AssetEntity.fromId(widget.item.id).then((a) => a?.file);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator(color: Colors.white);
        }
        if (snapshot.data == null) {
          return const Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white),
          );
        }
        return Image.file(
          snapshot.data!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Error loading image',
              style: TextStyle(color: Colors.white),
            );
          },
        );
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
        Text(
          l.details,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _row('Name', item.displayName?.toString() ?? 'Unknown'),
        _row('Album', item.albumName?.toString() ?? 'Unknown'),
        _row('Type', item.type?.name?.toUpperCase() ?? 'Unknown'),
        _row('Size', _formatBytes(item.sizeBytes)),
        _row('Date', _formatDate(item.createdAt)),
        if (item.isVideo == true) 
          _row('Duration', _formatDuration(item.duration)),
        if (item.width != null) 
          _row('Dimensions', '${item.width} x ${item.height}'),
        if (item.aiTags?.isNotEmpty == true) 
          _row('AI tags', (item.aiTags as List).join(', ')),
      ],
    );
  }

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return 'Unknown';
    try {
      return FileFormatters.bytes(bytes as int);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      return DateFormatters.fullDate(date as DateTime);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return 'Unknown';
    try {
      return FileFormatters.duration(duration as Duration);
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _row(String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                key,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
}
