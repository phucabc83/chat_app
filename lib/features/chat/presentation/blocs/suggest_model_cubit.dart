import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service/suggestion_service.dart';

class SuggestModelCubit extends Cubit<SuggestModelState> {
  final SuggestionService _suggestionService = SuggestionService();
  SuggestModelCubit() : super(SuggestModelState());


  Future<void> fetchSuggestions(String text) async {

    debugPrint('🟡 [SuggestModelCubit] Fetching suggestions for text: $text');

    if (text.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        isShowSuggestions: true,
        suggestions: [
           'Xin chào! 👋',
          'Cảm ơn bạn!',
          'OK, mình hiểu rồi',
        ],
      ));
      return;
    }

    try {
      final suggestions = await _suggestionService.fetchSuggestions(text);

      debugPrint(' [SuggestModelCubit] Fetched suggestions: $suggestions');


      emit(state.copyWith(
        isLoading: false,
        isShowSuggestions: true,
        suggestions: suggestions,
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
  List<String> suggestions;

  SuggestModelState({
    this.isLoading = false,
    this.isShowSuggestions = false,
    this.suggestions = const [],
    this.errorMessage = '',
  });

  SuggestModelState copyWith({
    bool? isLoading,
    bool? isShowSuggestions,
    List<String>? suggestions,
    String? errorMessage,
  }) {
    return SuggestModelState(
      isLoading: isLoading ?? this.isLoading,
      isShowSuggestions: isShowSuggestions ?? this.isShowSuggestions,
      suggestions: suggestions != null
          ? List<String>.from(suggestions)
          : this.suggestions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MessageSuggestion  {
  final String text;


  const MessageSuggestion({required this.text});

  static fromJson(item) {
    return MessageSuggestion(
      text: item['text'],

    );
  }
}
