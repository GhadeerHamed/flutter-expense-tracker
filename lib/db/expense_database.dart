import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/currency.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT,
        amount REAL,
        date TEXT,
        currency_code TEXT DEFAULT 'RON'
      )
    ''');

    await db.execute('''
      CREATE TABLE currencies (
        code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await _seedDefaultCurrencies(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE expenses_new (
          id TEXT PRIMARY KEY,
          title TEXT,
          amount REAL,
          date TEXT,
          currency_code TEXT DEFAULT 'RON'
        )
      ''');

      await db.execute('''
        INSERT INTO expenses_new (id, title, amount, date, currency_code)
        SELECT id, title, amount, date, 'RON'
        FROM expenses
      ''');

      await db.execute('DROP TABLE expenses');
      await db.execute('ALTER TABLE expenses_new RENAME TO expenses');
    }

    if (oldVersion < 3) {
      final columns = await db.rawQuery('PRAGMA table_info(expenses)');
      final hasCurrencyCode = columns.any(
        (column) => column['name'] == 'currency_code',
      );

      if (!hasCurrencyCode) {
        await db.execute(
          "ALTER TABLE expenses ADD COLUMN currency_code TEXT DEFAULT 'RON'",
        );
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS currencies (
          code TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          symbol TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await _seedDefaultCurrencies(db);
    }
  }

  Future<void> _seedDefaultCurrencies(Database db) async {
    for (final currency in CurrencyCatalog.supported) {
      await db.insert(
        'currencies',
        currency.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> fetchExpenses() async {
    final db = await instance.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<Expense>> fetchExpensesPage({
    required int limit,
    required int offset,
  }) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<List<CurrencyDef>> fetchActiveCurrencies() async {
    final db = await instance.database;
    final maps = await db.query(
      'currencies',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'code ASC',
    );

    return maps.map((map) => CurrencyDef.fromMap(map)).toList();
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
