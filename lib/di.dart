
import 'package:chat_app/core/permissions/permission_service.dart';
import 'package:chat_app/core/service/downloader_service.dart';
import 'package:chat_app/core/service/image_picker_service.dart';
import 'package:chat_app/core/service/supabase_storage_service.dart';
import 'package:chat_app/features/chat/presentation/blocs/image_save_cubit.dart';
import 'package:chat_app/features/chat/presentation/blocs/out_going_call_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/router_app.dart';
import 'core/service/api_service.dart';
import 'core/service/fcm_service.dart';
import 'core/service/socket_service.dart';
import 'core/theme/theme_app.dart';
import 'features/chat/presentation/blocs/in_coming_call_cubit.dart';
import 'firebase_options.dart';

// ===== Auth =====
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/AuthRepositoryImpl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';

// ===== Conversation =====
import 'features/conversation/data/data_sources/conversation_remote_data_source.dart';
import 'features/conversation/data/repositories/conversation_repository_impl.dart';
import 'features/conversation/domain/usecases/fetch_conversation_usecase.dart';
import 'features/conversation/presentation/blocs/conversation/conversations_bloc.dart';

// ===== Chat =====
import 'features/chat/data/data_sources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/load_message_usecase.dart';
import 'features/chat/presentation/blocs/chat_bloc.dart';

// ===== Group =====
import 'features/conversation/data/data_sources/group_remote_data_source.dart';
import 'features/conversation/data/repositories/group_repository_impl.dart';
import 'features/conversation/domain/usecases/create_group_usecase.dart';
import 'features/conversation/domain/usecases/fetch_avatar_usecase.dart';
import 'features/conversation/domain/usecases/fetch_conversation_group_usecase.dart';
import 'features/conversation/presentation/blocs/group/avatars_cubit.dart';
import 'features/conversation/presentation/blocs/group/create_group_cubit.dart';
import 'features/conversation/presentation/blocs/conversation/conversation_group_cubit.dart';

// ===== Users =====
import 'features/conversation/data/data_sources/user_remote_data_source.dart';
import 'features/conversation/data/repositories/user_repository_impl.dart';
import 'features/conversation/domain/usecases/fetch_all_user_usecase.dart';
import 'features/conversation/presentation/blocs/user/users_cubit.dart';
import 'features/conversation/presentation/blocs/user/users_online_bloc.dart';

// ===== Friend (đã có module injection riêng) =====
import 'features/friend/friend_injection.dart';
import 'features/friend/presentation/blocs/friend_bloc.dart';

Future<void>  setupDI() async {
  final sl = GetIt.instance;

  // ----- Core -----
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<FcmService>(() => FcmService());
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // ----- Auth -----
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(apiService: sl<ApiService>()),
  );
  sl.registerLazySingleton<AuthRepositoryImpl>(
        () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton<SignUpUsecase>(() => SignUpUsecase(sl<AuthRepositoryImpl>()));
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<LoginUseCase>(), sl<SignUpUsecase>()));

  // ----- Conversation -----
  sl.registerLazySingleton<ConversationRemoteDataSource>(
        () => ConversationRemoteDataSource(apiService: sl<ApiService>()),
  );
  sl.registerLazySingleton<ConversationRepositoryImpl>(
        () => ConversationRepositoryImpl(remoteDataSource: sl<ConversationRemoteDataSource>()),
  );
  sl.registerLazySingleton<FetchAllConversationUsecase>(
        () => FetchAllConversationUsecase(sl<ConversationRepositoryImpl>()),
  );
  sl.registerFactory<ConversationBloc>(
        () => ConversationBloc(sl<FetchAllConversationUsecase>()),
  );

  // ----- Chat -----
  sl.registerLazySingleton<ChatRemoteDataSource>(
        () => ChatRemoteDataSource(apiService: sl<ApiService>()),
  );
  sl.registerLazySingleton<ChatRepositoryImpl>(
        () => ChatRepositoryImpl(remoteDataSource: sl<ChatRemoteDataSource>()),
  );
  sl.registerLazySingleton<LoadMessageUseCase>(
        () => LoadMessageUseCase(sl<ChatRepositoryImpl>()),
  );
  // sl.registerLazySingleton<ImagePickerService>(
  //     () => ImagePickerService()
  // );
  // sl.registerLazySingleton<SupabaseStorageService>(
  //     () => SupabaseStorageService()
  // );
  sl.registerFactory<ChatBloc>(() => ChatBloc(sl<LoadMessageUseCase>()
       // ,sl<ImagePickerService>(),sl<SupabaseStorageService>()
  ));
  //
  // sl.registerLazySingleton<PermissionService>(
  //     () => PermissionService()
  // );

  // sl.registerLazySingleton<DownloaderService>(
  //         () => DownloaderService(
  //           supabase: Supabase.instance.client,
  //           bucket: 'avatars'
  //         )
  // );

  // sl.registerFactory<ImageSaveCubit>(
  //         () => ImageSaveCubit(permissionService: sl<PermissionService>(), downloaderService: sl<DownloaderService>())
  // );


  sl.registerFactory<OutGoingCallCubit>(() => OutGoingCallCubit(sl<SocketService>()
    // ,sl<ImagePickerService>(),sl<SupabaseStorageService>()
  ));

  sl.registerFactory<InComingCallCubit>(() => InComingCallCubit(sl<SocketService>()
    // ,sl<ImagePickerService>(),sl<SupabaseStorageService>()
  ));

  // ----- Group -----
  sl.registerLazySingleton<GroupRemoteDataSource>(
        () => GroupRemoteDataSource(apiService: sl<ApiService>()),
  );
  sl.registerLazySingleton<GroupRepositoryImpl>(
        () => GroupRepositoryImpl(remoteDataSource: sl<GroupRemoteDataSource>()),
  );
  sl.registerLazySingleton<CreateGroupUseCase>(
        () => CreateGroupUseCase(sl<GroupRepositoryImpl>()),
  );
  sl.registerLazySingleton<FetchAllAvatarsUseCase>(
        () => FetchAllAvatarsUseCase(sl<GroupRepositoryImpl>()),
  );
  sl.registerLazySingleton<FetchConversationGroupUseCase>(
        () => FetchConversationGroupUseCase(sl<GroupRepositoryImpl>()),
  );
  sl.registerFactory<AvatarsCubit>(() => AvatarsCubit(sl<FetchAllAvatarsUseCase>()));
  sl.registerFactory<CreateGroupCubit>(() => CreateGroupCubit(sl<CreateGroupUseCase>()));
  sl.registerFactory<ConversationGroupCubit>(() =>
      ConversationGroupCubit(fetchConversationGroupUseCase: sl<FetchConversationGroupUseCase>()));

  // ----- Users -----
  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSource(sl<ApiService>()),
  );
  sl.registerLazySingleton<UserRepositoryImpl>(
        () => UserRepositoryImpl(remoteDataSource: sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton<FetchAllUserUseCase>(
        () => FetchAllUserUseCase(sl<UserRepositoryImpl>()),
  );
  sl.registerFactory<UsersCubit>(() => UsersCubit(userUseCase: sl<FetchAllUserUseCase>()));
  sl.registerFactory<UsersOnlineBloc>(() => UsersOnlineBloc(sl<SocketService>()));

  // ----- Friend module -----
  initFriendDependencies(); // hàm này tự register FriendBloc, repo… vào sl
}