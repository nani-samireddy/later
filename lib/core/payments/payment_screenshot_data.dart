import '../ai/local_entry_data.dart';

class PaymentScreenshotData {
  final String text;
  final String amount;
  final String merchant;
  final String attachmentPath;
  final LocalEntryData? aiData;

  const PaymentScreenshotData({
    required this.text,
    required this.amount,
    required this.merchant,
    required this.attachmentPath,
    this.aiData,
  });
}
