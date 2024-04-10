import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapPage extends StatefulWidget {
  @override
  _MapSamplePageState createState() => _MapSamplePageState();
}

class _MapSamplePageState extends State<MapPage> {
  GoogleMapController? mapController;
  final Map<MarkerId, Marker> markers = {}; // CLASS MEMBER, MAP OF MARKS

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addMarker(double lat, double lng, String markerLoc) {
    final markerId = MarkerId("$lat,$lng");
    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      onTap: () {
        // Here you can fetch and show users near this marker
 showDialog(
        context: context,
        builder: (BuildContext context) {
          // Here, we are using a simple dialog to show user info. You can customize it as needed.
          return AlertDialog(
            title: Text("Freinds near $markerLoc"),
            content: Text("Users close to this marker: [...]"), // Placeholder for user info
            actions: <Widget>[
              // Usually buttons at the bottom of the dialog
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  @override
  void initState() {
    super.initState();
    // Example: Add a marker
    _addMarker(28.5483, 77.1879, "Satpura");
    _addMarker(28.5476, 77.1831, "Shivalik"); // Add more markers as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(28.5448, 77.1888),
          zoom: 15.0,
        ),
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }
}
