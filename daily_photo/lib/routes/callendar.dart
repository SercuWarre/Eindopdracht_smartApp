import 'package:daily_photo/models/details.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Center(
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(1990),
          lastDay: DateTime(2050),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekVisible: true,
          weekendDays: [DateTime.saturday, DateTime.sunday],
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true, // Remove the "2 weeks" text
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white, // Adjust color as needed
               // Center align the text
               
              
            ),
          ),
          // Add more calendar configurations here
          onDaySelected: (selectedDay, focusedDay) {
            // Navigate to details page for the selected day
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailsPage(selectedDay)),
            );
          },
        ),
      ),
    );
  }
}


