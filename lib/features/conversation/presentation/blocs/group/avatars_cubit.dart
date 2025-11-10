import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/avatar.dart';
import '../../../domain/usecases/fetch_avatar_usecase.dart';

class AvatarsState extends Equatable {
  final bool loading;
  final List<Avatar> data;
  final String? error;
  final bool isUserAvatars;

  const AvatarsState({
    this.loading = false,
    this.data = const [],
    this.error,
    this.isUserAvatars = false,
  });

  AvatarsState copyWith({
    bool? loading,
    List<Avatar>? data,
    String? error,
    bool? isUserAvatars,
  }) {
    return AvatarsState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
      isUserAvatars: isUserAvatars ?? this.isUserAvatars,
    );
  }

  @override
  List<Object?> get props => [loading, data, error];

  @override
  String toString() {
    // TODO: implement toString
    return 'AvatarsState(loading: $loading, data: $data, error: $error)';
  }
}

class AvatarsCubit extends Cubit<AvatarsState> {
  final FetchAllAvatarsUseCase fetchAllAvatarsUseCase;
  AvatarsCubit(this.fetchAllAvatarsUseCase) : super(const AvatarsState());

  Future<void> load({bool isUserAvatars = false}) async {
    emit(state.copyWith(loading: true, error: null));
    try {

      final list =  isUserAvatars ? await fetchAllAvatarsUseCase.callUserAvatars() :  await fetchAllAvatarsUseCase.call();
      emit(state.copyWith(loading: false, data:  list, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh() => load();
}
