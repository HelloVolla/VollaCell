import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:kaonic/data/models/mesh_message.dart';
import 'package:kaonic/theme/text_styles.dart';
import 'package:kaonic/theme/theme.dart';
import 'package:open_file/open_file.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.message,
    required this.myAddress,
  });

  final MeshMessage message;
  final String myAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey3),
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      margin: EdgeInsets.only(
          left: message.senderAddress == myAddress ? 100.w : 0,
          right: message.senderAddress == myAddress ? 0 : 100.w),
      child: _child(),
    );
  }

  Widget _child() {
    switch (message) {
      case MeshTextMessage m:
        return Text(
          m.message,
          style: TextStyles.text14.copyWith(color: Colors.white),
        );
      case MeshFileMessage f:
        return GestureDetector(
            onTap:
                f.localPath == null ? null : () => OpenFile.open(f.localPath!),
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.file_present_rounded, color: Colors.white),
                    SizedBox(
                      width: 16,
                    ),
                    Row(
                      children: [
                        if (f.localPath == null)
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
                          if(message.senderAddress != myAddress)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.upload,color: Colors.grey,size: 16,),
                          ),
                        Text(
                          '${((f.bytes?.length ?? 0) / 1024).toStringAsFixed(1)} kB',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ));
    }

    return const SizedBox.shrink();
  }
}
