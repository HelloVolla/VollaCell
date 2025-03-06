import 'package:flutter/material.dart';
import 'package:kaonic/theme/theme.dart';

class ScreenContainer extends StatelessWidget {
  const ScreenContainer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: child),
    );
  }
}
