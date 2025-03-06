import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';

enum MainButtonStyle { solid, stroke }

class MainButton extends StatelessWidget {
  const MainButton(
      {required this.label,
      this.onPressed,
      this.width,
      this.style = MainButtonStyle.solid,
      this.removePadding = false,
      super.key});
  final String label;
  final VoidCallback? onPressed;
  final MainButtonStyle style;
  final double? width;
  final bool removePadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      width: width ?? 200.w,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: AppColors.yellowGradient,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  color: AppColors.yellow,
                )
              ],
              borderRadius: BorderRadius.circular(32)),
          child: ElevatedButton(
            style: ButtonStyle(
              padding: removePadding
                  ? const WidgetStatePropertyAll(EdgeInsets.zero)
                  : null,
              shadowColor: WidgetStateColor.transparent,
              backgroundColor: WidgetStateColor.transparent,
              shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32))),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: TextStyles.text16,
            ),
          ),
        ),
      ),
    );
  }
}
