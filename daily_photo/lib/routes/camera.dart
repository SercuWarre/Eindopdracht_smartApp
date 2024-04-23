import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import package for date formatting

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final selectedCamera = cameras.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Retry after 3 seconds if initialization fails
      Timer(const Duration(seconds: 3), () {
        _initializeCamera();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            // Take a photo
            XFile imageFile = await _controller.takePicture();
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);
            // Upload the taken photo to Firebase Storage
            String imageUrl =
                await uploadImageToFirebaseStorage(imageFile.path);
            // Upload the location to Firebase Firestore
            if (_currentPosition != null) {
              await uploadLocationToFirestore(
                  position, imageUrl, DateTime.now(), context);
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

Future<void> uploadLocationToFirestore(Position position, String imageUrl,
    DateTime dateTime, BuildContext context) async {
  try {
    // Convert DateTime to a formatted string (e.g., 'yyyyMMddHHmmss')
    String documentName = DateFormat('yyyyMMdd').format(dateTime);

    await FirebaseFirestore.instance.collection('images').doc(documentName).set({
      'imageUrl': imageUrl,
      'latitude': position.latitude,
      'longitude': position.longitude,
      // Add other fields as needed
    });

    // Pop the camera page off the stack
    Navigator.pop(context);
  } catch (e) {
    print("Error uploading: $e");
  }
}

// Do the same for the image
Future<String> uploadImageToFirebaseStorage(String imagePath) async {
  try {
    Reference ref = FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
    await ref.putFile(File(imagePath));
    return await ref.getDownloadURL();
  } catch (e) {
    print("Error uploading image: $e");
    return '';
  }
}
