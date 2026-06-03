import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'schemas/user_schema.dart';
import 'schemas/reading_schema.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  /// 1. Initialize Isar Database
  Future<Isar> openDB() async {
    // If Isar is already open, return the instance
    if (Isar.instanceNames.isEmpty) {
      // Find a safe path on the local device (iOS/Android) to store the DB files
      final dir = await getApplicationDocumentsDirectory();
      
      return await Isar.open(
        [UserSchema, MeterReadingSchema], // Pass the generated schemas here
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// 2. USER METHODS (For Auth Validator)
  
  // Check if username is already taken during signup
  Future<bool> checkUserExists(String username) async {
    final isar = await db;
    final count = await isar.users.filter().usernameEqualTo(username).count();
    return count > 0;
  }

  // Save a new user to the database
  Future<void> createUser(String username, String password) async {
    final isar = await db;
    
    final newUser = User()
      ..username = username
      ..password = password; // Note: In production, hash this password!

    await isar.writeTxn(() async {
      await isar.users.put(newUser); // Save user to DB
    });
  }

  // Get a user for login verification
  Future<User?> getUserByUsername(String username) async {
    final isar = await db;
    return await isar.users.filter().usernameEqualTo(username).findFirst();
  }

  /// 3. METER READING LOGIC
  
  // Save a cleaned reading and link it to the specific user
  Future<void> saveMeterReading(String username, double numericReading) async {
    final isar = await db;
    
    // Retrieve the user to associate this reading with
    final user = await getUserByUsername(username);
    if (user == null) {
      throw Exception("User '$username' not found! Cannot save reading.");
    }

    // Create the new reading object
    final newReading = MeterReading()
      ..readingValue = numericReading
      ..timestamp = DateTime.now();

    // Database writes must happen inside a transaction
    await isar.writeTxn(() async {
      // 1. Put the reading in the DB to generate its ID
      await isar.meterReadings.put(newReading);
      
      // 2. Link it to the user and save the link
      newReading.user.value = user;
      await newReading.user.save();
    });
  }

  // Fetch the reading history for the dashboard
  Future<List<MeterReading>> getReadingsForUser(String username) async {
    final user = await getUserByUsername(username);
    if (user == null) return [];

    // Load the linked readings for this specific user
    await user.readings.load();
    
    // Return them sorted by latest first
    List<MeterReading> history = user.readings.toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return history;
  }
}
