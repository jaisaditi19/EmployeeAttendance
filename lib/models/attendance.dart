import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class Attendance extends HiveObject {
  @HiveField(0)
  final String employeeName;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final bool isPresent;

  Attendance({
    required this.employeeName,
    required this.date,
    required this.isPresent,
  });
}
