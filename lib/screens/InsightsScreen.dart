import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Insights")),
      body: paymentsAsync.when(
        data: (payments) {
          return attendanceAsync.when(
            data: (attendanceList) {
              return employeesAsync.when(
                data: (employees) {
                  final Map<String, Map<String, List<Payment>>> paymentsGrouped = {};
                  final Map<String, Map<String, List<Attendance>>> attendanceGrouped = {};

                  for (final payment in payments) {
                    final monthKey = DateFormat('yyyy-MM').format(payment.date);
                    paymentsGrouped.putIfAbsent(monthKey, () => {});
                    paymentsGrouped[monthKey]!.putIfAbsent(payment.employeeName, () => []);
                    paymentsGrouped[monthKey]![payment.employeeName]!.add(payment);
                  }

                  for (final att in attendanceList) {
                    final monthKey = DateFormat('yyyy-MM').format(att.date);
                    attendanceGrouped.putIfAbsent(monthKey, () => {});
                    attendanceGrouped[monthKey]!.putIfAbsent(att.employeeName, () => []);
                    attendanceGrouped[monthKey]![att.employeeName]!.add(att);
                  }

                  final allMonths = {
                    ...paymentsGrouped.keys,
                    ...attendanceGrouped.keys,
                  }.toList()
                    ..sort((a, b) => b.compareTo(a)); // Descending

                  return ListView.builder(
                    itemCount: allMonths.length,
                    itemBuilder: (context, index) {
                      final monthKey = allMonths[index];
                      final monthName = DateFormat('MMMM yyyy')
                          .format(DateTime.parse("$monthKey-01"));

                      // Collect all employee names involved in this month (from attendance or payment)
                      final employeeSet = <String>{};
                      employeeSet.addAll(paymentsGrouped[monthKey]?.keys ?? []);
                      employeeSet.addAll(attendanceGrouped[monthKey]?.keys ?? []);
                      final employeesInMonth = employeeSet.toList();

                      return Card(
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...employeesInMonth.map((employee) {
                                final empPayments = paymentsGrouped[monthKey]?[employee] ?? [];
                                final empAttendance = attendanceGrouped[monthKey]?[employee] ?? [];

                                final totalPay = empPayments.fold<double>(0.0, (sum, p) => sum + p.amount);
                                final firstDayOfMonth = DateTime.parse('$monthKey-01');

                                final allMonthAttendance = attendanceGrouped[monthKey]
                                        ?.values
                                        .expand((a) => a)
                                        .toList() ??
                                    [];

                                final lastRecordedDay = allMonthAttendance.isNotEmpty
                                    ? allMonthAttendance
                                        .map((e) => e.date)
                                        .reduce((a, b) => a.isAfter(b) ? a : b)
                                    : firstDayOfMonth;

                                final List<DateTime> monthDays = [];
                                for (DateTime d = firstDayOfMonth;
                                    !d.isAfter(lastRecordedDay);
                                    d = d.add(const Duration(days: 1))) {
                                  monthDays.add(DateTime(d.year, d.month, d.day));
                                }

                                final empAttendanceMap = {
                                  for (final att in empAttendance)
                                    DateTime(att.date.year, att.date.month, att.date.day): att.isPresent
                                };

                                int present = 0;
                                int absent = 0;

                                for (final day in monthDays) {
                                  if (empAttendanceMap.containsKey(day)) {
                                    if (empAttendanceMap[day]!) {
                                      present++;
                                    } else {
                                      absent++;
                                    }
                                  } else {
                                    absent++;
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      employee,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text("  • Total Payment: ₹${totalPay.toStringAsFixed(2)}"),
                                    Text("  • Present Days: $present"),
                                    Text("  • Leaves: $absent"),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Employee Error: $e")),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Attendance Error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Payment Error: $e")),
      ),
    );
  }
}
