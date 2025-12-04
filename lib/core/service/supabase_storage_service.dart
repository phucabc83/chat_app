import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService{

  final SupabaseClient _client = Supabase.instance.client;
  SupabaseStorageService();


  Future<String?> uploadFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      // Trả về public URL (nếu bucket public)
      return _client.storage.from(bucket).getPublicUrl(path);

    } on StorageException catch (e) {
      print('Upload error: ${e.message}');
      return null;
    }
  }


  Future<String?> uploadBinary({
    required bytes,
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: 'image/*'),
      );

      return _client.storage.from(bucket).getPublicUrl(path);

    } on StorageException catch (e) {
      print('Upload error: ${e.message}');
      return null;
    }
  }

  Future<String?> getSignedUrl(String bucket, String path, int expireInSec) async {
    final signedUrl = await _client.storage.from(bucket).createSignedUrl(path, expireInSec);
    return signedUrl;
  }

}