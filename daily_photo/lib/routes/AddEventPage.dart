import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventPage extends StatefulWidget {
  final DateTime selectedDay;

  const AddEventPage({super.key, required this.selectedDay});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late TextEditingController _eventController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _eventController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _eventController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventController,
              decoration: const InputDecoration(
                hintText: 'Enter event',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addEvent(widget.selectedDay);
              },
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }

  void addEvent(DateTime dateTime) {
    String event = _eventController.text.trim();
    String description = _descriptionController.text.trim();
    if (event.isNotEmpty && description.isNotEmpty) {
      String documentName = DateFormat('yyyyMMdd').format(dateTime);
      FirebaseFirestore.instance.collection('events').doc(documentName).set({
        'event': event,
        'description': description,
        'date': dateTime,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both event and description')),
      );
    }
  }
}
