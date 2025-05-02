import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'select_location_screen.dart';


class PostJobScreen extends StatefulWidget {
  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', company = '', salary = '', description = '', location = '', type = '';
  double latitude = 0.0, longitude = 0.0;
  bool isFetchingLocation = false;

loc.Location _location = loc.Location();


  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation(); // Fetch user's location on screen load
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      isFetchingLocation = true;
    });

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => isFetchingLocation = false);
        return;
      }
    }

    // Check and request location permissions
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() => isFetchingLocation = false);
        return;
      }
    }

    // Get current location
    loc.LocationData currentLocation = await _location.getLocation();
    setState(() {
      latitude = currentLocation.latitude!;
      longitude = currentLocation.longitude!;
      isFetchingLocation = false;
    });

    // Convert coordinates to address (Reverse Geocoding)
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        location = "${placemarks.first.locality}, ${placemarks.first.administrativeArea}";
      });
    }
  }

  void _selectLocation() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationScreen()),
    );

    if (pickedLocation != null) {
      setState(() {
        latitude = pickedLocation.latitude;
        longitude = pickedLocation.longitude;
      });

      // Convert new coordinates to address
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          location = "${placemarks.first.locality}, ${placemarks.first.administrativeArea}";
        });
      }
    }
  }

  void postJob() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': title,
        'company': company,
        'salary': salary,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Go back after posting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post a Job")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Title'),
                onChanged: (val) => title = val,
                validator: (val) => val!.isEmpty ? 'Enter Job Title' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Company Name'),
                onChanged: (val) => company = val,
                validator: (val) => val!.isEmpty ? 'Enter Company Name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Type'),
                onChanged: (val) => type = val,
                validator: (val) => val!.isEmpty ? 'Enter Type' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Salary (Optional)'),
                onChanged: (val) => salary = val,
              ),
              TextFormField(
                controller: TextEditingController(text: location),
                decoration: InputDecoration(
                  labelText: 'Location',
                  suffixIcon: isFetchingLocation
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: Icon(Icons.map),
                          onPressed: _selectLocation, // Open map picker
                        ),
                ),
                onChanged: (val) => location = val,
                validator: (val) => val!.isEmpty ? 'Enter location' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (val) => description = val,
                validator: (val) => val!.isEmpty ? 'Enter Job Description' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: postJob,
                child: Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
