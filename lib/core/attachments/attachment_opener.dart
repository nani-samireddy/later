import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import 'stored_attachment.dart';

Future<void> openAttachment(
  BuildContext context,
  StoredAttachment attachment,
) async {
  void message(String text) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  if (!await File(attachment.path).exists()) {
    message('This file is missing. Remove it and attach a new copy.');
    return;
  }
  if (!context.mounted) return;
  if (attachment.kind == 'image') {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(attachment.name)),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(attachment.path),
                errorBuilder: (_, _, _) =>
                    const Text('This image could not be opened.'),
              ),
            ),
          ),
        ),
      ),
    );
  } else {
    try {
      final result = await OpenFilex.open(attachment.path);
      if (result.type != ResultType.done) {
        message(
          'Could not open this file. Install an app that supports its format.',
        );
      }
    } catch (_) {
      message('Could not open this file. Try again.');
    }
  }
}
