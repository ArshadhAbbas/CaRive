import 'package:carive/shared/circular_progress_indicator.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSelectionScreen extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;
  const LocationSelectionScreen({Key? key, this.onLocationSelected})
      : super(key: key);

  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String address = "Choose Location";
  late GoogleMapController googleMapController;
  Set<Marker> markers = {}; // Set to hold the selected marker
  LatLng? selectedLatLng; // Variable to store the selected LatLng
  bool isCurrentLocationSelected = false;
  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(10.850516, 76.271080), zoom: 8);

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  void onMapTap(LatLng latLng) {
    getAddress(latLng);
    setState(() {
      markers = {}; // Clear existing markers
      selectedLatLng = latLng; // Set selected LatLng
      isCurrentLocationSelected = false;
      markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: latLng,
        ),
      );
    });
  }

  Future<LatLng> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(position.latitude, position.longitude);
  }

  void onCurrentLocationIconPressed() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CustomProgressIndicator(),
        ),
      );


      LatLng currentLocation = await getCurrentLocation();
      Navigator.of(context).pop();

      getAddress(currentLocation);

      setState(() {
        markers = {}; // Clear existing markers
        selectedLatLng =
            currentLocation; // Set selected LatLng to current location
        markers.add(
          Marker(
            markerId: MarkerId('selected_location'),
            position: currentLocation,
          ),
        );
        isCurrentLocationSelected = true;
      });

      // Animate the camera to the current location
      googleMapController.animateCamera(
        CameraUpdate.newLatLngZoom(
            currentLocation, 15), // Adjust the zoom level as needed
      );
    } else if (permissionStatus.isDenied ||
        permissionStatus.isPermanentlyDenied) {
      // Handle permission denied or permanently denied
      showPermissionAlertDialog('Permission Denied',
          'Location permission has been denied by the user.');
    } else if (permissionStatus.isRestricted) {
      // Handle permission restricted
      showPermissionAlertDialog(
          'Permission Restricted', 'Location permission is restricted.');
    }
  }

  getAddress(LatLng latLong) async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(latLong.latitude, latLong.longitude);
    setState(() {
      address = placemark[0].subLocality! +
          " " +
          placemark[0].locality! +
          " " +
          placemark[0].country!;
    });
  }

  void onCheckIconPressed() {
    if (selectedLatLng != null) {
      LatLng selectedLocation = selectedLatLng!;

      // Call the onLocationSelected callback with the selected location
      widget.onLocationSelected?.call(selectedLocation);
    }
  }

  void showPermissionAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColorGrey,
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            content,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColorGrey,
        actions: [
          TextButton(
              onPressed: onCheckIconPressed,
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: onMapCreated,
            onTap: onMapTap,
            markers: markers,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.topCenter,
                child: CustomElevatedButton(
                  text: address,
                  onPressed: () {},
                  paddingHorizontal: 3,
                  paddingVertical: 3,
                )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeColorGrey,
        foregroundColor: Colors.white,
        child: Icon(Icons.my_location),
        onPressed: onCurrentLocationIconPressed,
        heroTag: 'current_location',
        tooltip: "Current Location",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
