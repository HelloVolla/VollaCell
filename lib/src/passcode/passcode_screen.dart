import 'package:kaonic/data/repository/passcode_repository.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/src/passcode/bloc/passcode_bloc.dart';
import 'package:kaonic/src/passcode/keyboard_widget.dart';
import 'package:kaonic/src/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';
import 'package:kaonic/utils/snackbar_util.dart';

enum PasscodeMode {
  enter,
  create,
}

/// If username is not null - [PasscodeMode.create] mode activated
/// otherwise  - [PasscodeMode.enter] mode is active
///
/// In case[PasscodeMode.enter] mode - it MUST return bool value on pop (??????)
/// In case[PasscodeMode.create] mode - it MUST return passcode [String] value on pop
class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({this.username, super.key});
  final String? username;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  late final PasscodeBloc _bloc;

  @override
  void initState() {
    _bloc = PasscodeBloc(
        mode:
            widget.username != null ? PasscodeMode.create : PasscodeMode.enter,
        passcodeRepository: PasscodeRepository(storageService: context.read()));
    super.initState();
  }

  void _listenStates(BuildContext context, PasscodeState state) {
    if (state is PasscodeRepeatNotMatch) {
      SnackBarUtil.showError(context, error: S.of(context).passcodeNotMatch);
      return;
    }
    if (state is PasscodeEnterFailure) {
      SnackBarUtil.showError(context, error: S.of(context).invalidPasscode);
      return;
    }
    if (state is PasscodeCreatedSuccess) {
      Navigator.of(context).pop(state.code);
      return;
    }
    if (state is PasscodeEnterSuccess) {
      Navigator.of(context).pop(state.code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: BlocProvider(
        create: (context) => _bloc,
        child: BlocListener<PasscodeBloc, PasscodeState>(
          listener: _listenStates,
          child: Padding(
            padding:
                EdgeInsets.only(top: 10.h + MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                const AppBackButton(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                BlocBuilder<PasscodeBloc, PasscodeState>(
                  builder: (context, state) => Text(
                    _title(state, context),
                    style: TextStyles.text20Bold.copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                BlocBuilder<PasscodeBloc, PasscodeState>(
                  builder: (context, state) => PasscodeWidget(
                    onChanged: (code) => _bloc.add(PasscodeChanged(code: code)),
                    code: state.code,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _title(PasscodeState state, BuildContext context) {
    if (state is PasscodeCreate) return S.of(context).createPasscode;
    if (state is PasscodeRepeat ||
        state is PasscodeRepeatNotMatch ||
        state is PasscodeCreatedSuccess) {
      return S.of(context).repeatPasscode;
    }

    return S.of(context).enterPasscode;
  }
}
