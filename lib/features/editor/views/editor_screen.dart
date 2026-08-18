import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../app/localization/app_localizations.dart';
import '../controllers/editor_controller.dart';
import '../services/editor_service.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key, required this.mediaId});
  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final asyncState = ref.watch(editorProvider(mediaId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.editor),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: l.saveAsNew,
            onPressed: () async {
              try {
                await ref.read(editorProvider(mediaId).notifier).save();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.saveSuccess)));
                  context.go('/gallery');
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.saveFailed)));
                }
              }
            },
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.editorError)),
        data: (s) => _EditorBody(state: s, mediaId: mediaId),
      ),
    );
  }
}

class _EditorBody extends ConsumerWidget {
  const _EditorBody({required this.state, required this.mediaId});
  final EditorState state;
  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return Column(
      children: [
        Expanded(child: Center(child: _Image(image: state.current))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(label: Text(l.rotate), onPressed: () => ref.read(editorProvider(mediaId).notifier).rotate()),
              ActionChip(label: Text(l.flip), onPressed: () => ref.read(editorProvider(mediaId).notifier).flip()),
              ActionChip(label: Text(l.filters), onPressed: () => _filterSheet(context, ref)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _Slider(label: l.brightness, value: state.brightness, min: -50, max: 50, onChanged: (v) => ref.read(editorProvider(mediaId).notifier).adjust(brightness: v)),
              _Slider(label: l.contrast, value: state.contrast, min: -50, max: 50, onChanged: (v) => ref.read(editorProvider(mediaId).notifier).adjust(contrast: v)),
              _Slider(label: l.saturation, value: state.saturation, min: -50, max: 50, onChanged: (v) => ref.read(editorProvider(mediaId).notifier).adjust(saturation: v)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _filterSheet(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final f = await showModalBottomSheet<EditorFilter>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(l.filters), enabled: false),
          for (final filter in EditorFilter.values)
            ListTile(
              title: Text(filter.name),
              leading: Icon(state.activeFilter == filter ? Icons.check : null),
              onTap: () => Navigator.pop(filter),
            ),
        ],
      ),
    );
    if (f != null) ref.read(editorProvider(mediaId).notifier).applyFilter(f);
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.image});
  final img.Image image;

  @override
  Widget build(BuildContext context) {
    final png = Uint8List.fromList(img.encodePng(image));
    return InteractiveViewer(maxScale: 4, child: Image.memory(png, fit: BoxFit.contain));
  }
}

class _Slider extends StatelessWidget {
  const _Slider({required this.label, required this.value, required this.onChanged, required this.min, required this.max});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: Slider(min: min, max: max, value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
