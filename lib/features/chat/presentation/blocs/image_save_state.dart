import 'package:equatable/equatable.dart';

enum ImageSaveStatus { initial, saving, success, failure }


class ImageSaveState extends Equatable{
  final ImageSaveStatus status;
  final String? errorMessage;

  const ImageSaveState({
    required this.status,
    this.errorMessage,
  });

  const ImageSaveState.initial()
      : status = ImageSaveStatus.initial,
        errorMessage = null;





  ImageSaveState copyWith({
    ImageSaveStatus? status,
    String? error,
  }) {
    return ImageSaveState(
      status: status ?? this.status,
      errorMessage: error,
    );
  }
  @override
  List<Object?> get props => [status, errorMessage];
}