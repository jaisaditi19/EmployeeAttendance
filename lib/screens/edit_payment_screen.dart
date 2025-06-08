import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../providers/data_provider.dart';

class EditPaymentScreen extends ConsumerStatefulWidget {
  final Payment payment;
  final int index;

  const EditPaymentScreen({super.key, required this.payment, required this.index});

  @override
  ConsumerState<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends ConsumerState<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.payment.employeeName);
    _amountController = TextEditingController(text: widget.payment.amount.toString());
    _date = widget.payment.date;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final updated = Payment(
        employeeName: _nameController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        date: _date,
      );

      final box = ref.read(paymentBoxProvider);
      await box.putAt(widget.index, updated);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment updated")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Employee Name"),
                validator: (value) => value == null || value.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) => value == null || value.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Text("Date: ${_date.toLocal().toString().split(' ')[0]}")),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                    child: const Text("Change Date"),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Update Payment")),
            ],
          ),
        ),
      ),
    );
  }
}