import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/conversation/domain/entities/conversation.dart';
import 'package:chat_app/features/conversation/presentation/widgets/conversation_list.dart';
import 'package:chat_app/features/conversation/presentation/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routes/router_app_name.dart';
import '../../../../../core/service/socket_service.dart';
import '../../../../../core/theme/theme_app.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../../blocs/conversation/conversations_bloc.dart';
import '../../blocs/user/users_online_bloc.dart';
import '../../blocs/user/users_online_state.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init state Home');

    context.read<ConversationBloc>().add(AllConversationLoadEvent());
    context.read<UsersOnlineBloc>().add(LoadStatusFriendsEvent());

  }

  @override
  Widget build(BuildContext context) {

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Message',style: theme.textTheme.titleLarge),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),

        ],
      ),
      body: BlocListener<ConversationBloc,ConversationState>(
        listener: (context,state){
          if(state is ConversationSuccess){
            print('ConversationSuccess HomePage');
          }else if(state is ConversationFailure){
            print('ConversationFail HomePage');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
            GoRouter.of(context).go(AppRouteInfor.loginPath);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Online',style: theme.textTheme.bodySmall,),
              SizedBox(height: paddingCustom(context),),
              SizedBox(
                height: getHeight(context)*0.13,
                child: BlocBuilder<UsersOnlineBloc,UsersOnlineState>(

                  builder: (BuildContext context, UsersOnlineState state) {
                      if(state is UsersOnlineInitial){
                        return Container();
                      }else if(state is UsersOnlineLoading){

                        return CircularProgressIndicator();
                      }else if(state is UsersOnlineLoaded){
                        final friends = state.users;
                        print(friends);
                        return  ListView.separated(
                          // shrinkWrap: true,
                          reverse: true,
                          separatorBuilder: (context,index) => const SizedBox(width: 20,),
                          scrollDirection: Axis.horizontal,
                          itemCount: friends.length,
                          itemBuilder:(context,index){
                            final friend = friends[friends.length - 1 - index];
                            return UserCard(id:friend.id,name:friend.name, imageUrl: friend.avatar ?? 'https://www.gravatar.com/avatar/');
                          },

                        );
                      }
                      return const Center(child: Text('No friends online'));

                  },

                )
              ),

              Text('Tin nhắn',style: theme.textTheme.bodySmall,),
              SizedBox(height: paddingCustom(context),),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: DefaultColors.messageListPage.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: BlocBuilder<ConversationBloc,ConversationState>(
                    builder: (context,state) {
                      if(state is ConversationLoading) {
                        return  Center(child: CircularProgressIndicator());
                      } else if (state is ConversationSuccess) {
                        final conversations = (state as ConversationSuccess<List<Conversation>>).data ;
                        return ConversationList(conversations: conversations);

                      } else if (state is ConversationFailure) {
                        return Center(child: Text('Error ', style: theme.textTheme.bodyMedium));
                      }
                      return  Text('No conversations found');
                    }

                  ),
                ),
              ),




            ],
          ),
        ),
      ),

    );
  }



}
