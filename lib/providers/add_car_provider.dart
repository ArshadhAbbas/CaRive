import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddCarProvider extends ChangeNotifier {
  String? selectedCarModel;
  String? selectedMake;
  String? selectedFuel;
  String? selectedSeatCapacity;
  String? modelYear;
  int? amount;
  String? location;
  double? latitude;
  double? longitude;
  bool? isAvailable;
  String? address;
  LatLng? selectedLocation;

  void setSelectedCarModel(String? carModel) {
    selectedCarModel = carModel;
    notifyListeners();
  }

  void setSelectedFuel(String? fuel) {
    selectedFuel = fuel;
    notifyListeners();
  }

  void setSelectedSeatCapacity(String? seatCapacity) {
    selectedSeatCapacity = seatCapacity;
    notifyListeners();
  }

  // Add methods for other properties as needed

  void setModelYear(String? year) {
    modelYear = year;
    notifyListeners();
  }

  void setAmount(int? amountValue) {
    amount = amountValue;
    notifyListeners();
  }

  void setLocation(String? locationValue) {
    location = locationValue;
    notifyListeners();
  }

  void setLatitude(double? latitudeValue) {
    latitude = latitudeValue;
    notifyListeners();
  }

  void setLongitude(double? longitudeValue) {
    longitude = longitudeValue;
    notifyListeners();
  }

  void setIsAvailable(bool? isAvailableValue) {
    isAvailable = isAvailableValue;
    notifyListeners();
  }

  void carMakeChanged(String? make) {
    setSelectedMake(make);
    setSelectedCarModel(null);
    notifyListeners();
  }

  void setSelectedMake(String? make) {
    selectedMake = make;
    notifyListeners();
  }

    void setAddress(String? newAddress) {
    address = newAddress;
    notifyListeners();
  }

  void setSelectedLocation(LatLng? location) {
    selectedLocation = location;
    notifyListeners();
  }
  
}
