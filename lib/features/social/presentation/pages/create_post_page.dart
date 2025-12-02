import 'package:chat_app/core/utils/util.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

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

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
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
                  Navigator.pop(context);
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
            padding: const EdgeInsets.only(top: 20,bottom: 10,left: 10,right: 10),
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: Colors.white54,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                        onPressed: (){},
                        icon: Icon(Icons.image,color: Colors.green,size: 30,),
                        iconAlignment: IconAlignment.start,
                        label: Text('Thêm ảnh',style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                    )
                    ),
                    TextButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.supervised_user_circle_outlined,color: Colors.blueAccent,size: 30),
                        label: Text('Gắn thẻ bạn bè',style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        )
                    ),
                    TextButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.emoji_emotions,color: Colors.yellowAccent,size: 30),
                        label: Text('Cảm xúc',style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        )
                    ),
                    TextButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.location_on_outlined,color: Colors.green,size: 30),
                        label: Text('Vị trí',style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        )
                    )
                  ]
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
