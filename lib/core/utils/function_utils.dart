import 'dart:math';

String generateRandomId(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => characters.codeUnitAt(
        random.nextInt(characters.length),
      ),
    ),
  );
}

bool isExpired(DateTime endDate) {
  final now = DateTime.now();
  return endDate.isBefore(now);
}

// Duration unit = month
DateTime calculateEndDateFromDuration(int duration) {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
  int newMonth = now.month + duration;
  int yearAdjustment =
      (newMonth - 1) ~/ 12; // Handle overflow of months into the next year
  int finalMonth = ((newMonth - 1) % 12) + 1;

  // Return the adjusted DateTime
  return DateTime(
    now.year + yearAdjustment,
    finalMonth,
    now.day,
    now.hour,
    now.minute,
    now.second,
  );
}
