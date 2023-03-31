import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    this.content,
    this.actions,
  });

  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          const Icon(Icons.error),
          Text('error'.tr),
        ],
      ),
      content: content,
      actions: actions ??
          [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('ok'.tr),
            ),
          ],
    );
  }
}
