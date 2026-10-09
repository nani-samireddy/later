import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'payment_screenshot_parser.dart';

class SharedPaymentService {
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  Future<void> start(void Function(PaymentScreenshotData) onPayment) async {
    Future<void> handle(List<SharedMediaFile> files) async {
      final images = files.where(
        (file) => file.type == SharedMediaType.image && file.path.isNotEmpty,
      );
      if (images.isEmpty) return;
      final parsed = await PaymentScreenshotParser.parse(images.first.path);
      if (parsed != null) onPayment(parsed);
    }

    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      handle,
    );
    await handle(await ReceiveSharingIntent.instance.getInitialMedia());
    await ReceiveSharingIntent.instance.reset();
  }

  Future<void> dispose() async => _subscription?.cancel();
}
