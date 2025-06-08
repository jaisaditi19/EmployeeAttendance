import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final Employee employee;
  final int index;

  const EditEmployeeScreen({Key? key, required this.employee, required this.index})
      : super(key: key);

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _salaryController;
  late DateTime _joiningDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.employee.name);
    _salaryController = TextEditingController(text: widget.employee.salary.toString());
    _joiningDate = widget.employee.joiningDate;
    super.initState();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final salary = double.tryParse(_salaryController.text) ?? 0.0;

      final updatedEmployee = Employee(
        name: name,
        salary: salary,
        joiningDate: _joiningDate,
      );

      final box = ref.read(employeeBoxProvider);
      await box.putAt(widget.index, updatedEmployee);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${updatedEmployee.name}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                decoration: const InputDecoration(labelText: "Salary"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? "Enter salary" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text("Joining Date: ${_joiningDate.toLocal().toString().split(' ')[0]}"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _joiningDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _joiningDate = picked;
                        });
                      }
                    },
                    child: const Text("Change Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Update Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
