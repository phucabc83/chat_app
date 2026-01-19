import 'package:chat_app/core/routes/router_app_name.dart';
import 'package:chat_app/core/utils/util.dart';
import 'package:chat_app/core/widgets/choose_avatar.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:chat_app/features/conversation/presentation/blocs/user/users_cubit.dart';
import 'package:chat_app/features/conversation/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_app/core/consts/const.dart';
import 'package:chat_app/core/theme/theme_app.dart';
import 'package:chat_app/features/conversation/domain/entities/avatar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/avatar_tile.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_group_cubit.dart';
import '../../blocs/conversation/conversations_bloc.dart';
import '../../blocs/group/avatars_cubit.dart';
import '../../blocs/group/create_group_cubit.dart';



class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});
  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _groupName = TextEditingController();
  final _groupDesc = TextEditingController();
  Avatar? _selectedAvatar;
  List<User> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<AvatarsCubit>().load();
    context.read<UsersCubit>().loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: paddingCustom(context));

    return Scaffold(
      backgroundColor: const Color(0xFF18202D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18202D),
        title: const Text('Tạo nhóm'),
        centerTitle: false,
        elevation: 0,
      ),
      body: BlocListener<CreateGroupCubit, CreateGroupState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == CreateStatus.success) {
            showMessageSnackBar(context, state.message ?? 'Thành công');
            // context.read<ConversationBloc>().add(AllConversationLoadEvent());
            context.read<ConversationGroupCubit>().loadConversationGroups();
            context.goNamed(AppRouteInfor.homeName);
          } else if (state.status == CreateStatus.failure) {
            showMessageSnackBar(context, state.error ?? 'Có lỗi xảy ra');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Avatar
              ChooseAvatar(
                onChooseAvatar: (avatar){
                  _selectedAvatar = avatar;
                },
              ),
              gap,
              const Divider(height: 24),

              // Section: Thông tin nhóm
              Text('Thông tin nhóm', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              MessageInput(
                prefixIcon: const Icon(Icons.drive_file_rename_outline_outlined, color: Colors.white54),
                controller: _groupName,
                hint: 'Tên nhóm',
              ),
              const SizedBox(height: 12),
              MessageInput(
                prefixIcon: const Icon(Icons.description_outlined, color: Colors.white54),
                controller: _groupDesc,
                hint: 'Mô tả nhóm',
              ),

              gap,
              const Divider(height: 24),

              // Section: Thành viên
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Thành viên', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: _openUsersSheet,
                    icon: const Icon(Icons.supervised_user_circle_outlined),
                    label: const Text('Chọn thành viên'),
                  ),
                ],
              ),

              // Hiển thị các user đã chọn (chip có thể xóa)
              if (_selectedUsers.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedUsers.map((u) {
                    return Chip(
                      label: Text(u.name),
                      avatar: const CircleAvatar(child: Icon(Icons.person, size: 16)),
                      onDeleted: () {
                        setState(() {
                          _selectedUsers.removeWhere((x) => x.id == u.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ] else
                const Text('Chưa chọn thành viên nào', style: TextStyle(color: Colors.white54)),

              gap,

              // Nút tạo nhóm
              Center(
                child: BlocSelector<CreateGroupCubit, CreateGroupState, CreateStatus>(
                  selector: (s) => s.status,
                  builder: (context, status) {
                    final isLoading = status == CreateStatus.loading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DefaultColors.buttonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Tạo nhóm', style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _openUsersSheet() async {
    final chosen = await showModalBottomSheet<List<User>>(
      context: context,
      backgroundColor: DefaultColors.sentMessageInput,
      isScrollControlled: true,
      builder: (_) => UsersSheet(),
    );
    if (chosen != null && mounted) {
      setState(() => _selectedUsers = chosen);
    }
  }

  void _createGroup() {
    if (_selectedAvatar == null) {
      showMessageSnackBar(context, 'Vui lòng chọn ảnh đại diện');
      return;
    }
    if (_groupName.text.isEmpty || _groupDesc.text.isEmpty) {
      showMessageSnackBar(context, 'Vui lòng điền đầy đủ thông tin');
      return;
    }
    if (_selectedUsers.isEmpty) {
      showMessageSnackBar(context, 'Vui lòng chọn ít nhất 1 thành viên');
      return;
    }


    context.read<CreateGroupCubit>().submit(
      groupName: _groupName.text.trim(),
      groupDescription: _groupDesc.text.trim(),
      avatarId: _selectedAvatar!.id,
      members: _selectedUsers.map((u) => u.id).toList(),
    );
  }
}





class UsersSheet extends StatefulWidget {
  const UsersSheet({super.key, this.initialSelected = const []});
  final List<User> initialSelected;

  @override
  State<UsersSheet> createState() => _UsersSheetState();
}

class _UsersSheetState extends State<UsersSheet> {
  final TextEditingController _searchCtl = TextEditingController();
  final Set<int> _selectedIds = {}; // chỉ lưu id để toggle nhanh

  @override
  void initState() {
    super.initState();
    // nạp các id đã chọn trước đó
    _selectedIds.addAll(widget.initialSelected.map((e) => e.id));

  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SizedBox(
        height: h * 0.75,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Chọn thành viên',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text('Đã chọn: ${_selectedIds.length}'),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtl,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tên hoặc email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: 8),

            // Danh sách
            Expanded(
              child: BlocBuilder<UsersCubit, UsersState>(
                buildWhen: (p, c) =>
                p.loading != c.loading || p.users != c.users || p.error != c.error,
                builder: (context, state) {
                  if (state.loading == true) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null && state.error!.isNotEmpty) {
                    return Center(child: Text(state.error!));
                  }
                  var users = List.from(state.users.where((u) => u.id != Util.userId));
                  final q = _searchCtl.text.trim().toLowerCase();
                  if (q.isNotEmpty) {
                    users = users.where((u) =>
                    u.name.toLowerCase().contains(q) ||
                        u.email!.toLowerCase().contains(q)
                    ).toList();
                  }
                  if (users.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.2),
                    itemBuilder: (_, i) {
                      final u = users[i];
                      final checked = _selectedIds.contains(u.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage('https://cataas.com/cat?u=${u.id}&w=80&h=80'),
                        ),
                        title: Text(u.name),
                        subtitle: Text(u.email??'', style: const TextStyle(color: Colors.white70)),
                        trailing: Checkbox(
                          value: checked,
                          onChanged: (_) {
                            setState(() {
                              if (checked) {
                                _selectedIds.remove(u.id);
                              } else {
                                _selectedIds.add(u.id);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (checked) {
                              _selectedIds.remove(u.id);
                            } else {
                              _selectedIds.add(u.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Đóng'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final state = context.read<UsersCubit>().state;
                        final allUser = state.users;

                        // map id đã chọn -> object User
                        final selectedUser = allUser.where((u) => _selectedIds.contains(u.id) || u.id == Util.userId).toList();
                        Navigator.pop(context, selectedUser);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _ListUser extends StatefulWidget {
  final List<User> users;
  const _ListUser({required this.users});

  @override
  State<_ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<_ListUser> {
  final List<User> _localSelected = [];

  @override
  Widget build(BuildContext context) {
    final users = widget.users;
    if (users.isEmpty) {
      return const Center(child: Text('Không có dữ liệu'));
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Chọn thành viên', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (_, i) => AvatarTile(
                key: ValueKey(users[i].id),
                url: 'https://cataas.com/cat?unique=$i&width=80&height=80',
                selected: _localSelected.contains(users[i]),
                onTap: () => setState(() => _localSelected.add(users[i])),
                name: users[i].name,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 16)
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _localSelected.isEmpty
                ? null
                : () => Navigator.pop(context,_localSelected),
            icon: const Icon(Icons.check),
            label: const Text('Chọn'),
          ),
        ),
      ],
    );
  }
}
