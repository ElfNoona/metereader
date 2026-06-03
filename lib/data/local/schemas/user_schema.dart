import 'package:isar/isar.dart';
import 'reading_schema.dart';

part 'user_schema.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String username;

  late String password;

  // Backlink to easily access all readings that belong to this user
  @Backlink(to: 'user')
  final readings = IsarLinks<MeterReading>();
}
