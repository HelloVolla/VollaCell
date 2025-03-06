import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/routes.dart';
import 'package:kaonic/src/sign_up/bloc/sign_up_bloc.dart';
import 'package:kaonic/src/widgets/back_button.dart';
import 'package:kaonic/src/widgets/main_button.dart';
import 'package:kaonic/src/widgets/main_text_field.dart';
import 'package:kaonic/src/widgets/screen_container.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/utils/snackbar_util.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpBloc _bloc;
  final usernameController = TextEditingController();

  @override
  void initState() {
    _bloc = SignUpBloc(userService: context.read());
    super.initState();
  }

  void _listenStates(BuildContext context, SignUpState state) {
    if (state is SignUpUsernameExistError) {
      SnackBarUtil.showError(context, error: S.of(context).userExistError);

      return;
    }

    if (state is SignUpUserCreated) {
      Navigator.of(context)
          .pushReplacementNamed(Routes.saveBackup, arguments: state.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        body: SingleChildScrollView(
          child: BlocListener<SignUpBloc, SignUpState>(
            listenWhen: (previous, current) =>
                current is SignUpUsernameExistError ||
                current is SignUpUserCreated,
            listener: _listenStates,
            child: ScreenContainer(
              child: Flex(
                direction: Axis.vertical,
                children: [
                  SizedBox(
                    height: 24.h + MediaQuery.of(context).padding.top,
                  ),
                  AppBackButton(label: S.of(context).signUp),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              S.of(context).createUsername,
                              style: TextStyles.text20
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                child: MainTextField(
                                  controller: usernameController,
                                  onChange: (value) => _bloc
                                      .add(UsernameChanged(username: value)),
                                )),
                          ],
                        ),
                        BlocBuilder<SignUpBloc, SignUpState>(
                          builder: (context, state) => MainButton(
                            label: S.of(context).signUp,
                            onPressed: state.signUpBtnEnabled
                                ? () => _createPasscode(
                                    context, usernameController.text)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPasscode(BuildContext context, String username) async {
    final passcode = await Navigator.of(context)
        .pushNamed(Routes.passcode, arguments: username);
    if (passcode is String) {
      _bloc.add(PasscodeCreated(passcode: passcode));
    }
  }
}
