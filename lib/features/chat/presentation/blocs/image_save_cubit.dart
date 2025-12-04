import 'package:chat_app/core/permissions/permission_service.dart';
import 'package:chat_app/core/service/downloader_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'image_save_state.dart';

class ImageSaveCubit extends Cubit<ImageSaveState>{
  final PermissionService permissionService;
  final DownloaderService downloaderService;

  ImageSaveCubit({
    required this.permissionService,
    required this.downloaderService,
  }) : super(ImageSaveState.initial()) {
    debugPrint("✅ ImageSaveCubit constructor initialized");
  }

  Future<void> saveImage(String url) async {
    emit(state.copyWith(status: ImageSaveStatus.saving, error: null));
    try {
      debugPrint('✅ Image saved started for URL: $url');

      if(!kIsWeb){
        final photoPermission = await permissionService.requestPhotoPermission();
        final storagePermission = await permissionService.requestStoragePermission();
        final hasPermission = photoPermission && storagePermission;

        debugPrint('✅ Image saved hasPermission: $photoPermission and $storagePermission');
        if (!hasPermission) {
          emit(state.copyWith(status: ImageSaveStatus.failure, error: 'Vui lòng cấp quyền lưu ảnh'));
          return;
        }

      }

      final success = await downloaderService.downloadImage(url);
      debugPrint('✅ Image saved: $success');
      if (success) {
        emit(state.copyWith(status: ImageSaveStatus.success));
      } else {
        emit(state.copyWith(status: ImageSaveStatus.failure, error: 'Lưu ảnh thất bại'));
      }
    } catch (e) {
      emit(state.copyWith(status: ImageSaveStatus.failure, error: e.toString()));
      debugPrint('❌ Error saving image: $e');
    }
  }

}