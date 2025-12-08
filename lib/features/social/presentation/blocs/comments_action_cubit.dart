import 'package:chat_app/features/social/domain/usecases/create_comment_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/comment_post_usecase.dart';

class CommentsActionCubit extends Cubit<CommentsActionState> {
  final CreateCommentUseCase commentPostUseCase;
  CommentsActionCubit(this.commentPostUseCase) : super(const CommentsActionState());

  Future<void> addComment(int postId, String content) async {
    try {
      emit(state.copyWith(status: CommentsActionStatus.loading, error: null));
      final comment = await commentPostUseCase.call(postId, content);
      emit(state.copyWith(status: CommentsActionStatus.success, content: content));
    } catch (e) {
      emit(state.copyWith(status: CommentsActionStatus.failure, error: e.toString()));
    }
  }

}

enum CommentsActionStatus {
  initial,
  loading,
  success,
  failure,
}
class CommentsActionState extends Equatable {
  final CommentsActionStatus status;
  final String? content;
  final String? error;
  const CommentsActionState({
    this.status = CommentsActionStatus.initial,
    this.content,
    this.error,
  });


  CommentsActionState copyWith({
    CommentsActionStatus? status,
    String? content,
    String? error,
  }) {
    return CommentsActionState(
      status: status ?? this.status,
      content: content ?? this.content,
      error: error ?? this.error,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, content, error];



  // Implementation of CommentsState
}