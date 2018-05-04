import 'dart:async';

import 'package:flutter/services.dart';

copyToClipboard(String value,
    {bool clearAfterTimeout = false,
    Duration clearTimeout = const Duration(seconds: 60)}) {
  Clipboard.setData(ClipboardData(text: value));
  if (clearAfterTimeout) {
    Future.delayed(clearTimeout, () async {
      final data = await Clipboard.getData('text/plain');
      if (data?.text == value) {
        Clipboard.setData(ClipboardData(text: ''));
      }
    });
  }
}
