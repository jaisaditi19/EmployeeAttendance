import 'package:hive/hive.dart';

part 'payment.g.dart';

@HiveType(typeId: 2)
class Payment extends HiveObject {
  @HiveField(0)
  final String employeeName;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  Payment({
    required this.employeeName,
    required this.amount,
    required this.date,
  });
}
