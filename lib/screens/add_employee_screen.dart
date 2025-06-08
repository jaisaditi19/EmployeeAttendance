import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  DateTime? _joiningDate;

  void _submit() async {
    if (_formKey.currentState!.validate() && _joiningDate != null) {
      final name = _nameController.text;
      final salary = double.tryParse(_salaryController.text) ?? 0.0;
      final employee = Employee(name: name, salary: salary, joiningDate: _joiningDate!);

      final box = ref.read(employeeBoxProvider);
      await box.add(employee);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Employee added")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value == null || value.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Salary"),
                validator: (value) => value == null || value.isEmpty ? "Enter salary" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(_joiningDate == null
                        ? "Pick joining date"
                        : "Joining Date: ${_joiningDate!.toLocal()}".split(" ")[0]),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _joiningDate = picked;
                        });
                      }
                    },
                    child: const Text("Select Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Add Employee")),
            ],
          ),
        ),
      ),
    );
  }
}
