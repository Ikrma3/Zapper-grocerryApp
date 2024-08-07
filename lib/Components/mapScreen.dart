import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zapper/Components/colours.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final Function(String, LatLng) onLocationSelected;

  MapScreen({required this.initialPosition, required this.onLocationSelected});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition;
  late LatLng _selectedPosition;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _selectedPosition = widget.initialPosition;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_currentPosition),
    );
  }

  void _onTap(LatLng position) async {
    setState(() {
      _selectedPosition = position;
    });

    // Convert the selected position to an address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark placemark = placemarks.first;

    String address =
        '${placemark.name}, ${placemark.locality}, ${placemark.country}';
    widget.onLocationSelected(address, _selectedPosition);
  }

  Future<void> _searchAddress(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng position =
            LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.animateCamera(CameraUpdate.newLatLng(position));
        setState(() {
          _selectedPosition = position;
        });

        // Optionally, you can fetch the address as well
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        Placemark placemark = placemarks.first;
        String address =
            '${placemark.name}, ${placemark.locality}, ${placemark.country}';
        widget.onLocationSelected(address, _selectedPosition);
      }
    } catch (e) {
      print('Error during search: $e');
    }
  }

  void _saveLocation() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _searchAddress(_searchController.text),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onTap,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('selectedPosition'),
                position: _selectedPosition,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 80,
            child: Container(
              width: 60.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  minimumSize: Size(40.w, 35.h),
                ),
                onPressed: _saveLocation,
                child: Text(
                  'Save Location',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
