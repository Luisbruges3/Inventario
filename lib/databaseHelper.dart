import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'inventario.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS productos');
        await _onCreate(db, newVersion);
      },
    );
  }
  

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        referencia TEXT,
        precio REAL,
        descripcion TEXT,
        categoria TEXT
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    Database db = await instance.db;
    return await db.insert('productos', user.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.db;
    return await db.query('productos');
  }

  Future<int> updateUser(User user) async {
    Database db = await instance.db;
    return await db.update('productos', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.db;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> initializeUsers() async {
    final existing = await queryAllUsers();
    if (existing.isNotEmpty) return;

    List<User> usersToAdd = [
      User(nombre: 'Luis', referencia: '001', precio: 10600, descripcion: 'Tomate', categoria: 'Alimentos'),
      User(nombre: 'Alfredo', referencia: '025', precio: 250700, descripcion: 'Mueble de sala', categoria: 'Hogar'),
      User(nombre: 'Alicia', referencia: '883', precio: 87200, descripcion: 'Pc Gamer', categoria: 'Tecnologia'),
      User(nombre: 'Jorge', referencia: '027', precio: 24800, descripcion: 'Jeanes', categoria: 'Ropa'),
    ];

    for (User user in usersToAdd) {
      await insertUser(user);
    }
  }
}