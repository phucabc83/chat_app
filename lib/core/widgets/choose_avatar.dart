import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/conversation/domain/entities/avatar.dart';
import '../../features/conversation/presentation/blocs/group/avatars_cubit.dart';
import '../theme/theme_app.dart';
import 'avatar_tile.dart';
typedef chooseAvatarCallback = void Function(Avatar avatar);
class ChooseAvatar extends StatefulWidget {

  final chooseAvatarCallback onChooseAvatar;
  const ChooseAvatar({super.key,required this.onChooseAvatar});

  @override
  State<ChooseAvatar> createState() => _ChooseAvatarState();
}

class _ChooseAvatarState extends State<ChooseAvatar> {
  Avatar? _selectedAvatar;
  @override
  Widget build(BuildContext context) {
    return   Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: _selectedAvatar != null
                ? NetworkImage(_selectedAvatar!.url)
                : null,
            child: _selectedAvatar == null
                ? const Icon(Icons.group, size: 28)
                : null,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openAvatarSheet,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Chọn ảnh đại diện'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAvatarSheet() async {
    final chosen = await showModalBottomSheet<Avatar>(
      context: context,
      backgroundColor: DefaultColors.sentMessageInput,
      isScrollControlled: true,
      builder: (_) => const _AvatarGridSheet(),
    );
    if (chosen != null && mounted) {
      widget.onChooseAvatar(chosen);
      setState(() => _selectedAvatar = chosen);
    }
  }

}

class _AvatarGridSheet extends StatelessWidget {
  const _AvatarGridSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,

        // Chỉ rebuild khi state avatars đổi
        child: BlocBuilder<AvatarsCubit, AvatarsState>(
          buildWhen: (p, c) => p.loading != c.loading || p.data != c.data || p.error != c.error,
          builder: (context, state) {

            print(state.toString());
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            final avatars = state.data;
            if (avatars.isEmpty) {
              return const Center(child: Text('Không có dữ liệu'));
            }

            return _Grid(avatars: avatars);
          },
        ),
      ),
    );
  }
}



class _Grid extends StatefulWidget {
  final List<Avatar> avatars;
  const _Grid({required this.avatars});

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> {
  int? _localSelected;

  @override
  Widget build(BuildContext context) {
    final avatars = widget.avatars;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Chọn 1 ảnh', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10,
            ),
            itemCount: avatars.length,
            itemBuilder: (_, i) => AvatarTile(
              key: ValueKey(avatars[i].id),
              url: avatars[i].url,
              selected: _localSelected == i,
              onTap: () => setState(() => _localSelected = i),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _localSelected == null
                ? null
                : () => Navigator.pop(context, avatars[_localSelected!]),
            icon: const Icon(Icons.check),
            label: const Text('Chọn'),
          ),
        ),
      ],
    );
  }
}

