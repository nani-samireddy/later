import '../../../core/database/app_database.dart' hide Thing;
import '../../things/domain/thing.dart';

enum EntrySort { newest, title, date, amount }

enum MoneyType { all, owedToMe, iOwe, spending }

class EntryFilters {
  final String query;
  final String? category;
  final ThingStatus? status;
  final MoneyType moneyType;
  final bool? settled;
  final DateTime? start;
  final DateTime? end;
  final EntrySort sort;
  const EntryFilters({
    this.query = '',
    this.category,
    this.status,
    this.moneyType = MoneyType.all,
    this.settled,
    this.start,
    this.end,
    this.sort = EntrySort.newest,
  });

  bool _matches(String text) =>
      text.toLowerCase().contains(query.trim().toLowerCase());
  bool _date(DateTime? date) {
    if (start == null && end == null) return true;
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    return (start == null ||
            !day.isBefore(DateTime(start!.year, start!.month, start!.day))) &&
        (end == null ||
            !day.isAfter(DateTime(end!.year, end!.month, end!.day)));
  }

  int _dates(DateTime? a, DateTime? b) => a == null
      ? (b == null ? 0 : 1)
      : b == null
      ? -1
      : a.compareTo(b);
  List<Thing> things(Iterable<Thing> entries) {
    final result = entries
        .where(
          (e) =>
              _matches('${e.title} ${e.description} ${e.category}') &&
              (category == null || e.category == category) &&
              (status == null || e.status == status) &&
              _date(e.reminderDate),
        )
        .toList();
    result.sort((a, b) {
      final comparison = switch (sort) {
        EntrySort.title => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        EntrySort.date => _dates(a.reminderDate, b.reminderDate),
        _ => b.id.compareTo(a.id),
      };
      return comparison == 0 ? b.id.compareTo(a.id) : comparison;
    });
    return result;
  }

  List<MoneyEntry> money(Iterable<MoneyEntry> entries) {
    final result = entries
        .where(
          (e) =>
              _matches(
                '${e.person} ${e.reason} ${e.currency} ${e.amount.toStringAsFixed(2)}',
              ) &&
              switch (moneyType) {
                MoneyType.all => true,
                MoneyType.spending => e.kind == 'spending',
                MoneyType.owedToMe => e.kind != 'spending' && e.owedToMe,
                MoneyType.iOwe => e.kind != 'spending' && !e.owedToMe,
              } &&
              (settled == null ||
                  (e.kind != 'spending' && e.settled == settled)) &&
              _date(e.kind == 'spending' ? e.createdAt : e.dueDate),
        )
        .toList();
    result.sort((a, b) {
      final comparison = switch (sort) {
        EntrySort.title => a.person.toLowerCase().compareTo(
          b.person.toLowerCase(),
        ),
        EntrySort.date => _dates(
          a.kind == 'spending' ? a.createdAt : a.dueDate,
          b.kind == 'spending' ? b.createdAt : b.dueDate,
        ),
        EntrySort.amount => b.amount.compareTo(a.amount),
        EntrySort.newest => b.createdAt.compareTo(a.createdAt),
      };
      return comparison == 0 ? b.id.compareTo(a.id) : comparison;
    });
    return result;
  }
}
