import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/routes/router_app_name.dart';
import 'package:chat_app/core/theme/theme_app.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/blocs/suggest_model_cubit.dart';
import 'package:chat_app/features/chat/presentation/widgets/bottom_sheeet_image.dart';
import 'package:chat_app/features/chat/presentation/widgets/location_widgets.dart';
import 'package:chat_app/services/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagedListView, PagedChildBuilderDelegate, PagingListener, PagingController;
import 'package:url_launcher/url_launcher.dart';


import '../../../../../core/consts/const.dart';
import '../../../domain/entities/messsage.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../blocs/chat_event.dart';


class RequestMessage {
  final int conversationId;
  final int? lastMessageId;
  final String? createdAt;

  RequestMessage({
    required this.conversationId,
    this.lastMessageId,
    this.createdAt,
  });
}


class ChatPage extends StatefulWidget {
  final int conversationId;
  final String name;
  final bool isGroup;
  final String? avatar;
  final int? member;
  final int replyTo;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.name,
    required bool this.isGroup,
    this.avatar,
    this.member,
    this.replyTo = 0,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _controller;
  int replyTo = 0;
  final ScrollController _scrollController = ScrollController();
  bool isLoadingLocation = false;

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
      chatBloc.setConversation(
        widget.conversationId,
        widget.replyTo,
        widget.isGroup,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // tránh gọi lại nhiều lần

    print('build chat page');
    print('replyTo: $replyTo');
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
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
                    avatar ??
                        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y', //
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (widget.isGroup)
                      Text(
                        '${widget.member} thành viên',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.video_call, color: Colors.white),
                onPressed: () {
                  navigateToVideoCallPage(
                    callID:
                    'call_${widget.conversationId}_${Util.userId}_${chatBloc
                        .state.replyTo.toString()}',
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
                          final isLast =
                              item.id == pagingState.pages?.first?.first?.id;
                          return buildMessageBubble(
                              Theme.of(context),
                              item.content,
                              isSender,
                              isLast,
                              item.getStatus(isGroup),
                              item.messageType,
                              widget.isGroup,
                              item.senderName
                          );
                        },
                        firstPageProgressIndicatorBuilder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                        newPageProgressIndicatorBuilder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                        noItemsFoundIndicatorBuilder: (context) =>
                        const Center(child: Text('No messages yet')),
                      ),
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MessageInputWithSuggestions(
                  controller: _controller,
                  pagingController: chatBloc.pagingController,
                  onSend: (String text) {
                    debugPrint('Sending message: $text with replyTo: $replyTo');
                    if (text
                        .trim()
                        .isEmpty) return;
                    _sendMessage(
                      widget.conversationId,
                      text,
                      Util.userId,
                      MessageType.text,
                      replyTo,
                      widget.isGroup,
                    );
                  },
                  onCameraPressed: () {
                    _sendImageMessage(
                      widget.conversationId,
                      'image message',
                      Util.userId,
                      MessageType.image,
                      replyTo,
                      widget.isGroup,
                    );
                  },
                  onShareCurrentLocation: _handleShareCurrentLocation,
                  onChooseFromMap: _handleChooseFromMap,
                  isLoadingLocation: isLoadingLocation,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildMessageBubble(
      ThemeData theme,
      String message,
      bool isSender,
      bool lastMessage,
      String status,
      MessageType messageType,
      bool isGroup,
      String? senderName,
      ) {
    final bubbleColor = isSender
        ? DefaultColors.senderMessage.withOpacity(0.3)
        : DefaultColors.receiverMessage.withOpacity(0.3);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isGroup && !isSender)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 10),
              child: Text(
                senderName?? 'Tai',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                isSender ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                isSender ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: contentMessage(messageType, message, theme),
          ),

          // ✅ Status (sent / delivered / read)
          if (lastMessage &&
              isSender &&
              messageType != MessageType.video)
            Padding(
              padding: const EdgeInsets.only(
                right: 12,
                left: 12,
                top: 4,
              ),
              child: Text(
                status,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ),
        ],
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
            onPressed: () {
              _sendImageMessage(
                widget.conversationId,
                'image message',
                Util.userId,
                MessageType.image,
                replyTo,
                widget.isGroup,
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
                  widget.isGroup,
                );
                _controller.clear();
              },
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
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
                widget.isGroup,
              );
              _controller.clear();
            },
          ),
        ],
      ),
    );
  }

  void _readMessages(int conversationId) {
    context.read<ChatBloc>().add(
      MessageLoadEvent(
        conversationId: conversationId,
        isGroup: widget.isGroup,
        replyTo: replyTo,
      ),
    );
  }

  void _sendMessage(int conversationId,
      String content,
      int senderId,
      MessageType messageType,
      int? replyTo,
      bool isGroup,) {
    if (content
        .trim()
        .isNotEmpty) {
      debugPrint('Sending message: $content with replyTo: $replyTo');
      context.read<ChatBloc>().add(
        MessageSendEvent(
          conversationId: conversationId,
          content: content,
          messageType: messageType,
          replyTo: replyTo,
          isGroup: isGroup,
        ),
      );
    }
    Message? getLastMessage() {
      final pages = chatBloc.pagingController.value.pages;
      if (pages == null || pages.isEmpty) return null;
      if (pages.first.isEmpty) return null;

      return pages.first.first;
    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    chatBloc.dispose(conversationId, isGroup);
    _controller.dispose();
    _scrollController.dispose();
    print('dispose chat page');

    super.dispose();
  }

  void _sendImageMessage(int conversationId,
      String content,
      int senderId,
      MessageType messageType,
      int? replyTo,
      bool isGroup,) {
    context.read<ChatBloc>().add(
      SendImageMessage(
        imagePath: '',
        conversationId: conversationId,
        content: content,
        messageType: messageType,
        replyTo: replyTo,
        isGroup: isGroup,
      ),
    );
  }

  // Location sharing handlers
  Future<void> _handleShareCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      // Lấy vị trí hiện tại thực tế
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        setState(() => isLoadingLocation = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Không thể lấy vị trí. Vui lòng bật GPS và cấp quyền.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      // Lấy địa chỉ từ tọa độ
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      ) ?? 'Vị trí hiện tại';

      // Gửi tin nhắn vị trí
      final locationContent = '${position.latitude},${position
          .longitude}|$address';

      setState(() => isLoadingLocation = false);

      if (mounted) {
        Navigator.pop(context); // Đóng bottom sheet

        _sendMessage(
          conversationId,
          locationContent,
          Util.userId,
          MessageType.location,
          replyTo,
          isGroup,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã chia sẻ vị trí hiện tại'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoadingLocation = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleChooseFromMap() async {
    Navigator.pop(context); // Đóng bottom sheet trước

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result != null && mounted) {
      final latitude = result['latitude'] as double;
      final longitude = result['longitude'] as double;
      final address = result['address'] as String? ?? 'Vị trí đã chọn';

      // Gửi tin nhắn vị trí
      final locationContent = '$latitude,$longitude|$address';

      _sendMessage(
        conversationId,
        locationContent,
        Util.userId,
        MessageType.location,
        replyTo,
        isGroup,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã chia sẻ vị trí từ bản đồ'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _openLocationInMap(double lat, double lng) async {
    try {
      final url = Uri.parse('https://maps.google.com/?q=$lat,$lng');
      final urlLauncher = await canLaunchUrl(url);

      if (urlLauncher) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không thể mở bản đồ'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở bản đồ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget contentMessage(MessageType messageType,
      String message,
      ThemeData theme,) {
    if (messageType == MessageType.text) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(message, style: theme.textTheme.bodyMedium),
      );
    } else if (messageType == MessageType.image) {
      return GestureDetector(
        onTap: () {
          showImageBottomSheet(context: context, url: message);
        },
        child: Hero(
          tag: message,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: message,
              width: kIsWeb
                  ? getWidth(context) * 0.25
                  : getWidth(context) * 0.4,
              height: kIsWeb
                  ? getWidth(context) * 0.25
                  : getWidth(context) * 0.35,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            ),
          ),
        ),
      );
    } else if (messageType == MessageType.video) {
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
    } else if (messageType == MessageType.location) {
      // Parse location message: "latitude,longitude|address"
      try {
        final parts = message.split('|');
        final coords = parts[0].split(',');
        final latitude = double.parse(coords[0]);
        final longitude = double.parse(coords[1]);
        final address = parts.length > 1 ? parts[1] : null;

        return LocationMessageBubble(
          latitude: latitude,
          longitude: longitude,
          address: address,
          isSender: true,
          // Will be determined by buildMessageBubble
          onTap: () => _openLocationInMap(latitude, longitude),
        );
      } catch (e) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Invalid location data',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
          ),
        );
      }
    }

    return SizedBox.shrink();
  }

  bool isUrl(String s) {
    final uri = Uri.tryParse(s);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  void navigateToVideoCallPage({
    required String callID,
    required String userIdReceiver,
    required String userName,
    required int conversationId,
  }) {
    debugPrint(
      'infor navigate to outGoingCallName page: callID=$callID, '
          'userID=$userIdReceiver, userName=$userName',
    );
    context.pushNamed(
      AppRouteInfor.outGoingCallName,
      pathParameters: {'id': callID},
      queryParameters: {
        'userIdReceiver': userIdReceiver,
        'usernameReceiver': userName,
        'avatarUrl': avatar ?? '',
        'conversationId': conversationId.toString(),
      },
    );
  }
}


// Widget Suggestion Chips
class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final VoidCallback onDismiss;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Gợi ý tin nhắn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, size: 16, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 6),
          suggestions.isEmpty
              ? const Text(
            'Không có gợi ý phù hợp',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          )
              : SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) =>
              const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildChip(suggestion, onSuggestionTap);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          color: Colors.blue.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Widget Message Input đã tích hợp Suggestions
class MessageInputWithSuggestions extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onCameraPressed;
  final VoidCallback onShareCurrentLocation;
  final VoidCallback onChooseFromMap;
  final bool isLoadingLocation;
  final PagingController<RequestMessage?, Message> pagingController;


  const MessageInputWithSuggestions({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCameraPressed,
    required this.onShareCurrentLocation,
    required this.onChooseFromMap,
    this.isLoadingLocation = false,
    required this.pagingController,
  });

  @override
  State<MessageInputWithSuggestions> createState() =>
      _MessageInputWithSuggestionsState();
}

class _MessageInputWithSuggestionsState
    extends State<MessageInputWithSuggestions> {


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SuggestModelCubit, SuggestModelState>(
      builder: (context, state) {
        final suggestions = state.suggestions;
        final showSuggestions = state.isShowSuggestions;
        final isLoading = state.isLoading;

        debugPrint('MessageInputWithSuggestions build: '
            'showSuggestions=$showSuggestions, isLoading=$isLoading, '
            'suggestions is ${suggestions}');


        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Suggestion Chips
            AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: showSuggestions ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SuggestionChips(
                    suggestions: suggestions,
                    onSuggestionTap: _onSuggestionTap,
                    onDismiss: _onDismiss,
                  ),
                )
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  // Button Camera
                  IconButton(
                    onPressed: widget.onCameraPressed,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white70,
                    ),
                  ),

                  // Location Button
                  LocationActionButton(
                    onShareCurrentLocation: widget.onShareCurrentLocation,
                    onChooseFromMap: widget.onChooseFromMap,
                    isLoading: widget.isLoadingLocation,
                  ),

                  const SizedBox(width: 8),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text
                            .trim()
                            .isNotEmpty) {
                          widget.onSend(text);
                          widget.controller.clear();
                          context.read<SuggestModelCubit>().clearSuggestions();
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  // Button Gợi ý thông minh (AI Icon)
                  if (!showSuggestions)
                    IconButton(
                      onPressed: () {
                        String inputText = '';
                        if (widget.pagingController.value.pages != null) {
                          final lastMessage = widget.pagingController.value
                              .pages!.first.first;
                          debugPrint(
                              'Fetch suggestions based on last message ID: ${lastMessage
                                  .id}');

                          if (lastMessage.senderId != Util.userId) {
                            inputText = lastMessage.content;
                          }
                          context
                              .read<SuggestModelCubit>()
                              .fetchSuggestions(inputText);
                        }
                      },
                      icon: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                          : Icon(
                        Icons.psychology_outlined, // hoặc Icons.auto_awesome
                        color: Colors.blue.shade500,
                        size: 24,
                      ),
                      tooltip: 'Gợi ý thông minh',
                    ),

                  // Button Send
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = widget.controller.text.trim();
                      if (text.isNotEmpty) {
                        widget.onSend(text);
                        widget.controller.clear();
                        context.read<SuggestModelCubit>().clearSuggestions();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },

    );
  }

  _onSuggestionTap(String p1) {
    context.read<SuggestModelCubit>().clearSuggestions();
    widget.onSend(p1);
  }

  void _onDismiss() {
    context.read<SuggestModelCubit>().clearSuggestions();
  }
}
