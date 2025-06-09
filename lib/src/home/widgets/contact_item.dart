import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaonic/data/models/contact_model.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({
    super.key,
    required this.contact,
    required this.onTap,
    this.onIdentifyTap,
    this.nearbyFound = false,
    this.unreadCount,
  });

  final ContactModel contact;
  final Function() onTap;
  final Function()? onIdentifyTap;
  final bool nearbyFound;
  final int? unreadCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(42),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  // gradient: AppColors.yellowGradient,
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(42)),
              child: SizedBox(
                height: 32,
                child: Align(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      'User',
                      style: TextStyles.text18Bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            flex: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                border: Border.all(color: AppColors.grey3),
              ),
              child: SizedBox(
                height: 32,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          contact.address,
                          style: TextStyles.text16
                              .copyWith(color: AppColors.grey5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onIdentifyTap != null)
                        Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(48),
                            onTap: onIdentifyTap,
                            child: Ink(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(48),
                                  color: AppColors.grey2),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                S.of(context).labelIdentify,
                                style: TextStyles.text14
                                    .copyWith(color: AppColors.grey5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: nearbyFound ? AppColors.yellow : null,
                            border: nearbyFound
                                ? null
                                : Border.all(color: AppColors.yellow),
                          ),
                          child: const SizedBox(width: 8, height: 8),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
