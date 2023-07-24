import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionProvider extends ChangeNotifier {
  String? address;
  Set<Marker>? markers; // Set to hold the selected marker
  LatLng? selectedLatLng;
  bool? isCurrentLocationSelected;

  void setMarkerEmpty() {
    markers = {};
    notifyListeners();
  }

  void setLatLng(LatLng latLng) {
    selectedLatLng = latLng;
    notifyListeners();
  }

  void setCurrentLocationFalse() {
    isCurrentLocationSelected = false;
    notifyListeners();
  }
   void setCurrentLocationTrue() {
    isCurrentLocationSelected = true;
    notifyListeners();
  }

  void addMarkers(LatLng latLng) {
    markers!.add(Marker(
        markerId: const MarkerId('selected_location'), position: latLng));
  }

  void setAddress(String? newAddress) {
    address = newAddress;
    notifyListeners();
  }
}
