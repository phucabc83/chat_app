import 'dart:typed_data';

import 'package:chat_app/core/permissions/permission_service.dart';
import 'package:chat_app/core/service/image_picker_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service/image_compressor.dart';
import '../../domain/usecases/create_post_usecase.dart';



class CreatePostsCubit extends Cubit<CreatePostsState> {
  final CreatePostUseCase createPostUseCase;
  final PermissionService permissionService;
  final ImagePickerService imagePickerService;


  CreatePostsCubit({
    required this.createPostUseCase,
    required this.permissionService,
    required this.imagePickerService,
  }) : super( CreatePostsState());


  Future<void> createPost({required String content}) async {
    try {
      emit(state.copyWith(status: CreatePostStatus.submitting, error: null));
      final post = await createPostUseCase.execute(
        content: content,
        fileBytes: state.imageBytes,
        fileNameImage: state.imagePath,
        mimeType: state.mimeType,
      );
      emit(state.copyWith(status: CreatePostStatus.success));
    } catch (e) {
      print('❌ [CreatePostsCubit] Error creating post: $e');
      emit(state.copyWith(status: CreatePostStatus.failure, error: e.toString()));
    }
  }


  Future<void> chooseImage() async {
      var granted = await permissionService.requestPhotoPermission();
      if(!granted){
        emit(
            state.copyWith(
              status: CreatePostStatus.failure,
              error: 'Storage permission denied.',
            )
        );
      }

      final imageData = await imagePickerService.pickImage();

      if(imageData == null) return;

      // 2) Compress (ví dụ mục tiêu ~80KB, khung 1080p, auto format)
      final out = await ImageCompressor.compressBytes(
        imageData['fileBytes'] ,
        options: const ImageCompressOptions(
          targetKB: 80,
          maxWidth: 1080,
          maxHeight: 1080,
          startQuality: 85,
          minQuality: 40,
          format: OutputFormat.auto, // PNG nếu có alpha, JPEG nếu không
        ),
      );

      // 3) Gợi ý tên file & upload
      final newName = ImageCompressor.suggestFileName(imageData['fileName'], out);


      debugPrint(
        '🟢 [CreatePostsCubit] Image picked: Path=${imageData['filePath']}, Size=${(imageData['fileBytes'] as Uint8List).lengthInBytes} bytes',
      );

      emit(
          state.copyWith(
            status: CreatePostStatus.pickedImage,
            imageBytes:out.bytes,
            imagePath: imageData['filePath'],
            mimeType: out.mimeType
          )
      );




  }
}

enum CreatePostStatus { initial, pickedImage, submitting, success, failure }

class CreatePostsState extends Equatable {
  final CreatePostStatus status;
  final Uint8List? imageBytes;
  final String? imagePath;
  final String? imageUrl; // nếu upload trả về url
  final String? error;
  final String? mimeType;
  const CreatePostsState({
    this.status = CreatePostStatus.initial,
    this.imageBytes,
    this.imagePath,
    this.imageUrl,
    this.error,
    this.mimeType,
  });

  CreatePostsState copyWith({
    String? content,
    Uint8List? imageBytes,
    String? imagePath,
    String? imageUrl,
    String? error,
    CreatePostStatus? status,
    String? mimeType,
  }) {
    return CreatePostsState(
      imageBytes: imageBytes ?? this.imageBytes,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      error: error ?? this.error,
      status: status ?? this.status,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  List<Object?> get props => [ imageBytes, imagePath, imageUrl, error, mimeType,status];
}

