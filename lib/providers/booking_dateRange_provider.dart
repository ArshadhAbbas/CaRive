import 'package:flutter/material.dart';

class BookingDateRangeProvider with ChangeNotifier {
  DateTime? startDate;
  DateTime? endDate;

  void dateRangePicker(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void cancelDateRange() {
    startDate = null;
    endDate = null;
    notifyListeners();
  }
}
