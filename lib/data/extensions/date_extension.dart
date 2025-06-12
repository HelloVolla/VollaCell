import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get hMMFormat {
    return DateFormat('h:mm a').format(this);
  }
}
