import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class SpeechModelStore {
  static const _modelRepository =
      'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-20M-2023-02-17/resolve/main';
  static const files = [
    'encoder-epoch-99-avg-1.int8.onnx',
    'decoder-epoch-99-avg-1.int8.onnx',
    'joiner-epoch-99-avg-1.int8.onnx',
    'tokens.txt',
  ];

  static Future<String> ensureModel() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(path.join(root.path, 'speech', 'zipformer-en'));
    await directory.create(recursive: true);
    final client = HttpClient();
    try {
      for (final fileName in files) {
        final target = File(path.join(directory.path, fileName));
        if (await target.exists() && await target.length() > 0) continue;
        final request = await client.getUrl(
          Uri.parse('$_modelRepository/$fileName?download=true'),
        );
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Unable to download speech model file: $fileName',
            uri: request.uri,
          );
        }
        final sink = target.openWrite();
        await response.pipe(sink);
        await sink.close();
      }
    } finally {
      client.close(force: true);
    }
    return directory.path;
  }
}
