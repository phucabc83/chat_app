import 'dart:io';

import 'package:file_picker/file_picker.dart';

class ImagePickerService {


  Future<Map<String, dynamic>?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final fileName = result.files.first.name;
    final fileBytes = result.files.first.bytes;
    final filePath = result.files.first.path;

      return {
        'fileBytes': fileBytes,
        'fileName': fileName,
        'filePath': filePath,
      };



  }
}