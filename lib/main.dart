import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/employee.dart';
import 'models/attendance.dart';
import 'models/payment.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Hive.initFlutter(); // or Hive.init() for non-Flutter
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(AttendanceAdapter());

  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Payment>('payments');
  await Hive.openBox<Attendance>('attendance');

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
