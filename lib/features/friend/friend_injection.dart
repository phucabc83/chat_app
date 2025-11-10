import 'package:chat_app/core/service/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/data_sources/friend_remote_data_source.dart';
import 'data/data_sources/friend_remote_data_source_impl.dart';
import 'data/repositories/friend_repository_impl.dart';
import 'domain/repositories/friend_repository.dart';
import 'domain/usecases/get_friends_usecase.dart';
import 'domain/usecases/get_friend_requests_usecase.dart';
import 'domain/usecases/send_friend_request_usecase.dart';
import 'domain/usecases/accept_friend_request_usecase.dart';
import 'domain/usecases/reject_friend_request_usecase.dart';
import 'domain/usecases/remove_friend_usecase.dart';
import 'domain/usecases/block_friend_usecase.dart';
import 'domain/usecases/unblock_friend_usecase.dart';
import 'domain/usecases/get_blocked_friends_usecase.dart';
import 'domain/usecases/cancel_friend_request_usecase.dart';
import 'domain/usecases/search_users_usecase.dart';
import 'presentation/blocs/friend_bloc.dart';

final sl = GetIt.instance;

void initFriendDependencies() {

  // Data sources
  sl.registerLazySingleton<FriendRemoteDataSource>(
    () => FriendRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<FriendRepository>(
    () => FriendRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFriendsUseCase(sl()));
  sl.registerLazySingleton(() => GetFriendRequestsUseCase(sl()));
  sl.registerLazySingleton(() => SendFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFriendUseCase(sl()));
  sl.registerLazySingleton(() => BlockFriendUseCase(sl()));
  sl.registerLazySingleton(() => UnblockFriendUseCase(sl()));
  sl.registerLazySingleton(() => GetBlockedFriendsUseCase(sl()));
  sl.registerLazySingleton(() => CancelFriendRequestUseCase(sl()));
  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => FriendBloc(
      getFriendsUseCase: sl(),
      getFriendRequestsUseCase: sl(),
      sendFriendRequestUseCase: sl(),
      acceptFriendRequestUseCase: sl(),
      rejectFriendRequestUseCase: sl(),
      removeFriendUseCase: sl(),
      blockFriendUseCase: sl(),
      searchUsersUseCase: sl(),
    ),
  );
}
