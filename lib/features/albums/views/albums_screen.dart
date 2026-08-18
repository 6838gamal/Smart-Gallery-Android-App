import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/albums_controller.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(albumsControllerProvider);
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.albums)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreate(context, ref),
        child: const Icon(Icons.create_new_folder_outlined),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.albums.isEmpty
              ? _Empty(l: l)
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.albums.length,
                  itemBuilder: (context, index) {
                    final album = state.albums[index];
                    return _AlbumCard(album: album);
                  },
                ),
    );
  }

  Future<void> _showCreate(BuildContext context, WidgetRef ref) async {
    final name = await _textDialog(context, context.l.createAlbum, context.l.albumName);
    if (name != null && name.isNotEmpty) {
      ref.read(albumsControllerProvider.notifier).createAlbum(name);
    }
  }

  Future<String?> _textDialog(BuildContext context, String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l.ok),
          ),
        ],
      ),
    );
  }
}

class _AlbumCard extends ConsumerWidget {
  const _AlbumCard({required this.album});
  final dynamic album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return GestureDetector(
      onTap: () => context.go('/album/${album.id}'),
      onLongPress: () => _showOptions(context, ref),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.neutral200),
            if (album.coverId != null)
              const Center(child: Icon(Icons.folder, size: 48, color: AppColors.neutral400)),
            if (album.coverId == null)
              const Center(child: Icon(Icons.folder_outlined, size: 48, color: AppColors.neutral400)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(album.name as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Text('${album.count} ${l.items}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            if (album.isHidden)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.visibility_off, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOptions(BuildContext context, WidgetRef ref) async {
    final l = context.l;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.rename),
            onTap: () => Navigator.pop('rename'),
          ),
          ListTile(
            leading: Icon(album.isHidden ? Icons.visibility : Icons.visibility_off),
            title: Text(album.isHidden ? l.unhide : l.hide),
            onTap: () => Navigator.pop('toggleHidden'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(l.delete),
            onTap: () => Navigator.pop('delete'),
          ),
        ],
      ),
    );
    final c = ref.read(albumsControllerProvider.notifier);
    if (action == 'rename') {
      final name = await _textDialog(context, l.rename, l.albumName, initial: album.name as String);
      if (name != null && name.isNotEmpty) c.rename(album.id as String, name);
    } else if (action == 'toggleHidden') {
      c.toggleHidden(album as dynamic);
    } else if (action == 'delete') {
      c.delete(album.id as String);
    }
  }

  Future<String?> _textDialog(BuildContext context, String title, String hint, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: hint), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(context.l.ok)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l});
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 72, color: AppColors.neutral400),
          const SizedBox(height: 16),
          Text(l.noMedia, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
