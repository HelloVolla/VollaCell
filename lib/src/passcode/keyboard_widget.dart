import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasscodeWidget extends StatelessWidget {
  PasscodeWidget({required this.onChanged, this.code, super.key});
  final String? code;
  final ValueChanged<String> onChanged;

  final keySize = 40.w;

  final itemSpacing = 36.w;

  final rowSpacing = 20.w;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Wrap(
            spacing: 23.w,
            children: [
              _codeDot(filled: !(code?.isEmpty ?? false)),
              _codeDot(filled: (code?.length ?? 0) > 1),
              _codeDot(filled: (code?.length ?? 0) > 2),
              _codeDot(filled: (code?.length ?? 0) > 3),
            ],
          ),
          SizedBox(
            height: 28.h,
          ),
          _keyboard(),
        ],
      ),
    );
  }

  Widget _keyboard() => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Wrap(
            spacing: itemSpacing,
            children: [
              _number('1'),
              _number('2'),
              _number('3'),
            ],
          ),
          SizedBox(
            height: rowSpacing,
          ),
          Wrap(
            spacing: itemSpacing,
            children: [
              _number('4'),
              _number('5'),
              _number('6'),
            ],
          ),
          SizedBox(
            height: rowSpacing,
          ),
          Wrap(
            spacing: itemSpacing,
            children: [
              _number('7'),
              _number('8'),
              _number('9'),
            ],
          ),
          SizedBox(
            height: rowSpacing,
          ),
          Wrap(
            spacing: itemSpacing,
            alignment: WrapAlignment.end,
            children: [_number('0'), _erase()],
          ),
        ],
      );

  Widget _number(String number) => InkWell(
        customBorder: const CircleBorder(),
        splashColor: AppColors.grey1,
        onTap: () => onChanged(code == null
            ? number
            : code!.length > 3
                ? code!
                : '$code$number'),
        child: SizedBox(
          width: keySize,
          height: keySize,
          child: Center(
            child: Text(
              number,
              style: TextStyles.text20.copyWith(color: AppColors.white),
            ),
          ),
        ),
      );

  Widget _codeDot({required bool filled}) => SizedBox(
        width: 8.w,
        height: 8.w,
        child: DecoratedBox(
            decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.white : AppColors.grey4,
        )),
      );

  Widget _erase() => InkWell(
        customBorder: const CircleBorder(),
        splashColor: AppColors.grey1,
        onTap: () => onChanged(
            code?.isEmpty ?? true ? '' : code!.substring(0, code!.length - 1)),
        child: SizedBox(
          width: keySize,
          height: keySize,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.backspace_outlined,
                color: AppColors.white,
                size: 20,
              ),
            ],
          ),
        ),
      );
}
