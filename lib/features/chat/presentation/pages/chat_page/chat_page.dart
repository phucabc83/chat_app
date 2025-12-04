import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/core/routes/router_app_name.dart';
import 'package:chat_app/core/service/socket_service.dart';
import 'package:chat_app/core/theme/theme_app.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/widgets/bottom_sheeet_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart' show PagedListView, PagedChildBuilderDelegate, PagingListener;

import '../../../../../core/routes/router_app.dart';
import '../../../domain/entities/messsage.dart';
import '../../blocs/chat_event.dart';
import '../../blocs/chat_state.dart';


class RequestMessage{
  final int? lastMessageId;
  final String? createdAt;
  final int conversationId;

  RequestMessage({ this.lastMessageId, this.createdAt,required this.conversationId});
}

class ChatPage extends StatefulWidget {
  final int conversationId;
  final String name;
  final bool isGroup;
  final String? avatar;
  final int? member;
  final int replyTo;
   const ChatPage({super.key, required this.conversationId, required  this.name, required bool this.isGroup,this.avatar,this.member,  this.replyTo = 0});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

  class _ChatPageState extends State<ChatPage> {
    late final TextEditingController _controller;
    int replyTo = 0;
    final ScrollController _scrollController = ScrollController();

    late final ChatBloc chatBloc;
    late final int conversationId;
    late final bool isGroup;
    late final String? avatar;





    @override
    void initState() {
      super.initState();
      print('init state chat page');
      chatBloc = context.read<ChatBloc>();
      conversationId = widget.conversationId;
      isGroup = widget.isGroup;
      Util.conversationIdActive = widget.conversationId;

      _controller = TextEditingController();
      avatar = widget.avatar;
      replyTo = widget.replyTo;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[UI] call setConversation → refresh');
        chatBloc.setConversation(widget.conversationId, widget.replyTo, widget.isGroup);
      }
    );

    }


    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context); // tránh gọi lại nhiều lần

      print('build chat page');
      print('replyTo: $replyTo');
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      avatar ?? 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y' //
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    if (widget.isGroup) Text('${widget.member} thành viên', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70))
                  ],
                )

              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.video_call, color: Colors.white),
                onPressed: () {
                  navigateToVideoCallPage(
                    callID: 'call_${widget.conversationId}_${Util.userId}_${chatBloc.state.replyTo.toString()}',
                    userIdReceiver: chatBloc.state.replyTo.toString(),
                    userName: Util.userName,
                    conversationId: widget.conversationId,

                  );


                },

              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PagingListener<RequestMessage?, Message>(
                  controller: chatBloc.pagingController,
                  builder: (context, pagingState, fetchNextPage) {
                    return PagedListView<RequestMessage?, Message>.separated(
                      state: pagingState,
                      fetchNextPage: fetchNextPage,
                      reverse: true,
                      builderDelegate: PagedChildBuilderDelegate<Message>(
                        itemBuilder: (context, item, index) {
                          final isSender = item.senderId == Util.userId;
                          final isLast = item.id == pagingState.pages?.first?.first?.id;
                          return buildMessageBubble(
                              Theme.of(context),
                              item.content,
                              isSender,
                              isLast,
                              item.getStatus(isGroup),
                              item.messageType
                          );
                        },
                        firstPageProgressIndicatorBuilder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        newPageProgressIndicatorBuilder: (context) => const Center(
                          child: CircularProgressIndicator(),
                           ),
                        noItemsFoundIndicatorBuilder: (context) => const Center(
                          child: Text('No messages yet'),
                        ),
                      ),
                      separatorBuilder: (context, index) => const SizedBox(height: 12)
                    );
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildMessageInput(theme),
              ),
            ],
          ),
        )],
      );
    }

  Widget buildMessageBubble(ThemeData theme, String message, bool isSender,bool lastMessage,String status, MessageType messageType) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children:[
            Container(
                decoration: BoxDecoration(
                    color: isSender
                        ? DefaultColors.senderMessage.withOpacity(0.3)
                        : DefaultColors.receiverMessage.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15)),
                child: contentMessage(messageType,message,theme)
            ),

            if (lastMessage && isSender && messageType != MessageType.video) // Hiển thị replyTo chỉ cho tin nhắn cuối cùng
                Padding(
                  padding: const EdgeInsets.only(right: 8.0,left: 8.0, bottom: 7.0),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
          ]
        ),
    );
  }

  Widget buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: (){
              _sendImageMessage(
                  widget.conversationId,
                  'image message',
                  Util.userId,
                  MessageType.image,
                  replyTo,
                  widget.isGroup
              );
            },
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                _sendMessage(
                    widget.conversationId,
                    text,
                    Util.userId,
                    MessageType.text,
                    replyTo ?? 0,
                    widget.isGroup
                );
                _controller.clear();
              },
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),

              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              print('send mess');
              _sendMessage(
                widget.conversationId,
                _controller.text,
                Util.userId,
                MessageType.text,
                replyTo,
                widget.isGroup
              );
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  void _readMessages(int conversationId) {
    context.read<ChatBloc>().add(MessageLoadEvent(conversationId: conversationId, isGroup: widget.isGroup,replyTo: replyTo));
  }

  void _sendMessage(int conversationId, String content, int senderId,MessageType messageType,int? replyTo,bool isGroup) {

      if(content.trim().isNotEmpty){
        context.read<ChatBloc>().add(
            MessageSendEvent(conversationId: conversationId, content: content, messageType: messageType,replyTo: replyTo, isGroup: isGroup)
        );
      }
  }

  @override
  void dispose() async{
    // TODO: implement dispose
    chatBloc.dispose(conversationId, isGroup);
    _controller.dispose();
    _scrollController.dispose();
    print('dispose chat page');

    super.dispose();

  }



    void _sendImageMessage(int conversationId, String content, int senderId,MessageType messageType,int? replyTo,bool isGroup) {
      context.read<ChatBloc>().add(
          SendImageMessage(
              imagePath: '',
              conversationId: conversationId,
              content: content,
              messageType: messageType,
              replyTo: replyTo,
              isGroup: isGroup
          )
      );

    }

    Widget contentMessage(MessageType messageType, String message,ThemeData theme) {
      if(messageType == MessageType.text) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
        );
      } else if (messageType == MessageType.image) {
         return GestureDetector(
           onTap: (){
             showImageBottomSheet(context: context, url: message);
           },
           child: Hero(
             tag: message,
             child: ClipRRect(
               borderRadius: BorderRadius.circular(12),
               child: CachedNetworkImage(
                 imageUrl: message,
                 width: kIsWeb ? getWidth(context)*0.25 : getWidth(context)*0.4,
                 height: kIsWeb ? getWidth(context)*0.25 : getWidth(context)*0.35,
                 fit: BoxFit.cover,
                 placeholder: (context, url) => const Center(
                   child: CircularProgressIndicator(),
                 ),
                 errorWidget: (context, url, error) => Container(
                   color: Colors.grey[300],
                   alignment: Alignment.center,
                   child: const Icon(Icons.broken_image, color: Colors.grey),
                 ),
               ),
             ),
           ),
         );

      } else if(messageType == MessageType.video) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.videocam, color: Colors.white70),
              const SizedBox(height: 8),
              Text(message, style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      }

      return SizedBox.shrink();
    }


    bool isUrl(String s) {
      final uri = Uri.tryParse(s);
      return uri != null && (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
    }

  void navigateToVideoCallPage({required String callID, required String userIdReceiver,
    required String userName,required int conversationId}) {
      debugPrint('infor navigate to outGoingCallName page: callID=$callID, '
          'userID=$userIdReceiver, userName=$userName');
      context.pushNamed(
        AppRouteInfor.outGoingCallName,
        pathParameters: {
          'id': callID
        },
        queryParameters: {
          'userIdReceiver': userIdReceiver,
          'usernameReceiver': userName,
          'avatarUrl': avatar ?? '',
          'conversationId': conversationId.toString()
        },
      );
  }


}


