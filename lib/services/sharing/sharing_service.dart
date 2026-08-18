import 'package:share_plus/share_plus.dart';

/// Thin wrapper over `share_plus` for sharing one or many files by path.
class SharingService {
  SharingService._();
  static final SharingService instance = SharingService._();

  Future<void> sharePaths(List<String> paths, {String? subject}) async {
    if (paths.isEmpty) return;
    await Share.shareFiles(paths, subject: subject);
  }

  Future<void> shareText(String text) => Share.share(text);
}
