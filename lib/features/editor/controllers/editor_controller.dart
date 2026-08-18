import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

import '../../../data/datasources/media_data_source.dart';
import '../services/editor_service.dart';

class EditorController extends FamilyAsyncNotifier<EditorState, String> {
  @override
  Future<EditorState> build(String mediaId) async {
    final item = await MediaDataSource.instance.getById(mediaId);
    if (item == null) throw StateError('Media not found');
    final asset = await AssetEntity.fromId(mediaId);
    final file = await asset?.file;
    if (file == null) throw StateError('File unavailable');
    final image = await EditorService.instance.load(File(file.path));
    return EditorState(original: image, current: image, baseName: item.displayName);
  }

  void rotate() {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final next = EditorService.instance.rotate(cur.current, degrees: 90);
    state = AsyncData(cur.copyWith(current: next));
  }

  void flip() {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final next = EditorService.instance.flipHorizontal(cur.current);
    state = AsyncData(cur.copyWith(current: next));
  }

  void applyFilter(EditorFilter f) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final next = EditorService.instance.applyFilter(cur.original, filter: f);
    state = AsyncData(cur.copyWith(current: next, activeFilter: f));
  }

  void adjust({double? brightness, double? contrast, double? saturation}) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final next = EditorService.instance.adjust(
      src: cur.original,
      brightness: brightness ?? cur.brightness,
      contrast: contrast ?? cur.contrast,
      saturation: saturation ?? cur.saturation,
    );
    state = AsyncData(cur.copyWith(
      current: next,
      brightness: brightness ?? cur.brightness,
      contrast: contrast ?? cur.contrast,
      saturation: saturation ?? cur.saturation,
    ));
  }

  Future<String> save() async {
    final cur = state.valueOrNull;
    if (cur == null) throw StateError('Nothing to save');
    return EditorService.instance.saveAsNew(cur.current, cur.baseName);
  }
}

class EditorState {
  const EditorState({
    required this.original,
    required this.current,
    required this.baseName,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.activeFilter = EditorFilter.none,
  });
  final img.Image original;
  final img.Image current;
  final String baseName;
  final double brightness;
  final double contrast;
  final double saturation;
  final EditorFilter activeFilter;

  EditorState copyWith({
    img.Image? current,
    double? brightness,
    double? contrast,
    double? saturation,
    EditorFilter? activeFilter,
  }) =>
      EditorState(
        original: original,
        current: current ?? this.current,
        baseName: baseName,
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        saturation: saturation ?? this.saturation,
        activeFilter: activeFilter ?? this.activeFilter,
      );
}

final editorProvider =
    AsyncNotifierProvider.family<EditorController, EditorState, String>(
  EditorController.new,
);
