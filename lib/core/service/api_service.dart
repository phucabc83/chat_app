import 'dart:typed_data';

import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page/chat_page.dart';
import 'package:chat_app/features/conversation/data/models/avatar_model.dart';
import 'package:chat_app/features/conversation/data/models/conversation_model.dart';
import 'package:chat_app/features/social/data/models/comment_model.dart';
import 'package:chat_app/features/social/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/chat/data/models/message_model.dart';

class ApiService {
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl:  Util.apiBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      responseType: ResponseType.json,
    ));
  }

  Future<UserModel> signInWithEmailAndPassword(String email,
      String password) async {
    final endpoint = '/auth/login';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.post(
          endpoint, data: {'email': email, 'password': password});
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // In thông tin request/response thật chi tiết
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      print('Method: ${e.requestOptions.method}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password,
      String name, int avatarId) async {
    final endpoint = '/auth/signup';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {
      final res = await dio.post(endpoint, data: {
        'email': email,
        'password': password,
        'name': name,
        'avatarId': avatarId
      });
      print(res.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('Signup failed (status: $status): $body');
    }
  }

  Future<List<ConversationModel>> getConversations(bool isGroup) async {
    String token = await _storage.read(key: 'token') ?? '';


    final endpoint = '/conversations';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    print('Token: $token');

    try {
      final res = await dio.get(
          endpoint,
          queryParameters: {
            "userId": Util.userId,
            "isGroup": isGroup // 👈 Nếu API đọc từ req.query.userId
            // 👈 Nếu API đọc từ req.query.userId
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            validateStatus: (s) => s != null && s >= 200 && s < 300, // ép non-2xx ném lỗi

          )
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');

      final data = res.data['conversations'] as List<dynamic>;

      return data.map((e) =>
          ConversationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      rethrow;
    }
  }

  Future<PageResult<MessageModel>> fetchAllMessageByConversationId(
      int conversationId,
      RequestMessage? requestMessage) async {
    String token = await _storage.read(key: 'token') ?? '';


    final endpoint = '/conversations/$conversationId';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          ),
          queryParameters: {
            'id': requestMessage?.lastMessageId,
            'created_at': requestMessage?.createdAt,
          }
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Messages: ${res.data}');
      } else {
        print('Failed to fetch messages: ${res.statusCode}');
      }
      final data = PageResult<MessageModel>(
          items: res.data['messages']
              .map<MessageModel>((e) => MessageModel.fromJson(e))
              .toList(),
          hasMore: res.data['hasMore'],
          nextCursor: res.data['nextCursor'],
      );

      return data;
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch messages: ${e.toString()}');
    }
  }

  Future<List<AvatarModel>> getAllAvatars() async {
    String token = await _storage.read(key: 'token') ?? '';

    final endpoint = '/avatars';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      final data = res.data as List<dynamic>;
      print('Data: avatars ${data}  ');
      return data.map((e) => AvatarModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to fetch avatars: ${e.toString()}');
    }
  }

  Future<void> insertGroup(String groupName, String groupDescription,
      int avatarId, List<int> member) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/conversations/group';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {
      final res = await dio.post(
          endpoint,
          data: {
            'groupName': groupName,
            'groupDescription': groupDescription,
            'avatarId': avatarId,
            'memberIds': member
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Group created successfully');
      } else {
        print('Failed to create group: ${res.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to create group: ${e.toString()}');
    }
  }

  Future<List<User>> getAllUsers() async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/users';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Users fetched successfully');
        final data = res.data as List<dynamic>;
        return data.map((e) => User.fromJson(e)).toList();
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<List<ConversationModel>> getGroupConversationByUserId(
      int userId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/conversations/group/$userId';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Conversation Group fetched successfully');
        final data = res.data['conversations'] as List<dynamic>;
        return data.map((e) => ConversationModel.fromJson(e)).toList();
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch Group: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch Group: ${e.toString()}');
    }
  }

  Future<List<AvatarModel>> getAllUserAvatars() async {
    String token = await _storage.read(key: 'token') ?? '';

    final endpoint = '/avatars/user';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      final data = res.data as List<dynamic>;
      print('Data: avatars ${data}  ');
      return data.map((e) => AvatarModel.fromJson(e)).toList();
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to fetch avatars: ${e.toString()}');
    }
  }


  Future<void> addFriend(json) async {

  }

  Future<void> removeFriend(int friendId) async {
    final endpoint = '/friends/remove';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.post(

        options: Options(
            headers: {
              'Authorization': 'Bearer ${Util.token}'
            }
        ),
        endpoint,
        data: {
          'actorId': Util.userId,
          'ortherId': friendId
        },
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      print('Method: ${e.requestOptions.method}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<List<dynamic>> getFriends() async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/friends/${Util.userId}';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → get $url');

    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Friends fetched successfully');
        final data = res.data as List<dynamic>;
        return data;
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<void> sendFriendRequest(
      {required int receiverId, String? message}) async {
    final endpoint = '/friends/friend-request';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.post(

        options: Options(
            headers: {
              'Authorization': 'Bearer ${Util.token}'
            }
        ),
        endpoint,
        data: {'from_id': Util.userId, 'to_id': receiverId, 'message': message},
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');
    } on DioException catch (e) {
      // In thông tin request/response thật chi tiết
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      print('Method: ${e.requestOptions.method}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<List<dynamic>> getFriendRequests() async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/friends/friend-request/${Util.userId}';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → get $url');

    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('getFriendRequests fetched successfully');
        final data = res.data as List<dynamic>;
        print('Data: ${data}');
        return data;
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<void> acceptFriendRequest(int requestId,int friendId) async {

    final endpoint = '/friends/friend-accept/$requestId';
    final url = '${dio.options.baseUrl}$endpoint';

    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.post(

        options: Options(
            headers: {
              'Authorization': 'Bearer ${Util.token}'
            }
        ),
        endpoint,
        data: {
          'friendId': friendId,
          'userId': Util.userId
        },
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');
    } on DioException catch (e) {
      // In thông tin request/response thật chi tiết
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      print('Method: ${e.requestOptions.method}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(int requestId) async {
    final endpoint = '/friends/friend-reject/$requestId';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');

    try {
      final res = await dio.post(

        options: Options(
            headers: {
              'Authorization': 'Bearer ${Util.token}'
            }
        ),
        endpoint,
        data: {'requestId': requestId},
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('Data: ${res.data}');
    } on DioException catch (e) {
      // In thông tin request/response thật chi tiết
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      print('Method: ${e.requestOptions.method}');
      print('Headers: ${e.requestOptions.headers}');
      print('Data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<List<dynamic>> getNotFriends() async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/friends/not-friend/${Util.userId}';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → get $url');

    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Friends fetched successfully');

        final data = res.data as List<dynamic>;
        debugPrint('Data Not Friends: $data');

        return data;
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<int> getConversationsId(int receiveId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/conversations/id';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → get $url');

    try {
      final res = await dio.get(
          endpoint,
          queryParameters: {
            "userId": Util.userId,
            "receiveId": receiveId
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Friends fetched successfully');
        final id = res.data['conversationId'] as int;
        return id;
      } else {
        print('Failed to fetch users: ${res.statusCode}');
        throw Exception('Failed to fetch users: ${res.statusCode}');
      }
    } catch (e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }


  Future<void> tokenFcm(String tokenFcm) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/users/token-fcm';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {
      final res = await dio.post(
          endpoint,
          data: {
            'userId': Util.userId,
            'fcmToken': tokenFcm
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );
      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      if (res.statusCode == 200) {
        print('Token FCM updated successfully');
      } else {
        print('Failed to update Token FCM: ${res.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to update Token FCM: ${e.toString()}');
    }
  }

  Future<PostModel> createPost({required String content, Uint8List? fileBytes,String? fileNameImage,String? mimeType}) async {

    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/posts';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {
      print(
          'Creating post with content: $content, fileNameImage: $fileNameImage, mimeType: $mimeType'
      );
      FormData formData = FormData.fromMap({
        'userId': Util.userId,
        'userName': Util.userName,
        'avatarUrl': Util.avatarUrl,
        'content': content,
        if (fileBytes != null)
          'file': MultipartFile.fromBytes(
            fileBytes,
            filename: fileNameImage,
            contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
          ),
      });

      final res = await dio.post(
          endpoint,
          data: formData,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('data post: ${res.data['data']}');
      return PostModel.fromJson(res.data['data']);

    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<List<PostModel>> getPosts() async {

    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/posts';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    try {


      final res = await dio.get(
          endpoint,
          queryParameters: {
            'userId':Util.userId
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('get data posts: ${res.data}');
      final data = res.data ;
      final list = data as List;
      final posts = list
          .map<PostModel>((e) => PostModel.fromJson(e))
          .toList();

      return posts;

    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<bool> addLikeForPost({required int postId}) async {

    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/posts/$postId/like';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {

      final res = await dio.post(
          endpoint,
          queryParameters: {
            'userId':Util.userId
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      return true;

    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<CommentModel> addCommentToPost({required int postId, required String content}) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/posts/$postId/comments';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → POST $url');
    try {

      final res = await dio.post(
          endpoint,
          data: {
            'userId':Util.userId,
            'content':content,
            'username': Util.userName,
            'avatarUrl': Util.avatarUrl,
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');

      return CommentModel.fromJson(res.data['data']);

    } on DioException catch (e) {
      print('Dio ERROR   ← ${e.response?.statusCode} ${e.requestOptions.uri}');
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }


  Future<List<CommentModel>> getCommentsForPost({required int postId}) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/posts/$postId/comments';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');


    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('get data comment in post: ${res.data}');


      final data = res.data;
      final list = data as List;
      final comments = list
          .map<CommentModel>((e) => CommentModel.fromJson(e))
          .toList();

      return comments;
    }catch(e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  Future<List<PostModel>> fetchPostUser(int userId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final endpoint = '/profiles/$userId/posts';
    final url = '${dio.options.baseUrl}$endpoint';
    print('Dio REQUEST → GET $url');
    try {
      final res = await dio.get(
          endpoint,
          options: Options(
              headers: {
                'Authorization': 'Bearer $token'
              }
          )
      );

      print('Dio RESPONSE ← ${res.statusCode} ${res.requestOptions.uri}');
      print('get data posts for user: ${res.data}');
      final data = res.data;
      final list = data as List;
      final posts = list
          .map<PostModel>((e) => PostModel.fromJson(e))
          .toList();

      return posts;
    }catch(e) {
      print('Dio ERROR   ← ${e.toString()}');
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

}
