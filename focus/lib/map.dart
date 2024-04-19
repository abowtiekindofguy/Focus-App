import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile-card.dart'; // Import the profile card widget

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


    void _showBottomSheet(BuildContext context, Map<String, String> dataMap, String locationName) {
    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      context: context,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: dataMap.keys.length,
          itemBuilder: (_, index) {
            String key = dataMap.keys.elementAt(index);
            return ProfileCard(userID: dataMap[key]??"Friend",height: MediaQuery.of(context).size.height / 10,
                      width: 0.4 * MediaQuery.of(context).size.width, onPressed: () => ());
          },
        ),
      ),
    );
  }
    final markerId = MarkerId("$lat,$lng");
    final usersInHostel = FirebaseFirestore.instance.collection('users').where('location', isEqualTo: markerLoc).get();
    final Map<String,String> emailList = {}; 
    usersInHostel.then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
      final email = doc['email'];
      final name = doc['name'];
      emailList[name] = email;
      });
    }).catchError((error) {
      // Handle error
    });
    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: markerLoc),
      onTap: () {
        _showBottomSheet(context, emailList, markerLoc);
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }
  
  List<Map<String,List<double>>> hostelData = [
    {
      "Satpura": [28.5483, 77.1879]
    },
    {
      "Shivalik": [28.5476, 77.1831]
    }
  ];

  @override
  void initState() {
    super.initState();
    // Example: Add a marker
    for (var hostel in hostelData) {
      var key = hostel.keys.first;
      var value = hostel.values.first;
      _addMarker(value[0], value[1], key);
    }
    // _addMarker(28.5483, 77.1879, "Satpura");
    // _addMarker(28.5476, 77.1831, "Shivalik"); // Add more markers as needed
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
