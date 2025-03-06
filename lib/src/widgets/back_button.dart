import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/theme/text_styles.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({this.label, this.onBack, super.key});
  final String? label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(
            width: 22.w,
          ),
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          SizedBox(
            width: 10.w,
          ),
          Text(
            label ?? S.of(context).back,
            style: TextStyles.text24.copyWith(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
