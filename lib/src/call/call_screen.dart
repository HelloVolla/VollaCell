import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/data/models/mesh_call.dart';
import 'package:kaonic/service/communication_service.dart';
import 'package:kaonic/src/call/bloc/call_bloc.dart';
import 'package:kaonic/src/widgets/icon_circle_button.dart';
import 'package:kaonic/src/widgets/screen_container.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocProvider(
        create: (context) => CallBloc(
            communicationService: context.read<CommunicationService>()),
        child: Scaffold(
          body: ScreenContainer(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 10.h + MediaQuery.of(context).padding.top,
                bottom: 10.h + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: BlocConsumer<CallBloc, CallState>(
                      listener: (context, state) {
                        if (state is EndCallState) {
                          Navigator.of(context).pop();
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.call?.status.getTitle(state
                                          .usernameAddressHex
                                          ?.substring(0, 5) ??
                                      'Unknown') ??
                                  '',
                              style: TextStyles.text24
                                  .copyWith(color: Colors.white),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(bottom: 150.h, top: 25.h),
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                    color: AppColors.grey2,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: EdgeInsets.all(30.w),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 70,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: Durations.medium2,
                              child: switch (state.call?.status) {
                                MeshCallStatuses.incomingCall => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconCircleButton(
                                        icon: Icons.call_end,
                                        onTap: () {
                                          context
                                              .read<CallBloc>()
                                              .add(EndCall());
                                        },
                                        color: AppColors.negative,
                                      ),
                                      IconCircleButton(
                                        icon: Icons.call,
                                        onTap: () {
                                          context
                                              .read<CallBloc>()
                                              .add(AcceptCall());
                                        },
                                        color: AppColors.positive,
                                      )
                                    ],
                                  ),
                                MeshCallStatuses.outcomeCall ||
                                MeshCallStatuses.inCall =>
                                  IconCircleButton(
                                    icon: Icons.call_end,
                                    onTap: () {
                                      context.read<CallBloc>().add(EndCall());
                                    },
                                    color: AppColors.negative,
                                  ),
                                MeshCallStatuses.ended => Opacity(
                                    opacity: 0.5,
                                    child: IconCircleButton(
                                      icon: Icons.call_end,
                                      onTap: () {},
                                      color: AppColors.negative,
                                    ),
                                  ),
                                _ => const SizedBox(),
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
