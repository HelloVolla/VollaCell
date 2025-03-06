import 'package:flutter/material.dart';
import 'package:kaonic/theme/theme.dart';

abstract class TextStyles {
  static const text36 = TextStyle(fontSize: 36, color: AppColors.black);
  static final text36Bold = text36.copyWith(fontWeight: FontWeight.bold);

  /// 24
  static const text24 = TextStyle(fontSize: 24, color: AppColors.black);

  /// 20
  static const text20 = TextStyle(fontSize: 20, color: AppColors.black);
  static final text20Bold = text20.copyWith(fontWeight: FontWeight.bold);

  /// 18
  static const text18 = TextStyle(fontSize: 18, color: AppColors.black);
  static final text18Bold = text18.copyWith(fontWeight: FontWeight.bold);

  /// 16
  static const text16 = TextStyle(fontSize: 16, color: AppColors.black);

  /// 14
  static const text14 = TextStyle(fontSize: 14, color: AppColors.black);
}
