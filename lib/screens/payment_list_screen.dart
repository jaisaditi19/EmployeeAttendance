import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../providers/data_provider.dart';
import 'edit_payment_screen.dart';

class PaymentListScreen extends ConsumerWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Payments")),
      body: paymentsAsync.when(
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text("No payments found."));
          }

          // Group payments by employee name
          final Map<String, List<Payment>> grouped = {};
          for (final p in payments) {
            grouped.putIfAbsent(p.employeeName, () => []).add(p);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key),
                children: entry.value.map((payment) {
                  final index = ref
                      .read(paymentBoxProvider)
                      .values
                      .toList()
                      .indexOf(payment);

                  return ListTile(
                    title: Text("₹${payment.amount.toStringAsFixed(2)}"),
                    subtitle: Text("Date: ${payment.date.toLocal().toString().split(' ')[0]}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPaymentScreen(
                                payment: payment,
                                index: index,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          final box = ref.read(paymentBoxProvider);
                          await box.deleteAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Payment deleted")),
                          );
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text("Edit")),
                        PopupMenuItem(value: 'delete', child: Text("Delete")),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}