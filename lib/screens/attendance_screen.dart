import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final attendanceBox = ref.read(attendanceBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, _) {
              setState(() => _selectedDate = selectedDay);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) {
                  return const Center(child: Text("No employees found."));
                }
                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final existing = attendanceBox.values.firstWhere(
                      (att) => att.employeeName == employee.name && isSameDay(att.date, _selectedDate),
                      orElse: () => Attendance(
                        employeeName: employee.name,
                        date: _selectedDate,
                        isPresent: false,
                      ),
                    );
                    bool isMarked = attendanceBox.values.any(
                      (att) => att.employeeName == employee.name && isSameDay(att.date, _selectedDate),
                    );

                    return SwitchListTile(
                      title: Text(employee.name),
                      subtitle: Text(isMarked ? "Marked" : "Not marked"),
                      value: existing.isPresent,
                      onChanged: (value) async {
                        final existingIndex = attendanceBox.values.toList().indexWhere(
                          (att) => att.employeeName == employee.name && isSameDay(att.date, _selectedDate),
                        );

                        final newRecord = Attendance(
                          employeeName: employee.name,
                          date: _selectedDate,
                          isPresent: value,
                        );

                        if (existingIndex != -1) {
                          final key = attendanceBox.keyAt(existingIndex);
                          await attendanceBox.put(key, newRecord);
                        } else {
                          await attendanceBox.add(newRecord);
                        }
                        setState(() {}); // Refresh UI
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
