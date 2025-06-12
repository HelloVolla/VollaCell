import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';

class MainTextField extends StatelessWidget {
  MainTextField({
    this.hint,
    this.onChange,
    this.controller,
    this.suffix,
    this.prefix,
    this.keyboardType,
    super.key,
  });

  final String? hint;
  final ValueChanged<String>? onChange;
  final TextEditingController? controller;
  final Widget? suffix;
  final Widget? prefix;
  final TextInputType? keyboardType;

  // final _baseBorder = OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(22),
  //     borderSide: const BorderSide(color: AppColors.grey3));

  final _baseBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.white));

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      controller: controller,
      // cursorColor: AppColors.grey3,
      cursorColor: AppColors.white,
      keyboardType: keyboardType,
      style: TextStyles.text14.copyWith(color: Colors.white),
      decoration: InputDecoration(
        isDense: false,
        // fillColor: AppColors.grey2,
        suffixIcon: suffix,
        prefixIcon: prefix,
        fillColor: Colors.transparent,
        filled: true,
        hintText: hint ?? S.of(context).hint,
        hintStyle: TextStyles.text14
            .copyWith(fontStyle: FontStyle.italic, color: AppColors.grey3),
        contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 32.w),
        border: InputBorder.none,
        focusedBorder: _baseBorder,
        // suffixIcon: suffix,
      ),
    );
  }
}
