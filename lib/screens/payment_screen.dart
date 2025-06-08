import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../models/employee.dart';
import '../providers/data_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeName;
  double? _amount;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final paymentBox = ref.read(paymentBoxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Record Payment")),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return const Center(child: Text("No employees available."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Select Employee"),
                    items: employees
                        .map((emp) => DropdownMenuItem<String>(
                              value: emp.name,
                              child: Text(emp.name),
                            ))
                        .toList(),
                    value: _selectedEmployeeName,
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployeeName = value;
                      });
                    },
                    validator: (value) => value == null ? "Please select an employee" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? "Enter amount" : null,
                    onSaved: (value) {
                      _amount = double.tryParse(value ?? "0");
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedDate == null
                            ? "Select date"
                            : "Date: ${_selectedDate!.toLocal()}".split(" ")[0]),
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
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: const Text("Choose Date"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedDate != null) {
                        _formKey.currentState!.save();
                        final payment = Payment(
                          employeeName: _selectedEmployeeName!,
                          amount: _amount!,
                          date: _selectedDate!,
                        );
                        paymentBox.add(payment);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Payment recorded")),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Payment"),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
