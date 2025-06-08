import 'package:employee_attendance_payment_app/screens/payment_list_screen.dart';
import 'package:flutter/material.dart';
import 'InsightsScreen.dart';
import 'add_employee_screen.dart';
import 'attendance_screen.dart';
import 'employee_list.dart';
import 'payment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Management")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text("Add Employee"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text("Mark Attendance"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_money),
                label: const Text("Record Payment"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
  child: const Text("View Employees"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
    );
  },
),
const SizedBox(height: 5),
              ElevatedButton(
  child: const Text("View Payments"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaymentListScreen()),
    );
  },
),
const SizedBox(height: 5),
ElevatedButton(
  child: const Text("View Insights"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InsightsScreen()),
    );
  },
),
            ],
          ),
        ),
      ),
    );
  }
}
