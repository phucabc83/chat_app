import 'package:chat_app/core/service/socket_service.dart';
import 'package:chat_app/features/social/domain/entities/comment.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_comments_usecase.dart';


class CommentsCubit extends Cubit<CommentsState> {
  final FetchCommentsUsecase fetchCommentsUsecase;
  final SocketService socketService;

  CommentsCubit(this.fetchCommentsUsecase, this.socketService): super(const CommentsState());

  Future<void> fetchComments(int postId) async {
    try {
      emit(state.copyWith(status: CommentsStatus.loading, error: null));
      final comments =  await fetchCommentsUsecase.call(postId);
      emit(state.copyWith(status: CommentsStatus.success, comments: comments));

      socketService.listenNewComment((comment) {
        print('New comment received via socket: $comment');
        final updatedComments = List<Comment>.from(state.comments)..add(comment);

        emit(state.copyWith(comments: updatedComments));
      });
    } catch (e) {
      emit(state.copyWith(status: CommentsStatus.failure, error: e.toString()));
    }
  }


}

enum CommentsStatus {
  initial,
  loading,
  success,
  failure,
}

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<Comment> comments;
  final String? error;
  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.error
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comment>? comments,
    String? error,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      error: error ?? this.error,
    );
  }


  @override
  // TODO: implement props
  List<Object?> get props => [status, comments, error];



  // Implementation of CommentsState
}