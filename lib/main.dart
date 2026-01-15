import 'package:chat_app/features/chat/presentation/blocs/suggest_model_cubit.dart';
import 'package:chat_app/features/social/presentation/blocs/posts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/service/api_service.dart';
import 'core/service/fcm_service.dart';
import 'core/service/notify_helper.dart';
import 'core/service/socket_service.dart';
import 'core/utils/util.dart';

import 'core/routes/router_app.dart';
import 'core/theme/theme_app.dart';
import 'di.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/chat/presentation/blocs/chat_bloc.dart';
import 'features/chat/presentation/blocs/in_coming_call_cubit.dart';
import 'features/conversation/presentation/blocs/conversation/conversation_group_cubit.dart';
import 'features/conversation/presentation/blocs/conversation/conversations_bloc.dart';
import 'features/conversation/presentation/blocs/group/avatars_cubit.dart';
import 'features/conversation/presentation/blocs/group/create_group_cubit.dart';
import 'features/conversation/presentation/blocs/user/users_cubit.dart';
import 'features/conversation/presentation/blocs/user/users_online_bloc.dart';
import 'features/friend/presentation/blocs/friend_bloc.dart';
import 'firebase_options.dart';


final sl = GetIt.instance;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  const storage = FlutterSecureStorage();
  Util.token      = await storage.read(key: 'token')    ?? '';
  Util.userId     = int.tryParse(await storage.read(key: 'userId') ?? '0') ?? 0;
  Util.userName   = await storage.read(key: 'userName') ?? '';
  Util.avatarUrl  = await storage.read(key: 'avatarUrl')?? '';
  Util.fcmToken   = await storage.read(key: 'fcmToken') ?? '';
  Util.baseUrl    = Util.apiBaseUrl();

  await dotenv.load(fileName: ".env");




  // ===== DI =====
  await setupDI();

  // ===== Firebase, FCM, Local Notification =====
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  final supabase = Supabase.instance.client;

  final session = supabase.auth.currentSession;
  if (session == null) {
    print("❌ Chưa có session (chưa login).");
  } else {
    print("✅ Đã có session, user ID: ${session.user.id}");
  }
  await sl<FcmService>().setupPush();
  await NotifyHelper().init();
  final socketService = sl<SocketService>();

  runApp(const MyApp());
}


  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
          BlocProvider<ConversationBloc>(create: (_) => sl<ConversationBloc>()),
          BlocProvider<UsersOnlineBloc>(create: (_) => sl<UsersOnlineBloc>()),
          BlocProvider<AvatarsCubit>(create: (_) => sl<AvatarsCubit>()),
          BlocProvider<CreateGroupCubit>(create: (_) => sl<CreateGroupCubit>()),
          BlocProvider<UsersCubit>(create: (_) => sl<UsersCubit>()),
          BlocProvider<ConversationGroupCubit>(create: (_) => sl<ConversationGroupCubit>()),
          BlocProvider<FriendBloc>(create: (_) => sl<FriendBloc>()),
          BlocProvider<InComingCallCubit>(create: (_) => sl<InComingCallCubit>()),
          BlocProvider<SuggestModelCubit>(create: (_) => sl<SuggestModelCubit>()),
        ],
        child: MaterialApp.router(
          title: 'Chat App',
          debugShowCheckedModeBanner: false,
          theme: ThemeApp.darkTheme,
          routerConfig: RouterApp.router,
        ),
      );
    }
  }
