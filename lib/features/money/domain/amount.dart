double? parseAmount(String value) {
  final text = value.trim();
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(text)) return null;
  final amount = double.tryParse(text);
  return amount != null && amount.isFinite && amount > 0 ? amount : null;
}
