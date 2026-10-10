import 'dart:async';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'payment_screenshot_parser.dart';

typedef PaymentReview = FutureOr<void> Function(PaymentScreenshotData);

/// Holds the intake lock until the review sheet is dismissed. Home should return
/// its sheet Future from onPayment and provide isReviewOpen for manual capture.
class SharedPaymentService {
  SharedPaymentService({Future<PaymentScreenshotData?> Function(String)? parse})
    : _parse = parse ?? PaymentScreenshotParser.parse;
  final Future<PaymentScreenshotData?> Function(String) _parse;
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _busy = false;
  bool _disposed = false;
  final Map<String, DateTime> _recent = {};

  Future<void> handle(
    List<SharedMediaFile> files,
    PaymentReview onPayment, {
    void Function(String)? onFeedback,
    bool Function()? isReviewOpen,
  }) async {
    if (_disposed) return;
    final images = files
        .where((f) => f.type == SharedMediaType.image && f.path.isNotEmpty)
        .toList();
    if (images.isEmpty) {
      onFeedback?.call('Share one payment screenshot image to Later.');
      return;
    }
    if (images.length != 1) {
      onFeedback?.call(
        'Share one screenshot at a time. No images were imported.',
      );
      return;
    }
    final key = images.single.path;
    final now = DateTime.now();
    _recent.removeWhere(
      (_, time) => now.difference(time) > const Duration(seconds: 5),
    );
    if (_recent.containsKey(key)) return;
    if (_busy || (isReviewOpen?.call() ?? false)) {
      onFeedback?.call(
        'Finish the open entry, then share this screenshot again.',
      );
      return;
    }
    _busy = true;
    _recent[key] = now;
    try {
      final data = await _parse(key);
      if (_disposed) return;
      if (data == null) {
        onFeedback?.call(
          'Could not read this image. Share it again or enter the details manually.',
        );
      } else {
        await onPayment(data);
      }
    } catch (_) {
      if (!_disposed) {
        onFeedback?.call(
          'Could not read the shared image. Share it again or enter the details manually.',
        );
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> start(
    PaymentReview onPayment, {
    void Function(String)? onFeedback,
    bool Function()? isReviewOpen,
  }) async {
    if (_disposed || _subscription != null) return;
    Future<void> receive(List<SharedMediaFile> files) => handle(
      files,
      onPayment,
      onFeedback: onFeedback,
      isReviewOpen: isReviewOpen,
    );
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) {
        unawaited(receive(files));
      },
      onError: (Object _) =>
          onFeedback?.call('Screenshot sharing failed. Please try again.'),
    );
    try {
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      // Reset before waiting for user review so stale cold-start data cannot recur.
      await ReceiveSharingIntent.instance.reset();
      if (initial.isNotEmpty) await receive(initial);
    } catch (_) {
      if (!_disposed) {
        onFeedback?.call(
          'Could not load the shared screenshot. Please share it again.',
        );
      }
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
  }
}
