import 'dart:typed_data';

import '../entities/post.dart';
import '../repositories/social_repository.dart';

class CreatePostUseCase {
  final SocialRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> execute({required String content, Uint8List? fileBytes,String? fileNameImage,String? mimeType}) async {
    return await repository.createPost(
      content: content,
      fileBytes: fileBytes,
      fileNameImage: fileNameImage,
      mimeType: mimeType,
    );
  }
}

