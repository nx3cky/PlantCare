/// Форматування дат українською без пакета intl:
/// «04.10.2026», «4 жовтня», «Сьогодні, 4 жовтня», «через 2 дні».
abstract final class DateFormatUa {
  static const _monthsGenitive = [
    'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
    'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
  ];

  static const _months = [
    'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
    'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень',
  ];

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// 04.10.2026
  static String date(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

  /// 04.10
  static String shortDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}';

  /// 09:05
  static String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  /// 04.10.2026, 09:05
  static String dateTime(DateTime d) => '${date(d)}, ${time(d)}';

  /// 4 жовтня
  static String dayMonth(DateTime d) => '${d.day} ${_monthsGenitive[d.month - 1]}';

  /// Жовтень 2026
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// Початок доби (00:00) – для порівняння дат без часу.
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Дата через [days] календарних днів (00:00). На відміну від
  /// add(Duration(days: n)) не зсувається через перехід на літній/зимовий час.
  static DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  /// Кількість діб між датами без урахування часу (може бути від'ємною).
  /// Рахується в UTC, щоб перехід на літній час не давав 23-годинну добу.
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;

  /// Заголовок групи журналу: «Сьогодні, 4 жовтня», «Вчора, 3 жовтня», «1 жовтня».
  static String dayHeader(DateTime d, DateTime today) {
    final diff = daysBetween(d, today);
    final label = dayMonth(d);
    if (diff == 0) return 'Сьогодні, $label';
    if (diff == 1) return 'Вчора, $label';
    return d.year == today.year ? label : '$label ${d.year}';
  }

  /// Відмінювання іменника після числа: 1 день, 2 дні, 5 днів.
  static String plural(int n, String one, String few, String many) {
    final mod10 = n.abs() % 10;
    final mod100 = n.abs() % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }

  /// 1 день, 3 дні, 14 днів
  static String days(int n) => '$n ${plural(n, 'день', 'дні', 'днів')}';

  /// Відносний термін наступної процедури: «сьогодні», «завтра», «через 2 дні»,
  /// «прострочено на 1 день».
  static String relative(int daysLeft) {
    if (daysLeft == 0) return 'сьогодні';
    if (daysLeft == 1) return 'завтра';
    if (daysLeft > 1) return 'через ${days(daysLeft)}';
    return 'прострочено на ${days(-daysLeft)}';
  }
}
