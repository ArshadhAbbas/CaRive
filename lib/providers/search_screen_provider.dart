import 'package:flutter/material.dart';

class SearchScreenState extends ChangeNotifier {
  String? selectedFuel;
  String? selectedSeatCapacity;
  RangeValues priceRange = const RangeValues(1000, 10000);
  RangeLabels priceRangeLabels = const RangeLabels('1000', '10000');
  int? minPrice;
  int? maxPrice;
  String? searchQuery;

  void updateSearchQuery(String query)
  {
    searchQuery=query;
    notifyListeners();
  }

  void updateSelectedFuel(String? value) {
    selectedFuel = value;
    notifyListeners();
  }

  void updateSelectedSeatCapacity(String? value) {
    selectedSeatCapacity = value;
    notifyListeners();
  }

  void updatePriceRange(RangeValues value) {
    priceRange = value;
    minPrice = value.start.toInt();
    maxPrice = value.end.toInt();
    priceRangeLabels = RangeLabels(
      value.start.toInt().toString(),
      value.end.toInt().toString(),
    );
    notifyListeners();
  }
}
