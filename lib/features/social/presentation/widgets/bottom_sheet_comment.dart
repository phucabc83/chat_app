import 'package:chat_app/features/social/domain/entities/comment.dart';
import 'package:chat_app/features/social/presentation/blocs/comments_action_cubit.dart';
import 'package:chat_app/features/social/presentation/blocs/comments_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/util.dart';

Future<void> showCommentBottomSheet({
  required BuildContext context,
  required int postId,
  required int likeCount,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<CommentsCubit>(
              create: (_) => GetIt.instance<CommentsCubit>()..fetchComments(postId),
            ),
            BlocProvider<CommentsActionCubit>(
              create: (_) => GetIt.instance<CommentsActionCubit>(),
            ),
          ],
          child: CommentBottomSheet(postId: postId,likeCount: likeCount,)
      );
    },
  );
}

class CommentBottomSheet extends StatefulWidget {
  final int postId;
  final int likeCount;

  const CommentBottomSheet({Key? key, required this.postId, required this.likeCount}) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet>
{
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();




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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    print('Bottom inset: $bottomInset');

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF202324),
              Color(0xFF282B3E),
              Color(0xFF2D3C4B),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),

        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildShimmerDivider(),
            _buildStatsBar(likeCount:  widget.likeCount),
            Expanded(child: _buildCommentList()),
            _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xEFAD8555), Color(0xEFA68461)],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xEF8F6B47).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),

                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
      ),
    );
  }

    Widget _buildShimmerDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF6366F1).withOpacity(0.4),
            const Color(0xFF8B5CF6).withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar({required int likeCount}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: BlocBuilder<CommentsCubit,CommentsState>(
        builder: (context,state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.favorite, likeCount.toString(), const Color(0xFFFF4D67)),
              _buildStatDivider(),
              _buildStatItem(Icons.comment_rounded, state.comments.length.toString(), const Color(0xFF3B82F6)),
              _buildStatDivider(),
              _buildStatItem(Icons.share_rounded, '5', const Color(0xFF8B5CF6)),
            ],
          );
        }
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCommentList() {
    return BlocBuilder<CommentsCubit,CommentsState>(
      builder: (context,state){
        if(state.status == CommentsStatus.loading){
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if(state.status == CommentsStatus.failure){
          return Center(
            child: Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else if(state.comments.isEmpty){
          return const Center(
            child: Text(
              'Chưa có bình luận nào',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: state.comments.length,
            itemBuilder: (context, index) {
              final comment = state.comments[index];
              return _buildCommentItem(comment, index);
            },
          );
        }
      },
    );

  }

  Widget _buildCommentItem(Comment comment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1F3A),
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(comment.authorAvatarUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }




  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  Widget _buildCommentInput() {
    final avatarUrl = Util.avatarUrl;
    return SafeArea(
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A1F3A),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child:  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                    NetworkImage(avatarUrl),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _focusNode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.white.withOpacity(0.6),
                    size: 22,
                  ),
                ),
      
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
              shape: BoxShape.circle
    ),
            child: IconButton(
              onPressed: () {
                _commentPost(context);
              },
              icon: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
            ),
          )
      
        ],
      ),
    );
  }

  void _commentPost(BuildContext context) {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<CommentsActionCubit>().addComment(
        widget.postId, content);

    _commentController.clear();
    _focusNode.unfocus();
  }
}


String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'bây giờ';
  if (diff.inHours < 1) return '${diff.inMinutes} phút';
  if (diff.inDays < 1) return '${diff.inHours} giờ';
  return '${diff.inDays} ngày';
}