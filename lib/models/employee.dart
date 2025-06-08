import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double salary;

  @HiveField(2)
  final DateTime joiningDate;

  Employee({
    required this.name,
    required this.salary,
    required this.joiningDate,
  });
}