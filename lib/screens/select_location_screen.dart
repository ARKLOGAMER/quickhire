import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late GoogleMapController mapController;
  LatLng selectedLocation = LatLng(8.8282, 76.7139); // Default to Parippally

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng position) async {
    setState(() {
      selectedLocation = position;
    });

    // Convert coordinates to address
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      print("Selected Address: ${placemarks.first.locality}, ${placemarks.first.administrativeArea}");
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, selectedLocation); // Return location to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Job Location")),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId("selected-location"),
            position: selectedLocation,
          ),
        },
        onTap: _onTap, // Allow pin selection
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmLocation,
        child: Icon(Icons.check),
      ),
    );
  }
}
