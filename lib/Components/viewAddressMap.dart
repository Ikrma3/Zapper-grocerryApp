import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewAddressMapScreen extends StatelessWidget {
  final LatLng coordinates;
  final String address;

  ViewAddressMapScreen({required this.coordinates, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Address'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: coordinates,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('addressMarker'),
                position: coordinates,
                infoWindow: InfoWindow(
                  title: address,
                ),
              ),
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
