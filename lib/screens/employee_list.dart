import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';
import 'edit_employee_screen.dart';
class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Employees")),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(child: Text("No employees added."));
          }

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              return ListTile(
                title: Text(emp.name),
                subtitle: Text(
                  "Salary: ₹${emp.salary.toStringAsFixed(2)}\nJoined: ${emp.joiningDate.toLocal().toString().split(' ')[0]}",
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    final box = ref.read(employeeBoxProvider);

                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditEmployeeScreen(employee: emp, index: index),
                        ),
                      );
                    } else if (value == 'delete') {
                      await box.deleteAt(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted ${emp.name}')),
                      );
                      ref.invalidate(employeesProvider); // refresh the list
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Failed to load employees:\n$err")),
      ),
    );
  }
}