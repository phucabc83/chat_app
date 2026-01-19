import 'package:chat_app/core/service/api_service.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/chat/presentation/blocs/suggest_model_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class SuggestionService {

  static final SuggestionService _instance = SuggestionService._internal();

  factory SuggestionService() => _instance;

  SuggestionService._internal();





  Future<List<MessageSuggestion>> fetchSuggestions(String query) async {
    debugPrint('Fetching suggestions for query: $query');
   Dio dio = Dio(
      BaseOptions(
        baseUrl: Util.apiBaseUrl(port:5000),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );


    try {
      final response = await dio.post(
        '/suggest',
        data: {
          'text': query,
        },
      );

      debugPrint('Response data: ${response.data}');

      final data = response.data['suggestions'] as List<dynamic>;
      final list = data.map<MessageSuggestion>((item) => MessageSuggestion.fromJson(item)).toList();
      debugPrint('Fetched ${list.length} suggestions.');
      return list;

    }  catch (e) {
      throw Exception('Failed to fetch posts: ${e.toString()}');

    }
  }
}