import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  static Future<Map<String, dynamic>?> getImageInfoFromFirestore(
      String selectedDay) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('images')
          .doc(selectedDay)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> imageData = {
          'imageUrl':
              (documentSnapshot.data() as Map<String, dynamic>)['imageUrl'],
          'latitude':
              (documentSnapshot.data() as Map<String, dynamic>)['latitude'],
          'longitude':
              (documentSnapshot.data() as Map<String, dynamic>)['longitude'],
        };
        return imageData;
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving image info from Firestore: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getEventFromFirestore(
      String selectedDay) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(selectedDay)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> eventData = {
          'event': (documentSnapshot.data() as Map<String, dynamic>)['event'],
          'description':
              (documentSnapshot.data() as Map<String, dynamic>)['description'],
          'date': (documentSnapshot.data() as Map<String, dynamic>)['date'],
        };
        return eventData;
      } else {
        return null;
      }
    } catch (e) {
      print("Error retrieving event info from Firestore: $e");
      return null;
    }
  }


static Future<void> uploadImageToFirestore(Position position, String imageUrl,
      DateTime dateTime, BuildContext context) async {
    try {
      // Convert DateTime to a formatted string (e.g., 'yyyyMMddHHmmss')
      String documentName = DateFormat('yyyyMMdd').format(dateTime);

      await FirebaseFirestore.instance
          .collection('images')
          .doc(documentName)
          .set({
        'imageUrl': imageUrl,
        'latitude': position.latitude,
        'longitude': position.longitude,
        // Add other fields as needed
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('image added successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add image: $error')),
        );
      });
    } catch (e) {
      print("Error uploading image to Firestore: $e");
    }
  }

  static Future<String> uploadImageToFirebaseStorage(String imagePath) async {
    try {
      Reference ref =
          FirebaseStorage.instance.ref().child('images/${DateTime.now()}.png');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }
}
