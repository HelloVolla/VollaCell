import 'package:flutter/material.dart';
import 'package:kaonic/theme/theme.dart';

class IconCircleButton extends StatelessWidget {
  const IconCircleButton(
      {super.key, required this.icon, required this.onTap, this.color});

  final IconData icon;
  final Color? color;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color ?? AppColors.grey1,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Align(
              child: Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
