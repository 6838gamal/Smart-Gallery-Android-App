import 'package:flutter/material.dart';

/// Hand-maintained localization map. We avoid `flutter gen-l10n` codegen
/// (which needs the Flutter SDK at build time) by loading the same strings
/// directly here. The .arb files remain the source of truth; this file
/// mirrors them.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static Map<String, Map<String, String>> _values = {};

  static Future<void> load() async {
    _values = {
      'ar': _ar,
      'en': _en,
    };
  }

  String t(String key) => _values[locale.languageCode]?[key] ?? _en[key] ?? key;

  // ── getters used across the app ──
  String get appName => t('appName');
  String get gallery => t('gallery');
  String get albums => t('albums');
  String get search => t('search');
  String get favorites => t('favorites');
  String get trash => t('trash');
  String get settings => t('settings');
  String get security => t('security');
  String get editor => t('editor');
  String get backup => t('backup');
  String get aiSearch => t('aiSearch');
  String get aiSearchHint => t('aiSearchHint');
  String get searchHint => t('searchHint');
  String get sortByName => t('sortByName');
  String get sortByDate => t('sortByDate');
  String get sortBySize => t('sortBySize');
  String get sortByType => t('sortByType');
  String get sortByAlbum => t('sortByAlbum');
  String get sortAscending => t('sortAscending');
  String get sortDescending => t('sortDescending');
  String get sortBy => t('sortBy');
  String get createAlbum => t('createAlbum');
  String get albumName => t('albumName');
  String get rename => t('rename');
  String get delete => t('delete');
  String get hide => t('hide');
  String get unhide => t('unhide');
  String get restore => t('restore');
  String get deletePermanently => t('deletePermanently');
  String get share => t('share');
  String get favorite => t('favorite');
  String get unfavorite => t('unfavorite');
  String get details => t('details');
  String get crop => t('crop');
  String get rotate => t('rotate');
  String get flip => t('flip');
  String get brightness => t('brightness');
  String get contrast => t('contrast');
  String get saturation => t('saturation');
  String get filters => t('filters');
  String get saveAsNew => t('saveAsNew');
  String get cancel => t('cancel');
  String get save => t('save');
  String get done => t('done');
  String get ok => t('ok');
  String get confirm => t('confirm');
  String get noMedia => t('noMedia');
  String get noMediaHint => t('noMediaHint');
  String get noFavorites => t('noFavorites');
  String get noTrash => t('noTrash');
  String get permissionRequired => t('permissionRequired');
  String get permissionDenied => t('permissionDenied');
  String get grantPermission => t('grantPermission');
  String get openSettings => t('openSettings');
  String get lockApp => t('lockApp');
  String get unlock => t('unlock');
  String get enterPassword => t('enterPassword');
  String get setPassword => t('setPassword');
  String get confirmPassword => t('confirmPassword');
  String get biometricUnlock => t('biometricUnlock');
  String get passwordMismatch => t('passwordMismatch');
  String get wrongPassword => t('wrongPassword');
  String get themeMode => t('themeMode');
  String get light => t('light');
  String get dark => t('dark');
  String get system => t('system');
  String get language => t('language');
  String get arabic => t('arabic');
  String get english => t('english');
  String get fileCorrupted => t('fileCorrupted');
  String get unsupportedFormat => t('unsupportedFormat');
  String get aiNotAvailable => t('aiNotAvailable');
  String get aiSearching => t('aiSearching');
  String get editorError => t('editorError');
  String get saveSuccess => t('saveSuccess');
  String get saveFailed => t('saveFailed');
  String get scanning => t('scanning');
  String get items => t('items');
  String get item => t('item');
  String get videos => t('videos');
  String get images => t('images');
  String get today => t('today');
  String get yesterday => t('yesterday');
  String get selectItems => t('selectItems');
  String get selectAll => t('selectAll');
  String get selected => t('selected');
  String get moveToTrash => t('moveToTrash');
  String get movedToTrash => t('movedToTrash');
  String get restored => t('restored');
  String get deletedPermanently => t('deletedPermanently');
  String get deleteConfirm => t('deleteConfirm');
  String get trashConfirm => t('trashConfirm');
  String get restoreConfirm => t('restoreConfirm');
  String get noResults => t('noResults');
  String get tryDifferentSearch => t('tryDifferentSearch');
  String get backupNone => t('backupNone');
  String get backupConfigure => t('backupConfigure');
  String get loading => t('loading');
  String get retry => t('retry');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    await AppLocalizations.load();
    return AppLocalizations(locale);
  }
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Convenience extension so widgets can write `context.l.gallery`.
extension LocalizationsX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;
}

// ── string tables (mirrored from the .arb files) ──
const Map<String, String> _ar = {
  'appName': 'معرض الذكية',
  'gallery': 'المعرض',
  'albums': 'الألبومات',
  'search': 'بحث',
  'favorites': 'المفضلة',
  'trash': 'المحذوفات',
  'settings': 'الإعدادات',
  'security': 'الأمان',
  'editor': 'المحرر',
  'backup': 'النسخ الاحتياطي',
  'aiSearch': 'البحث الذكي',
  'aiSearchHint': 'ابحث بالوصف… مثل: صور قطط',
  'searchHint': 'ابحث بالاسم…',
  'sortByName': 'الاسم',
  'sortByDate': 'التاريخ',
  'sortBySize': 'الحجم',
  'sortByType': 'النوع',
  'sortByAlbum': 'الألبوم',
  'sortAscending': 'تصاعدي',
  'sortDescending': 'تنازلي',
  'sortBy': 'ترتيب حسب',
  'createAlbum': 'إنشاء ألبوم',
  'albumName': 'اسم الألبوم',
  'rename': 'إعادة تسمية',
  'delete': 'حذف',
  'hide': 'إخفاء',
  'unhide': 'إظهار',
  'restore': 'استعادة',
  'deletePermanently': 'حذف نهائي',
  'share': 'مشاركة',
  'favorite': 'مفضلة',
  'unfavorite': 'إزالة من المفضلة',
  'details': 'التفاصيل',
  'crop': 'اقتصاص',
  'rotate': 'تدوير',
  'flip': 'قلب',
  'brightness': 'السطوع',
  'contrast': 'التباين',
  'saturation': 'التشبع',
  'filters': 'الفلاتر',
  'saveAsNew': 'حفظ كصورة جديدة',
  'cancel': 'إلغاء',
  'save': 'حفظ',
  'done': 'تم',
  'ok': 'حسنا',
  'confirm': 'تأكيد',
  'noMedia': 'لا توجد وسائط',
  'noMediaHint': 'لم يتم العثور على صور أو فيديوهات',
  'noFavorites': 'لا توجد مفضلة',
  'noTrash': 'المحذوفات فارغة',
  'permissionRequired': 'الإذن مطلوب',
  'permissionDenied': 'تم رفض الإذن. لا يمكن عرض الوسائط بدون الوصول إلى التخزين.',
  'grantPermission': 'منح الإذن',
  'openSettings': 'فتح الإعدادات',
  'lockApp': 'قفل التطبيق',
  'unlock': 'فتح القفل',
  'enterPassword': 'أدخل كلمة المرور',
  'setPassword': 'تعيين كلمة المرور',
  'confirmPassword': 'تأكيد كلمة المرور',
  'biometricUnlock': 'فتح بالبصمة',
  'passwordMismatch': 'كلمتا المرور غير متطابقتين',
  'wrongPassword': 'كلمة المرور غير صحيحة',
  'themeMode': 'وضع المظهر',
  'light': 'فاتح',
  'dark': 'داكن',
  'system': 'النظام',
  'language': 'اللغة',
  'arabic': 'العربية',
  'english': 'الإنجليزية',
  'fileCorrupted': 'ملف تالف',
  'unsupportedFormat': 'صيغة غير مدعومة',
  'aiNotAvailable': 'البحث الذكي غير متاح حاليا',
  'aiSearching': 'جارٍ البحث الذكي…',
  'editorError': 'تعذّر تعديل الصورة',
  'saveSuccess': 'تم الحفظ بنجاح',
  'saveFailed': 'فشل الحفظ',
  'scanning': 'جارٍ فحص الوسائط…',
  'items': 'عنصر',
  'item': 'عنصر',
  'videos': 'فيديوهات',
  'images': 'صور',
  'today': 'اليوم',
  'yesterday': 'أمس',
  'selectItems': 'تحديد عناصر',
  'selectAll': 'تحديد الكل',
  'selected': 'محدد',
  'moveToTrash': 'نقل إلى المحذوفات',
  'movedToTrash': 'تم النقل إلى المحذوفات',
  'restored': 'تمت الاستعادة',
  'deletedPermanently': 'تم الحذف نهائيا',
  'deleteConfirm': 'هل تريد الحذف نهائيا؟ لا يمكن التراجع.',
  'trashConfirm': 'نقل إلى المحذوفات؟',
  'restoreConfirm': 'استعادة العنصر المحدد؟',
  'noResults': 'لا توجد نتائج',
  'tryDifferentSearch': 'جرّب كلمة أخرى',
  'backupNone': 'لم يتم إعداد نسخ احتياطي',
  'backupConfigure': 'إعداد النسخ الاحتياطي',
  'loading': 'جارٍ التحميل…',
  'retry': 'إعادة المحاولة',
};

const Map<String, String> _en = {
  'appName': 'Smart Gallery',
  'gallery': 'Gallery',
  'albums': 'Albums',
  'search': 'Search',
  'favorites': 'Favorites',
  'trash': 'Trash',
  'settings': 'Settings',
  'security': 'Security',
  'editor': 'Editor',
  'backup': 'Backup',
  'aiSearch': 'AI Search',
  'aiSearchHint': 'Search by description… e.g. cats',
  'searchHint': 'Search by name…',
  'sortByName': 'Name',
  'sortByDate': 'Date',
  'sortBySize': 'Size',
  'sortByType': 'Type',
  'sortByAlbum': 'Album',
  'sortAscending': 'Ascending',
  'sortDescending': 'Descending',
  'sortBy': 'Sort by',
  'createAlbum': 'Create album',
  'albumName': 'Album name',
  'rename': 'Rename',
  'delete': 'Delete',
  'hide': 'Hide',
  'unhide': 'Unhide',
  'restore': 'Restore',
  'deletePermanently': 'Delete permanently',
  'share': 'Share',
  'favorite': 'Favorite',
  'unfavorite': 'Unfavorite',
  'details': 'Details',
  'crop': 'Crop',
  'rotate': 'Rotate',
  'flip': 'Flip',
  'brightness': 'Brightness',
  'contrast': 'Contrast',
  'saturation': 'Saturation',
  'filters': 'Filters',
  'saveAsNew': 'Save as new image',
  'cancel': 'Cancel',
  'save': 'Save',
  'done': 'Done',
  'ok': 'OK',
  'confirm': 'Confirm',
  'noMedia': 'No media',
  'noMediaHint': 'No photos or videos found',
  'noFavorites': 'No favorites',
  'noTrash': 'Trash is empty',
  'permissionRequired': 'Permission required',
  'permissionDenied': 'Permission denied. Cannot show media without storage access.',
  'grantPermission': 'Grant permission',
  'openSettings': 'Open settings',
  'lockApp': 'Lock app',
  'unlock': 'Unlock',
  'enterPassword': 'Enter password',
  'setPassword': 'Set password',
  'confirmPassword': 'Confirm password',
  'biometricUnlock': 'Unlock with biometric',
  'passwordMismatch': 'Passwords do not match',
  'wrongPassword': 'Wrong password',
  'themeMode': 'Theme mode',
  'light': 'Light',
  'dark': 'Dark',
  'system': 'System',
  'language': 'Language',
  'arabic': 'Arabic',
  'english': 'English',
  'fileCorrupted': 'Corrupted file',
  'unsupportedFormat': 'Unsupported format',
  'aiNotAvailable': 'AI search is not available right now',
  'aiSearching': 'AI searching…',
  'editorError': 'Could not edit the image',
  'saveSuccess': 'Saved successfully',
  'saveFailed': 'Save failed',
  'scanning': 'Scanning media…',
  'items': 'items',
  'item': 'item',
  'videos': 'Videos',
  'images': 'Photos',
  'today': 'Today',
  'yesterday': 'Yesterday',
  'selectItems': 'Select items',
  'selectAll': 'Select all',
  'selected': 'selected',
  'moveToTrash': 'Move to trash',
  'movedToTrash': 'Moved to trash',
  'restored': 'Restored',
  'deletedPermanently': 'Deleted permanently',
  'deleteConfirm': 'Delete permanently? This cannot be undone.',
  'trashConfirm': 'Move to trash?',
  'restoreConfirm': 'Restore the selected item?',
  'noResults': 'No results',
  'tryDifferentSearch': 'Try another keyword',
  'backupNone': 'No backup configured',
  'backupConfigure': 'Configure backup',
  'loading': 'Loading…',
  'retry': 'Retry',
};
