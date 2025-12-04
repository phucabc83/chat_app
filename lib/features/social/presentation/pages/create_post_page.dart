import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/features/social/presentation/blocs/create_posts_cubit.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {

  final TextEditingController _controller = TextEditingController();


    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);

      return BlocConsumer<CreatePostsCubit, CreatePostsState>(
        listener: (context, state) {
          debugPrint('state current ${state.status}');

          if (state.error != null) {
              showMessageSnackBar(context, '${state.error}');
          }
          if(state.status == CreatePostStatus.success) {
            Navigator.pop(context);
            showMessageSnackBar(context, 'Tạo bài viết thành công');

          }
        },
        builder: (context, state) {
          debugPrint('state current ${state.status}');

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                  'assets/images/background.jpg', fit: BoxFit.cover),
            ),
            Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                leading: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Hủy',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  'Tạo bài viết',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if(_controller.text.trim().isEmpty) {
                        showMessageSnackBar(context,'Vui lòng nhập nội dung bài viết');
                        return;
                      }
                      context.read<CreatePostsCubit>().createPost(
                        content: _controller.text,
                      );
                    },
                    child: Text(
                      'Đăng',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blueAccent.shade200,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              body: Padding(
                padding: const EdgeInsets.only(
                    top: 20, bottom: 10, left: 10, right: 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(Util.avatarUrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: "Bạn đang nghĩ gì...? ",
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                    color: Colors.white54,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                    color: Colors.cyanAccent,
                                    width: 2.0,
                                  ),
                                ),
                  
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        color: Colors.white54,
                        thickness: 1,
                        radius: BorderRadius.circular(5),
                      ),
                      Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 30,
                          runSpacing: 5,
                          children: [
                            TextButton.icon(
                                onPressed: () {
                                  context.read<CreatePostsCubit>().chooseImage();
                                },
                                icon: Icon(Icons.image, color: Colors.green,
                                  size: 30,),
                                iconAlignment: IconAlignment.start,
                                label: Text('Thêm ảnh', style: theme.textTheme
                                    .bodyMedium?.copyWith(color: Colors.white),
                                )
                            ),
                            TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.supervised_user_circle_outlined,
                                    color: Colors.blueAccent, size: 30),
                                label: Text('Gắn thẻ bạn bè', style: theme
                                    .textTheme.bodyMedium?.copyWith(
                                    color: Colors.white),
                                )
                            ),
                            TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.emoji_emotions, color: Colors
                                    .yellowAccent, size: 30),
                                label: Text('Cảm xúc', style: theme.textTheme
                                    .bodyMedium?.copyWith(color: Colors.white),
                                )
                            ),
                            TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.location_on_outlined,
                                color: Colors.green, size: 30),
                                label: Text('Vị trí', style: theme.textTheme
                                    .bodyMedium?.copyWith(color: Colors.white),
                                )
                            )
                          ]
                      ),
                      SizedBox(
                        height: paddingCustom(context),
                      ),
                  
                      state.imageBytes != null ? ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: Image.memory(
                          state.imageBytes!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ): Container()
                    ],
                  ),
                ),
              ),
            ),
            state.status == CreatePostStatus.submitting ?
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ) : Container(),

          ],
        );
      }

    );
  }

  _post(context) {
    if(_controller.text.trim().isEmpty) {
      showMessageSnackBar(context,'Vui lòng nhập nội dung bài viết');
      return;
    }
    context.read<CreatePostsCubit>().createPost(
      content: _controller.text,
    );
  }
}
