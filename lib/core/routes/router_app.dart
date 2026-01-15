import 'package:chat_app/core/routes/router_app_name.dart';

import 'package:chat_app/features/auth/presentation/pages/sign_up/sign_up_page.dart';
import 'package:chat_app/features/chat/presentation/blocs/out_going_call_cubit.dart';
import 'package:chat_app/features/chat/presentation/pages/video_call_page/incoming_call_screen.dart';
import 'package:chat_app/features/chat/presentation/pages/video_call_page/out_going_call_screen.dart';
import 'package:chat_app/features/chat/presentation/pages/video_call_page/video_call_page.dart';
import 'package:chat_app/features/conversation/presentation/pages/home_main_page.dart';
import 'package:chat_app/features/social/presentation/blocs/create_posts_cubit.dart';
import 'package:chat_app/features/social/presentation/blocs/posts_cubit.dart';
import 'package:chat_app/features/social/presentation/pages/create_post_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login/sign_in_page.dart';
import '../../features/chat/presentation/blocs/chat_bloc.dart';
import '../../features/chat/presentation/blocs/in_coming_call_cubit.dart';
import '../../features/chat/presentation/pages/chat_page/chat_page.dart';
import '../../features/conversation/presentation/pages/group_page/add_group_page.dart';
import '../utils/util.dart';

final sl = GetIt.instance;

class RouterApp {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: AppRouteInfor.homePath,
        name: AppRouteInfor.homeName,
        builder: (_, _) => HomeMainPage(),
      ),
      GoRoute(
        path: AppRouteInfor.chatPath,
        name: AppRouteInfor.chatName,

        builder: (context, router) {
          final id = int.parse(router.pathParameters['id']!);
          final name = router.uri.queryParameters['name']!;
          final isGroup = router.uri.queryParameters['isGroup']! == 'true';
          final avatar = router.uri.queryParameters['avatar'];
          final member = router.uri.queryParameters['member'] != null
              ? int.parse(router.uri.queryParameters['member']!)
              : null;
          final replyTo = int.parse(
            router.uri.queryParameters['replyTo'] ?? '0',
          );
          print('id $id name $name isGroup $isGroup $avatar');

          return BlocProvider(
            create: (context) => sl<ChatBloc>(),
            child: ChatPage(
              conversationId: id,
              name: name,
              isGroup: isGroup,
              avatar: avatar,
              member: member,
              replyTo: replyTo,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouteInfor.outGoingCallPath,
        name: AppRouteInfor.outGoingCallName,

        builder: (context, router) {
          final callID = router.pathParameters['id']!;
          final userIdReceiver = router.uri.queryParameters['userIdReceiver']!;
          final conversationId = router.uri.queryParameters['conversationId']!;

          final usernameReceiver =
              router.uri.queryParameters['usernameReceiver']!;
          final avatarUrl = router.uri.queryParameters['avatarUrl']!;
          print('id $callID name $usernameReceiver userID $userIdReceiver');
          return BlocProvider(
            create: (context) => sl<OutGoingCallCubit>(),
            child: OutGoingCallScreen(
              callID: callID,
              avatarUrl: avatarUrl,
              userIdReceiver: int.parse(userIdReceiver),
              usernameReceiver: usernameReceiver,
              conversationId: int.parse(conversationId),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRouteInfor.incomingCallPath,
        name: AppRouteInfor.incomingCallName,

        builder: (context, router) {
          final callID = router.pathParameters['id']!;
          final callerID = router.uri.queryParameters['callerID']!;
          final usernameCaller = router.uri.queryParameters['usernameCaller']!;
          final avatarUrlCaller =
              router.uri.queryParameters['avatarUrlCaller']!;
          final reminderTime = router.uri.queryParameters['reminderTime']!;

          print(' go to incomingcall id $callID name $usernameCaller callerID $callerID');
          return IncomingCallScreen(
            usernameCaller: usernameCaller,
            avatarUrlCaller: avatarUrlCaller,
            callerID: int.parse(callerID),
            callID: callID,
            reminderTime: int.parse(reminderTime),
          );
        },
      ),

      GoRoute(
        path: AppRouteInfor.videoCallPath,
        name: AppRouteInfor.videoCallName,

        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          final callID = extra['callID']!;
          final userIDReceiver = extra['userIDReceiver']!;
          final userIDCaller = extra['userIDCaller']!;


          print('id $callID userIDReceiver $userIDReceiver userIDCaller $userIDCaller');

          return VideoCallPage(
            callID: callID,
            userIDReceiver: userIDReceiver,
            userIDCaller: userIDCaller,
          );
        },
      ),
      GoRoute(
        path: AppRouteInfor.signUpPath,
        name: AppRouteInfor.signUpName,
        builder: (_, _) => SignUpPage(),
      ),
      GoRoute(
        path: AppRouteInfor.loginPath,
        name: AppRouteInfor.loginName,
        builder: (_, _) => LoginPage(),
      ),
      GoRoute(
        path: AppRouteInfor.addGroupPath,
        name: AppRouteInfor.addGroupName,
        builder: (_, _) => const AddGroupPage(),
      ),

      GoRoute(
        path: AppRouteInfor.createPostPath,
        name: AppRouteInfor.createPostName,
        builder: (_, _) => BlocProvider(
          create: (context) => sl<CreatePostsCubit>(),
          child: const CreatePostPage(),
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = Util.userId != 0 && Util.token.isNotEmpty;
      final isOnLoginPage =
          state.matchedLocation == AppRouteInfor.loginPath ||
          state.matchedLocation == AppRouteInfor.signUpPath;

      print('path ${state.matchedLocation}');
      print('isLoggedIn $isLoggedIn isOnLoginPage $isOnLoginPage');

      debugPrint(
          ' login infor path : ${Util.userId} token ${Util.token}'
      );

      if (!isLoggedIn && !isOnLoginPage) {
        return AppRouteInfor.loginPath;
      }

      if (isLoggedIn && isOnLoginPage) {
        return AppRouteInfor.homePath;
      }

      return null;
    },
  );
}
