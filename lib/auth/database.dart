import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 1,
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
        // Insert dummy data kategori
        await db.insert('kategori', {'nama': 'Makanan'});
        await db.insert('kategori', {'nama': 'Minuman'});
        // Insert dummy data menu
        await db.insert('menu', {
          'nama': 'Nasi Goreng',
          'harga': 20000,
          'gambar': null,
          'kategori_id': 1
        });
        await db.insert('menu', {
          'nama': 'Es Teh',
          'harga': 5000,
          'gambar': null,
          'kategori_id': 2
        });
      },
    );
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
}
