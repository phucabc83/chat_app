import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/features/conversation/presentation/widgets/conversation_list.dart';
import 'package:chat_app/features/conversation/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/router_app_name.dart';
import '../../../../../core/theme/theme_app.dart';
import '../../blocs/conversation/conversation_group_cubit.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationGroupCubit>().loadConversationGroups();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(Icons.group, size: 30,color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Group',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
        ),

        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MessageInput(controller: TextEditingController(),
                hint: 'Search group',
                prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                  color: Colors.white54,
                )
              ),
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
                  child: BlocBuilder<ConversationGroupCubit, ConversationGroupState>(

                    builder: (context,state){
                      if(state.loading!){
                        return Center(child: CircularProgressIndicator(color: DefaultColors.messageListPage));
                      }
                      if(state.error != null && state.error!.isNotEmpty){
                        return Center(child: Text('Error: ${state.error}'));
                      }
                      if(state.conversations.isEmpty){
                        return Center(child: Text('No groups found', style: Theme.of(context).textTheme.bodyLarge));
                      }
                      return ConversationList(conversations: state.conversations);

                    }
                  ),
                )
              ),
            ]
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.pushNamed(AppRouteInfor.addGroupName),
          backgroundColor: DefaultColors.messageListPage,
          shape: CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}
