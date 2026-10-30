/// Pure functions: testable without widgets, Flutter, or intl.
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Route parameter -> id. Returns null for missing or invalid input.
int? parseRouteId(String? raw) => int.tryParse(raw ?? '');
