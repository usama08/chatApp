import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng currentLocation = const LatLng(
      37.7749, -122.4194); // Replace with your default/current location
  LatLng targetLocation =
      const LatLng(34.6849, -132.4074); // Replace with your target location

  @override
  void initState() {
    super.initState();
    location.onLocationChanged.listen((LocationData currentLocationData) {
      setState(() {
        currentLocation = LatLng(
            currentLocationData.latitude!, currentLocationData.longitude!);
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _goToCurrentLocation() async {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Demo'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 15.0,
            ),
            markers: <Marker>{
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: currentLocation,
                icon: BitmapDescriptor.defaultMarker,
                infoWindow: const InfoWindow(title: 'Current Location'),
              ),
              Marker(
                markerId: const MarkerId('targetLocation'),
                position: targetLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
                infoWindow: const InfoWindow(title: 'Target Location'),
              ),
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _goToCurrentLocation,
              child: const Text('Go to Current Location'),
            ),
          ),
        ],
      ),
    );
  }
}
