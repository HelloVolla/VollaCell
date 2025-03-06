import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/theme/theme.dart';

class SnackBarUtil {
  static void showSuccessMessage(BuildContext context,
          {required String message}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.grey3,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      ));

  static void showError(BuildContext context, {required String error}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          error,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      ));
}
