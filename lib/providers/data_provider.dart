import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/employee.dart';
import '../models/payment.dart';
import '../models/attendance.dart';

// Providers for Hive boxes
final employeeBoxProvider = Provider<Box<Employee>>((ref) {
  return Hive.box<Employee>('employees');
});

final paymentBoxProvider = Provider<Box<Payment>>((ref) {
  return Hive.box<Payment>('payments');
});

final attendanceBoxProvider = Provider<Box<Attendance>>((ref) {
  return Hive.box<Attendance>('attendance');
});

// Stream providers for watching data changes
final employeesProvider = StreamProvider<List<Employee>>((ref) async* {
  final box = ref.watch(employeeBoxProvider);
  yield box.values.toList();
  yield* box.watch().map((_) => box.values.toList());
});

final paymentsProvider = StreamProvider<List<Payment>>((ref) async* {
  final box = ref.watch(paymentBoxProvider);
  yield box.values.toList();
  yield* box.watch().map((_) => box.values.toList());
});

final attendanceProvider = StreamProvider<List<Attendance>>((ref) async* {
  final box = ref.watch(attendanceBoxProvider);
  yield box.values.toList();
  yield* box.watch().map((_) => box.values.toList());
});
