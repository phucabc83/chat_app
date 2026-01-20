
import 'package:chat_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/blocs/auth_event.dart';
import 'package:chat_app/features/auth/presentation/widgets/build_promt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/consts/const.dart';
import '../../../../../core/routes/router_app_name.dart';
import '../../../../../core/service/socket_service.dart';
import '../../blocs/auth_state.dart';
import '../../widgets/build_button.dart';
import '../../widgets/build_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<LoginPage> {

  late final _emailTextController;
  late final _passwordTextController;

  @override
  void initState() {
    super.initState();
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go(AppRouteInfor.homePath);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return CircularProgressIndicator();
                  }
                  return const SizedBox.shrink();
                },
              ),
              Text('Sign In', style: theme.textTheme.titleLarge),
              SizedBox(height: paddingCustom(context)),
              BuildTextField(
                hint: 'Enter your email',
                icon: Icons.email,
                controller: _emailTextController,
              ),
              SizedBox(height: paddingCustom(context)),
              BuildTextField(
                hint: 'Enter your password',
                icon: Icons.lock,
                controller: _passwordTextController,
                obscureText: true,
              ),
              SizedBox(height: paddingCustom(context)),
              BuildButton(
                title: 'Sign In',
                onPressed: () {
                  context.read<AuthBloc>().add(
                    AuthLoginEvent(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    ),
                  );
                },
              ),
              SizedBox(height: paddingCustom(context)),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleSignInEvent());
                    },
                    icon: Icon(
                      FontAwesomeIcons.google,
                      size: 40,
                      color: Colors.green,
                  )
                  ),

                ],
              ),

              SizedBox(height: paddingCustom(context)),

              BuildPromt(
                title: 'Đăng ký',
                subTitle: 'Ban chưa có tài khoản ?',
                onTap: () => context.goNamed(AppRouteInfor.signUpName),
              ),
            ],
          ),
        ),
      ),]
    );
  }

}
