import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaonic/theme/theme.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({super.key, required this.icon, required this.onTap});

  final String icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          child: Align(
            child: SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
