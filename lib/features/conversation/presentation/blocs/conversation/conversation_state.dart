abstract class ConversationState {}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationSuccess<T> extends ConversationState {
  final T data;
  ConversationSuccess(this.data);
}

class ConversationFailure extends ConversationState {
  final String error;
  ConversationFailure(this.error);
}

