import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/src/widgets/solid_button.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';

abstract class DialogUtil {
  static void showDefaultDialog(
    BuildContext context, {
    required String title,
    required Function() onYes,
    String? buttonYesText,
    String? buttonNotText,
  }) =>
      showDialog(
          context: context,
          builder: (context) => Dialog(
                backgroundColor: AppColors.black,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyles.text18
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Flexible(
                            child: SolidButton(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              textButton:
                                  buttonNotText ?? S.of(context).labelNo,
                            ),
                          ),
                          // Flexible(
                          //   child: MainButton(
                          //     width: 150.w,
                          //     onPressed: () {
                          //       Navigator.of(context).pop();
                          //     },
                          //     label: buttonNotText ?? S.of(context).labelNo,
                          //   ),
                          // ),
                          SizedBox(width: 10.w),
                          Flexible(
                            child: SolidButton(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              onTap: () {
                                Navigator.of(context).pop();
                                onYes();
                              },
                              textButton:
                                  buttonNotText ?? S.of(context).labelYes,
                            ),
                          ),
                          // Flexible(
                          //     child: MainButton(
                          //         onPressed: () {
                          //           Navigator.of(context).pop();
                          //           onYes();
                          //         },
                          //         width: 150.w,
                          //         label:
                          //             buttonYesText ?? S.of(context).labelYes)),
                        ],
                      )
                    ],
                  ),
                ),
              ));
}
