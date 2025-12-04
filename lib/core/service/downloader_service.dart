import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_saver/file_saver.dart';                   // Web + Desktop
import 'package:permission_handler/permission_handler.dart';   // Mobile


class DownloaderService {
  final SupabaseClient supabase;
  final String bucket;

  DownloaderService({
    required this.supabase,
    required this.bucket,
  });

  /// Tải ảnh từ Supabase Storage và lưu:
  /// - Mobile: vào Gallery
  /// - Web/Desktop: Save As... bằng FileSaver
  Future<bool> downloadImage(String path, {String? fileName}) async {
    try {
      final name  = _suggestName(path, fileName);
      final bytes = await _downloadBytesFromSupabase(path); // KHÔNG CORS

      final (ext, mime) = _guessExtMime(name);

      if (_isMobile) {
        final ok = await _ensureMediaPermission();
        if (!ok) return false;

        final res = await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 100,
          name: _stripExt(name),            // plugin tự thêm phần mở rộng theo bytes
          isReturnImagePathOfIOS: true,
        );
        return (res['isSuccess'] == true);
      }

      // Web + Desktop (FileSaver có web impl)
      await FileSaver.instance.saveFile(
        name: name,
        bytes: bytes,
        fileExtension: ext,                 // "jpg", "png", ...
        mimeType: _mapMimeType(mime),
      );
      return true;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return false;
    }
  }

  // === Supabase bytes (tránh CORS, không build URL tay) ===
  Future<Uint8List> _downloadBytesFromSupabase(String url) async {
    final path = formatSupabasePath(
      url,
      bucket: 'avatars',
    );
    final data = await supabase.storage.from(bucket).download(path);
    return Uint8List.fromList(data);
  }

  // ===== Helpers =====
  bool get _isMobile =>
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);

  /// Quyền ảnh: iOS & Android 13+ dùng `photos`; Android cũ có thể cần `storage`.
  Future<bool> _ensureMediaPermission() async {
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final st = await Permission.storage.request();
      if (st.isGranted) return true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final addOnly = await Permission.photosAddOnly.request();
      if (addOnly.isGranted) return true;
    }
    return false;
  }

  String _suggestName(String path, String? fileName) {
    if (fileName != null && fileName.trim().isNotEmpty) return fileName;
    final last = path.split('/').last;
    return last.contains('.') ? last : '$last.jpg';
  }

  String _stripExt(String name) {
    final i = name.lastIndexOf('.');
    return (i > 0) ? name.substring(0, i) : name;
  }

  /// Trả về (ext, mime) từ tên/path.
  (String, String) _guessExtMime(String nameOrUrl) {
    final s = nameOrUrl.toLowerCase();
    if (s.endsWith('.png'))  return ('png',  'image/png');
    if (s.endsWith('.webp')) return ('webp', 'image/webp');
    if (s.endsWith('.gif'))  return ('gif',  'image/gif');
    if (s.endsWith('.bmp'))  return ('bmp',  'image/bmp');
    if (s.endsWith('.heic')) return ('heic', 'image/heic');
    if (s.endsWith('.jpeg')) return ('jpeg','image/jpeg');
    // default jpg
    return ('jpg', 'image/jpeg');
  }

  /// Map string mime -> enum của file_saver
  MimeType _mapMimeType(String mime) {
    switch (mime) {
      case 'image/png':  return MimeType.png;
      case 'image/jpeg': return MimeType.jpeg;
      case 'image/gif':  return MimeType.other;
      case 'image/webp': return MimeType.other;
      case 'image/bmp':  return MimeType.other;
      case 'image/heic': return MimeType.other;
      default:           return MimeType.other;
    }
  }

  String formatSupabasePath(String input, {String? bucket}) {
    if (input.startsWith('http://') || input.startsWith('https://')) {
      final re = RegExp(r'/storage/v1/object/(public/)?([^/]+)/(.+)$');
      final m = re.firstMatch(input);
      if (m != null) {
        final urlBucket = m.group(2)!;   // bucket name trong URL
        final path = m.group(3)!;        // đường dẫn tương đối
        // Nếu truyền bucket thì check khớp, còn không thì cứ trả path
        if (bucket != null && bucket != urlBucket) {
          throw Exception(
              "Bucket mismatch: expected '$bucket' nhưng URL chứa '$urlBucket'");
        }
        return path;
      }
      throw Exception("URL không đúng format Supabase Storage: $input");
    }

    // Nếu chỉ truyền path tương đối thì trả về luôn
    return input;
  }
}
