import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_photo/routes/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DetailsPage extends StatefulWidget {
  final DateTime selectedDay;

  DetailsPage(this.selectedDay);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late String _imagePath = '';
  late double _latitude = 0.0;
  late double _longitude = 0.0;
  late String _city = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getImageInfo();
  }

  Future<void> _getImageInfo() async {
    try {
      String formattedDate = DateFormat('yyyyMMdd').format(widget.selectedDay);
      Map<String, dynamic>? imageData =
          await getImageInfoFromFirestore(formattedDate);
      if (imageData != null) {
        setState(() {
          _imagePath = imageData['imageUrl'];
          _latitude = imageData['latitude'];
          _longitude = imageData['longitude'];
        });
        await _getCityName();
      }
    } catch (e) {
      print("Error getting image info: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCityName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude,
        _longitude,
      );
      setState(() {
        _city = placemarks.first.locality ?? 'Unknown';
      });
    } catch (e) {
      print('Error getting city name: $e');
      setState(() {
        _city = 'Unknown';
      });
    }
  }

  bool isCurrentDay(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ' ${DateFormat('dd-MM-yyyy').format(widget.selectedDay)}',
                  ),
                  const SizedBox(height: 20),
                  _imagePath != null && _imagePath.isNotEmpty
                      ? Column(
                          children: [
                            Image.network(_imagePath),
                            const SizedBox(height: 10),
                            Text('City: $_city'),
                          ],
                        )
                      : const Text('No image available'),
                  const SizedBox(height: 20),
                  if (isCurrentDay(widget.selectedDay))
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the camera page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CameraPage()),
                        );
                      },
                      child: const Text('Go to Camera Page'),
                    ),
                ],
              ),
            ),
    );
  }
}

Future<Map<String, dynamic>?> getImageInfoFromFirestore(
    String selectedDay) async {
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('images')
        .doc(selectedDay)
        .get();

    if (documentSnapshot.exists) {
      // If a document with the specified ID exists, retrieve its data
      Map<String, dynamic> imageData = {
        'imageUrl':
            (documentSnapshot.data() as Map<String, dynamic>)['imageUrl'],
        'latitude':
            (documentSnapshot.data() as Map<String, dynamic>)['latitude'],
        'longitude':
            (documentSnapshot.data() as Map<String, dynamic>)['longitude'],
        // Add other fields as needed
      };
      return imageData;
    } else {
      // If no document matches the specified ID, return null
      return null;
    }
  } catch (e) {
    print("Error retrieving image info from Firestore: $e");
    return null;
  }
}
