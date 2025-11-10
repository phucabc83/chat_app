import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../domain/entities/messsage.dart';
import '../pages/chat_page/chat_page.dart';

class StateUI {
  int conversationId;
  bool isGroup = false;
  int  replyTo;

  StateUI({ this.conversationId = 0, this.isGroup = false, this.replyTo = 0});
}

class Initial extends StateUI {}
class Loading extends StateUI {}
class Success<T> extends StateUI {
  final T data;
  final int lastMessageId;
  final DateTime createdAt;
  final bool isLast;
  Success(this.data,{required this.lastMessageId ,required this.createdAt , this.isLast = false});


  @override
  Success<T> copyWith({int? conversationId, T? data, int? lastMessageId, DateTime? createdAt, bool? isLast}) {
    return Success<T>(data ?? this.data,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        createdAt: createdAt ?? this.createdAt,
        isLast: isLast ?? this.isLast
    );
  }
}
class Failture extends StateUI {
  final String error;
  Failture(this.error);
}

