import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:daily_photo/models/FirebaseService.dart';

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
        ResolutionPreset
            .medium, // Set a lower resolution preset for faster initialization
      );
      _controller.setFlashMode(FlashMode.auto);

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
      appBar: AppBar(
        title: const Text('Camera'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) => Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_controller)),
                  Positioned(
                    bottom: 16.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _takePicture() async {
    try {
      // Ensure the controller is initialized
      await _initializeControllerFuture;

      // Capture the photo
      final XFile imageFile = await _controller.takePicture();

      // Get the current position asynchronously
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      // Get the current user's UID
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        print('No user logged in');
        return;
      }

      final String userId = user.uid;

      // Upload the taken photo to Firebase Storage
      final String imageUrl =
          await FirebaseService.uploadImageToFirebaseStorage(imageFile.path);

      // Upload the location, image URL, and userId to Firebase Firestore
      if (_currentPosition != null) {
        await FirebaseService.uploadImageToFirestore(
            userId, position, imageUrl, DateTime.now(), context);
      }
    } catch (e) {
      print(e);
    }
  }
}
