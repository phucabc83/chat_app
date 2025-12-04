import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

class ImagePickerService {


  Future<Map<String, dynamic>?> pickImage() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true
    );

    if (result == null || result.files.isEmpty) return null;

    final fileName = result.files.first.name;
    final fileBytes = result.files.first.bytes;
    final filePath = result.files.first.path;

    debugPrint(
        'ImagePickerService: pickImage: fileName=$fileName, filePath=$filePath filebytes=$fileBytes'
    );

      return {
        'fileBytes': fileBytes,
        'fileName': fileName,
        'filePath': filePath,
      };



  }
}