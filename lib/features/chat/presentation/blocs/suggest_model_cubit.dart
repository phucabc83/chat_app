import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service/suggestion_service.dart';

class SuggestModelCubit extends Cubit<SuggestModelState> {
  final SuggestionService _suggestionService = SuggestionService();
  SuggestModelCubit() : super(SuggestModelState());


  Future<void> fetchSuggestions(String text) async {
    // emit(state.copyWith(
    //   isLoading: true,
    //   isShowSuggestions: false,
    //   suggestions: [],
    // ));
    debugPrint('🟡 [SuggestModelCubit] Fetching suggestions for text: $text');

    if (text.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        isShowSuggestions: true,
        suggestions: [
          MessageSuggestion(text: 'Xin chào! 👋', similarity: 1.0),
          MessageSuggestion(text: 'Cảm ơn bạn!', similarity: 1.0),
          MessageSuggestion(text: 'OK, mình hiểu rồi', similarity: 1.0),
        ],
      ));
      return;
    }

    try {
      final suggestions = await _suggestionService.fetchSuggestions(text);

      debugPrint('🟢 [SuggestModelCubit] Fetched suggestions: $suggestions');


      emit(state.copyWith(
        isLoading: false,
        isShowSuggestions: true,
        suggestions: [
          MessageSuggestion(text: 'Xin chào! 👋', similarity: 1.0),
          MessageSuggestion(text: 'Cảm ơn bạn!', similarity: 1.0),
          MessageSuggestion(text: 'OK, mình hiểu rồi', similarity: 1.0),
        ],
      ));

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isShowSuggestions: false,
        suggestions: [],
        errorMessage: e.toString(),
      ));
    }
  }


  void clearSuggestions() {
    emit(state.copyWith(
      isShowSuggestions: false,
      suggestions: [],
    ));
  }
}


class SuggestModelState  {
  bool isLoading;
  bool isShowSuggestions;
  String errorMessage = '';
  List<MessageSuggestion> suggestions;

  SuggestModelState({
    this.isLoading = false,
    this.isShowSuggestions = false,
    this.suggestions = const [],
    this.errorMessage = '',
  });

  SuggestModelState copyWith({
    bool? isLoading,
    bool? isShowSuggestions,
    List<MessageSuggestion>? suggestions,
    String? errorMessage,
  }) {
    return SuggestModelState(
      isLoading: isLoading ?? this.isLoading,
      isShowSuggestions: isShowSuggestions ?? this.isShowSuggestions,
      suggestions: suggestions != null
          ? List<MessageSuggestion>.from(suggestions)
          : this.suggestions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MessageSuggestion  {
  final String text;
  final double similarity;

  const MessageSuggestion({required this.text, required this.similarity});

  static fromJson(item) {
    return MessageSuggestion(
      text: item['text'],
      similarity: item['similarity'].toDouble(),
    );
  }
}
