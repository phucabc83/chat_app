// // image_compressor.dart
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
//
// /// Định dạng đầu ra
// enum OutputFormat { auto, jpeg, png }
//
// /// Tuỳ chọn nén
// class ImageCompressOptions {
//   /// Giới hạn kích thước theo trục dài (giữ tỉ lệ)
//   final int maxWidth;
//   final int maxHeight;
//
//   /// Mục tiêu dung lượng ~KB (<=0 nghĩa là bỏ qua mục tiêu dung lượng, chỉ resize/encode)
//   final int targetKB;
//
//   /// Nếu ảnh nhỏ hơn ngưỡng này (KB) thì giữ nguyên, không nén lại
//   final int minKeepKB;
//
//   /// Chất lượng JPEG (1..100)
//   final int startQuality;
//   final int minQuality;
//
//   /// Ưu tiên định dạng đầu ra
//   final OutputFormat format;
//
//   /// Mức nén PNG (0..9), cao hơn = nén mạnh hơn nhưng chậm hơn
//   final int pngLevel;
//
//   /// Bật sửa orientation theo EXIF nếu lib hỗ trợ
//   final bool fixOrientation;
//
//   const ImageCompressOptions({
//     this.maxWidth = 1280,
//     this.maxHeight = 1280,
//     this.targetKB = 300,     // mặc định ~300KB
//     this.minKeepKB = 200,    // dưới 200KB thì giữ nguyên
//     this.startQuality = 85,
//     this.minQuality = 40,
//     this.format = OutputFormat.auto,
//     this.pngLevel = 6,
//     this.fixOrientation = true,
//   })  : assert(maxWidth > 0 && maxHeight > 0),
//         assert(startQuality >= 1 && startQuality <= 100),
//         assert(minQuality >= 1 && minQuality <= 100),
//         assert(minQuality <= startQuality),
//         assert(pngLevel >= 0 && pngLevel <= 9);
// }
//
// /// Kết quả nén
// class CompressedImage {
//   final Uint8List bytes;
//   final String mimeType;      // 'image/jpeg', 'image/png'
//   final String suggestedExt;  // 'jpg', 'png'
//   final int width;
//   final int height;
//   final int qualityUsed;      // -1 nếu không áp dụng quality (PNG)
//
//   const CompressedImage({
//     required this.bytes,
//     required this.mimeType,
//     required this.suggestedExt,
//     required this.width,
//     required this.height,
//     required this.qualityUsed,
//   });
// }
//
// class ImageCompressor {
//   /// Nén ảnh từ bytes (web & mobile dùng chung)
//   static Future<CompressedImage> compressBytes(
//       Uint8List input, {
//         ImageCompressOptions options = const ImageCompressOptions(),
//       }) async {
//     // Nếu ảnh đã nhỏ hơn ngưỡng minKeepKB -> giữ nguyên
//     if (input.lengthInBytes <= options.minKeepKB * 1024) {
//       final decoded = img.decodeImage(input);
//       if (decoded == null) {
//         throw ArgumentError('Unsupported image format or decode failed');
//       }
//       return CompressedImage(
//         bytes: input,
//         mimeType: _guessMimeFromBytes(input) ?? 'application/octet-stream',
//         suggestedExt: 'jpg',
//         width: decoded.width,
//         height: decoded.height,
//         qualityUsed: -1,
//       );
//     }
//
//     // 1) Decode
//     final decoded = img.decodeImage(input);
//     if (decoded == null) {
//       throw ArgumentError('Unsupported image format or decode failed');
//     }
//
//     // 2) Sửa orientation (nếu có)
//     img.Image work = decoded;
//     if (options.fixOrientation) {
//       try {
//         work = img.bakeOrientation(work);
//       } catch (_) {}
//     }
//
//     // 3) Resize giữ tỉ lệ vào khung (maxW x maxH)
//     work = _resizeToFit(work, options.maxWidth, options.maxHeight);
//
//     // 4) Quyết định định dạng đầu ra
//     final bool hasAlpha = work.hasAlpha;
//     final OutputFormat outFmt = _decideFormat(
//       requested: options.format,
//       hasAlpha: hasAlpha,
//     );
//
//     // 5) Encode theo định dạng & mục tiêu dung lượng
//     switch (outFmt) {
//       case OutputFormat.png:
//         return _encodePng(work, options.pngLevel);
//       case OutputFormat.jpeg:
//         return _encodeLossyWithTarget(
//           work,
//           targetKB: options.targetKB,
//           startQ: options.startQuality,
//           minQ: options.minQuality,
//           encoder: (img.Image im, int q) =>
//               Uint8List.fromList(img.encodeJpg(im, quality: q)),
//           mime: 'image/jpeg',
//           ext: 'jpg',
//         );
//       case OutputFormat.auto:
//         throw StateError('Unexpected auto format at encoding step');
//     }
//   }
//
//   /// Gợi ý tên file mới theo phần mở rộng phù hợp
//   static String suggestFileName(String originalName, CompressedImage out) {
//     final base = (originalName.isEmpty ? 'image' : originalName)
//         .split('/')
//         .last
//         .split('\\')
//         .last;
//     final withoutExt = base.contains('.')
//         ? base.substring(0, base.lastIndexOf('.'))
//         : base;
//     return '$withoutExt.${out.suggestedExt}';
//   }
//
//   // ---------------- internal helpers ----------------
//
//   static img.Image _resizeToFit(img.Image src, int maxW, int maxH) {
//     final w = src.width, h = src.height;
//     if (w <= maxW && h <= maxH) return src;
//     final scaleW = maxW / w;
//     final scaleH = maxH / h;
//     final scale = scaleW < scaleH ? scaleW : scaleH; // theo trục dài
//     final newW = (w * scale).round();
//     final newH = (h * scale).round();
//     return img.copyResize(src, width: newW, height: newH);
//   }
//
//   static OutputFormat _decideFormat({
//     required OutputFormat requested,
//     required bool hasAlpha,
//   }) {
//     if (requested != OutputFormat.auto) return requested;
//     return hasAlpha ? OutputFormat.png : OutputFormat.jpeg;
//   }
//
//   static Future<CompressedImage> _encodePng(img.Image im, int level) async {
//     final bytes = Uint8List.fromList(img.encodePng(im, level: level));
//     return CompressedImage(
//       bytes: bytes,
//       mimeType: 'image/png',
//       suggestedExt: 'png',
//       width: im.width,
//       height: im.height,
//       qualityUsed: -1,
//     );
//   }
//
//   static Future<CompressedImage> _encodeLossyWithTarget(
//       img.Image im, {
//         required int targetKB,
//         required int startQ,
//         required int minQ,
//         required Uint8List Function(img.Image, int q) encoder,
//         required String mime,
//         required String ext,
//       }) async {
//     int q = startQ.clamp(1, 100);
//     Uint8List out = encoder(im, q);
//
//     // Nếu không cần nén hoặc ảnh đã nhỏ hơn target -> trả luôn
//     if (targetKB <= 0 || out.lengthInBytes <= targetKB * 1024) {
//       return CompressedImage(
//         bytes: out,
//         mimeType: mime,
//         suggestedExt: ext,
//         width: im.width,
//         height: im.height,
//         qualityUsed: q,
//       );
//     }
//
//     final int targetBytes = targetKB * 1024;
//     while (out.lengthInBytes > targetBytes && q > minQ) {
//       q = (q - 10).clamp(1, 100);
//       out = encoder(im, q);
//     }
//
//     return CompressedImage(
//       bytes: out,
//       mimeType: mime,
//       suggestedExt: ext,
//       width: im.width,
//       height: im.height,
//       qualityUsed: q,
//     );
//   }
//
//   static String? _guessMimeFromBytes(Uint8List bytes) {
//     if (bytes.length >= 4) {
//       if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
//       if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
//       if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
//     }
//     return null;
//   }
// }
