
import 'package:chat_app/core/widgets/choose_avatar.dart';
import 'package:chat_app/features/auth/presentation/blocs/auth_event.dart';
import 'package:chat_app/features/auth/presentation/widgets/build_promt.dart';
import 'package:chat_app/features/conversation/presentation/blocs/group/avatars_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/consts/const.dart';
import '../../../../../core/routes/router_app_name.dart';
import '../../../../conversation/domain/entities/avatar.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../widgets/build_button.dart';
import '../../widgets/build_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final _nameTextController;

  late final _emailTextController;
  late final _passwordTextController;
  Avatar? _selectedAvatar;

  @override
  void initState() {
    _nameTextController = TextEditingController();
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    super.initState();
    context.read<AvatarsCubit>().load(isUserAvatars:true);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is AuthSuccess) {
            context.goNamed(AppRouteInfor.loginName);
          }
        },

        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return CircularProgressIndicator();
                  } else if (state is AuthFailure) {
                    return Text(state.error, style: TextStyle(color: Colors.red));
                  }
                  return Container();
                },
              ),
              ChooseAvatar(onChooseAvatar: (avatar){
                _selectedAvatar = avatar;
              }),
              SizedBox(height: paddingCustom(context)),
              Text('Sign Up', style: theme.textTheme.titleLarge),
              SizedBox(height: paddingCustom(context)),
              BuildTextField(
                hint: 'Enter your name',
                icon: Icons.person,
                controller: _nameTextController,
              ),
              BuildTextField(
                hint: 'Enter your email',
                icon: Icons.email,
                controller: _emailTextController,
              ),
              BuildTextField(
                hint: 'Enter your password',
                icon: Icons.lock,
                controller: _passwordTextController,
                obscureText: true,
              ),
              SizedBox(height: paddingCustom(context)),
              BuildButton(
                title: 'Sign Up',
                onPressed: () {
                  print('email ${_emailTextController.text}');
                  print('password ${_passwordTextController.text}');
                  print('name ${_nameTextController.text}');
                  context.read<AuthBloc>().add(
                    AuthSignUpEvent(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                      name: _nameTextController.text,
                      avatarId: _selectedAvatar!.id
                    ),
                  );
                },
              ),
              SizedBox(height: paddingCustom(context)),
              BuildPromt(
                title: 'Login',
                subTitle: 'Already have an account? ',
                onTap: () => context.goNamed(AppRouteInfor.loginName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
