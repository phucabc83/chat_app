import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
//
// class PermissionService{
//   Future<bool> requestStoragePermission() async {
//     final checkPermission = await checkStoragePermission();
//     if(checkPermission) return true;
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.request();
//       return status.isGranted;
//     }
//     return true; // iOS không có storage permission
//   }
//
//   Future<bool> checkStoragePermission() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.storage.status;
//       return status.isGranted;
//     }
//     return true; // iOS không có storage permission
//   }
//   Future<bool> checkPhotoPermission() async {
//
//     if (Platform.isAndroid) {
//       final status = await Permission.photos.status;
//       return status.isGranted;
//     } else if (Platform.isIOS) {
//       final status = await Permission.photosAddOnly.status;
//       return status.isGranted;
//     }
//     return true;
//   }
//
//   Future<bool> requestPhotoPermission() async {
//
//     final checkPermission = await checkPhotoPermission();
//     if(checkPermission) return true;
//
//     if (Platform.isAndroid) {
//       final status = await Permission.photos.request();
//       return status.isGranted;
//     } else if (Platform.isIOS) {
//       final status = await Permission.photosAddOnly.request();
//       return status.isGranted;
//     }
//     return true;
//   }
// }