import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:daily_photo/routes/camera.dart';
import 'package:daily_photo/routes/AddEventPage.dart';
import 'package:daily_photo/models/FirebaseService.dart';

class DetailsPage extends StatefulWidget {
  final DateTime selectedDay;

  const DetailsPage(this.selectedDay, {super.key});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late String _imagePath = '';
  late double _latitude = 0.0;
  late double _longitude = 0.0;
  late String _city = '';
  bool _isLoading = true;
  late String _event = '';
  late String _description = '';

  @override
  void initState() {
    super.initState();
    _getImageInfo();
    _getEventInfo();
  }

  Future<void> _getImageInfo() async {
    try {
      String formattedDate = DateFormat('yyyyMMdd').format(widget.selectedDay);
      Map<String, dynamic>? imageData =
          await FirebaseService.getImageInfoFromFirestore(formattedDate);
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

  Future<void> _getEventInfo() async {
    try {
      String formattedDate = DateFormat('yyyyMMdd').format(widget.selectedDay);
      Map<String, dynamic>? eventData =
          await FirebaseService.getEventFromFirestore(formattedDate);
      if (eventData != null) {
        setState(() {
          _event = eventData['event'];
          _description = eventData['description'];
        });
      }
    } catch (e) {
      print("Error getting event info: $e");
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
      appBar: AppBar(
        title: const Text(
          'Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' ${DateFormat('dd-MM-yyyy').format(widget.selectedDay)}',
                    ),
                    const SizedBox(height: 20),
                    if (_imagePath.isNotEmpty)
                      Column(children: [
                        Image.network(_imagePath),
                        const SizedBox(height: 10),
                        Text('City: $_city'),
                        const SizedBox(height: 20),
                      ]),
                    if (_event.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Event:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(_event),
                          const SizedBox(height: 10),
                          Text(_description),
                          const SizedBox(height: 10),
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (isCurrentDay(widget.selectedDay))
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  CameraPage()),
                           ).then((value) {
                            _getImageInfo();
                            _getEventInfo();
                          });
                        },
                        child: const Text('Go to Camera Page'),
                      ),
                    if (_event.isEmpty)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddEventPage(
                                    selectedDay: widget.selectedDay)),
                          ).then((value) {
                            _getImageInfo();
                            _getEventInfo();
                          });
                        },
                        child: const Text('Add Event'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
