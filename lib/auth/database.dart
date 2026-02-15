import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kasir.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kategori (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE menu (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            harga INTEGER NOT NULL,
            gambar TEXT,
            kategori_id INTEGER,
            FOREIGN KEY (kategori_id) REFERENCES kategori(id) ON DELETE SET NULL
          );
        ''');
        await db.execute('''
          CREATE TABLE pin (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pin TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');

        // PIN dimasukkan di onCreate karena ini data krusial pertama kali
        await db.insert('pin', {
          'pin': '123456',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      },
      // KITA TAMBAHKAN onOpen UNTUK SEEDING KATEGORI
      onOpen: (db) async {
        await _seedData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE pin (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              pin TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            );
          ''');
          await db.insert('pin', {
            'pin': '123456',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      },
    );
  }

  // FUNGSI SEED DATA TERPISAH
  static Future<void> _seedData(Database db) async {
    // Cek apakah tabel kategori kosong
    final List<Map<String, dynamic>> kategori = await db.query('kategori');

    if (kategori.isEmpty) {
      // print("Seeding data kategori...");
      Batch batch = db.batch();
      batch.insert('kategori', {'nama': 'Makanan'});
      batch.insert('kategori', {'nama': 'Minuman'});
      await batch.commit(noResult: true);
    } else {
      // print("Data kategori sudah ada, skip seeding.");
    }
  }

  // KATEGORI
  static Future<int> insertKategori(String nama) async {
    final db = await database;
    return await db.insert('kategori', {'nama': nama});
  }

  static Future<List<Map<String, dynamic>>> getKategori() async {
    final db = await database;
    return await db.query('kategori', orderBy: 'nama');
  }

  static Future<int> updateKategori(int id, String nama) async {
    final db = await database;
    return await db.update(
      'kategori',
      {'nama': nama},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteKategori(int id) async {
    final db = await database;
    await db.delete('kategori', where: 'id = ?', whereArgs: [id]);
  }

  // MENU
  static Future<int> insertMenu({
    required String nama,
    required int harga,
    String? gambar,
    required int kategoriId,
  }) async {
    final db = await database;
    return await db.insert('menu', {
      'nama': nama,
      'harga': harga,
      'gambar': gambar,
      'kategori_id': kategoriId,
    });
  }

  static Future<List<Map<String, dynamic>>> getMenu() async {
    final db = await database;
    return await db.rawQuery('''
			SELECT menu.*, kategori.nama AS kategori_nama
			FROM menu
			LEFT JOIN kategori ON menu.kategori_id = kategori.id
			ORDER BY menu.nama
		''');
  }

  static Future<int> updateMenu({
    required int id,
    required String nama,
    required int harga,
    String? gambar,
    required int kategoriId,
  }) async {
    final db = await database;
    return await db.update(
      'menu',
      {
        'nama': nama,
        'harga': harga,
        'gambar': gambar,
        'kategori_id': kategoriId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteMenu(int id) async {
    final db = await database;
    final result = await db.query('menu', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final gambarPath = result[0]['gambar'] as String?;
      if (gambarPath != null && gambarPath.isNotEmpty) {
        await _deleteImageFile(gambarPath);
      }
    }
    await db.delete('menu', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> _deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // PIN
  static Future<String?> getCurrentPin() async {
    final db = await database;
    final result = await db.query('pin', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return result.first['pin'] as String;
    }
    return null;
  }

  static Future<bool> validatePin(String inputPin) async {
    final currentPin = await getCurrentPin();
    return currentPin == inputPin;
  }

  static Future<int> updatePin(String oldPin, String newPin) async {
    final db = await database;

    // Validate old PIN first
    final isValidOldPin = await validatePin(oldPin);
    if (!isValidOldPin) {
      throw Exception('PIN lama tidak sesuai');
    }

    return await db.update('pin', {
      'pin': newPin,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = (SELECT MAX(id) FROM pin)');
  }

  static Future<int> insertNewPin(String newPin) async {
    final db = await database;
    return await db.insert('pin', {
      'pin': newPin,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
