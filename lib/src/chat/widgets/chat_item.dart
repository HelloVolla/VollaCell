import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:kaonic/data/models/kaonic_message_event.dart';
import 'package:kaonic/data/extensions/date_extension.dart';
import 'package:kaonic/generated/l10n.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';
import 'package:open_file/open_file.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.message,
    required this.peerAddress,
  });

  final MessageEvent message;
  final String peerAddress;

  @override
  Widget build(BuildContext context) {
    final bool isMyMessage = message.address == peerAddress;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      margin: EdgeInsets.only(
        left: isMyMessage ? 40.w : 0,
        right: isMyMessage ? 0 : 40.w,
      ),
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMyMessage) ...[
                Text(
                  S.of(context).username,
                  style: TextStyles.text14
                      .copyWith(color: AppColors.white.withValues(alpha: 0.5)),
                ),
                SizedBox(width: 10.w),
              ],
              Text(
                DateTime.fromMillisecondsSinceEpoch(message.timestamp)
                    .hMMFormat,
                style: TextStyles.text14
                    .copyWith(color: AppColors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
          _child(isMyMessage),
        ],
      ),
    );
  }

  Widget _child(bool isMyMessage) {
    switch (message) {
      case MessageTextEvent m:
        return Text(
          m.text ?? "",
          textAlign: isMyMessage ? TextAlign.end : TextAlign.start,
          style: TextStyles.text14.copyWith(color: Colors.white),
        );
      case MessageFileEvent f:
        return GestureDetector(
            onTap: f.path == null ? null : () => OpenFile.open(f.path!),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.file_present_rounded, color: Colors.white),
                SizedBox(width: 16),
                Row(
                  children: [
                    if (f.path == null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: const SizedBox(
                            width: 7,
                            height: 7,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.yellow,
                            )),
                      ),
                    if (message.address != peerAddress)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.upload,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    Text(
                      '${(f.fileSize / 1024).toStringAsFixed(1)} kB',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              ],
            ));
    }

    return const SizedBox.shrink();
  }
}
