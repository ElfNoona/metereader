import 'package:isar/isar.dart';
import 'user_schema.dart';

part 'reading_schema.g.dart';

@collection
class MeterReading {
  Id id = Isar.autoIncrement;

  // The final, cleaned, and verified numeric reading
  late double readingValue; 

  // When the reading was taken
  late DateTime timestamp;

  // Link to the specific user who took this reading
  final user = IsarLink<User>();
}
