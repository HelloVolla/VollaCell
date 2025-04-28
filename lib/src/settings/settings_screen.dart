import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/data/models/settings.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/src/settings/bloc/settings_bloc.dart';
import 'package:kaonic/src/widgets/main_text_field.dart';
import 'package:kaonic/src/widgets/radio_button.dart';
import 'package:kaonic/theme/assets.dart';
import 'package:kaonic/theme/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _frequencyController = TextEditingController();
  final _spacingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: Scaffold(
        body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (ctxBloc, state) => Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _appBar(),
                    _item(
                      S.current.radio,
                      child: MainTextField(
                        controller: _frequencyController,
                      ),
                    ),
                    SizedBox(height: 16),
                    _item(S.current.Frequency,
                        child: DropdownButton<OFDMOptions>(
                          items: OFDMOptions.values
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Expanded(child: Text(e.toString())),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ctxBloc
                                  .read<SettingsBloc>()
                                  .add(UpdateOption(option: value));
                            }
                          },
                        )),
                    SizedBox(height: 16),
                    _item(S.current.Channel,
                        child: DropdownButton<int>(
                          value: state.channel,
                          items: List.generate(11, (index) => index + 1)
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ctxBloc
                                  .read<SettingsBloc>()
                                  .add(UpdateChannel(channel: value));
                            }
                          },
                        )),
                    SizedBox(height: 16),
                    _item(S.current.ChannelSpacing,
                        child: MainTextField(
                          controller: _spacingController,
                        )),
                    SizedBox(height: 24),
                    _itemWithRadio(
                      S.current.OFDMOption,
                      list: OFDMOptions.values
                          .map(
                            (e) => CustomRadioButton(
                                label: e.name,
                                onChanged: (_) {},
                                groupValue: state.option,
                                value: e),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 24),
                    _itemWithRadio(
                      S.current.OFDMRate,
                      list: OFDMRate.values
                          .map(
                            (e) => CustomRadioButton(
                                label: e.name,
                                onChanged: (_) {},
                                groupValue: state.option,
                                value: e),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _itemWithRadio(
    String label, {
    required List<Widget> list,
  }) =>
      Column(
        children: [
          Text(
            S.current.OFDMOption,
            style: TextStyles.text18Bold.copyWith(color: Colors.white),
          ),
          GridView(
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3.8),
            children: list,
          ),
        ],
      );

  Widget _item(String label, {required Widget child}) => Row(
        children: [
          Text(
            label,
            style: TextStyles.text18Bold.copyWith(color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(child: child),
        ],
      );

  Widget _appBar() => Row(
        children: [
          BackButton(
            color: Colors.white,
          ),
          Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Align(
                  child: Text(
                    S.of(context).settings,
                    textAlign: TextAlign.center,
                    style: TextStyles.text24.copyWith(color: Colors.white),
                  ),
                )),
          ),
        ],
      );
}
