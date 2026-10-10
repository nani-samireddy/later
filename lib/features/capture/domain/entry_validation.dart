import '../../money/domain/amount.dart';

String? validateEntry({
  required String kind,
  required String description,
  required String person,
  required String amount,
}) {
  if (!{'thing', 'owedToMe', 'iOwe', 'spending'}.contains(kind)) {
    return 'Choose an entry type.';
  }
  if (kind == 'thing') {
    return description.trim().isEmpty ? 'Enter a title for your item.' : null;
  }
  if (parseAmount(amount) == null) {
    return 'Enter an amount greater than zero, with up to two decimal places.';
  }
  if (kind != 'spending' && person.trim().isEmpty) {
    return 'Enter the person’s name.';
  }
  return null;
}
