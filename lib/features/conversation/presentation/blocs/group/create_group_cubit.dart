import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_group_usecase.dart';

enum CreateStatus { idle, loading, success, failure }

class CreateGroupState extends Equatable {
  final CreateStatus status;
  final String? message;
  final String? error;

  const CreateGroupState({
    this.status = CreateStatus.idle,
    this.message,
    this.error,
  });

  CreateGroupState copyWith({
    CreateStatus? status,
    String? message,
    String? error,
  }) {
    return CreateGroupState(
      status: status ?? this.status,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, message, error];
}

class CreateGroupCubit extends Cubit<CreateGroupState> {
  final CreateGroupUseCase createGroupUseCase;
  CreateGroupCubit(this.createGroupUseCase) : super(const CreateGroupState());

  Future<void> submit({
    required String groupName,
    required String groupDescription,
    required int avatarId,
    required List<int> members,
  }) async {
    emit(state.copyWith(status: CreateStatus.loading, message: null, error: null));
    try {
      await createGroupUseCase.call(groupName, groupDescription, avatarId,members);
      emit(state.copyWith(status: CreateStatus.success, message: 'Tạo nhóm thành công'));
    } catch (e) {
      emit(state.copyWith(status: CreateStatus.failure, error: e.toString()));
    }
  }
}
