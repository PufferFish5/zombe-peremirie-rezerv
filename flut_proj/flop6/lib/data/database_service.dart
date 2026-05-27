import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/drink.dart';
import 'models/post.dart';
import 'models/order.dart';
import 'models/user_profile.dart';

class DatabaseService {
  DatabaseService._();
  static Database? _db;

//INIT
  static Future<void> initialize() async {
    if (_db != null) return;
    final dbFolder = await getDatabasesPath();
    final dbPath = join(dbFolder, 'db.sqlite3');
    final fileExists = await File(dbPath).exists();
    if (!fileExists) {
      await _copyDbFromAssets(dbPath);
    }

    _db = await openDatabase(
      dbPath,
      version: 1,
      //onCreate: _createTables,
    );
  }

  static Future<void> _copyDbFromAssets(String targetPath) async {
    final ByteData data = await rootBundle.load('assets/db/omega_energy.db');
    final bytes = data.buffer.asUint8List();
    await File(targetPath).writeAsBytes(bytes, flush: true);
  }

 
  // static Future<void> _createTables(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS products (
  //       id            INTEGER PRIMARY KEY AUTOINCREMENT,
  //       name          VARCHAR(50)  NOT NULL UNIQUE,
  //       series        VARCHAR(50)  NOT NULL,
  //       flavor_profile VARCHAR(255) NOT NULL,
  //       description   TEXT         NOT NULL,
  //       category      VARCHAR(50)  NOT NULL,
  //       price         FLOAT        NOT NULL,
  //       image_path    TEXT         DEFAULT ''
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS posts (
  //       id          INTEGER PRIMARY KEY AUTOINCREMENT,
  //       title       TEXT NOT NULL,
  //       body        TEXT NOT NULL DEFAULT '',
  //       type        TEXT NOT NULL DEFAULT 'news',
  //       image_url   TEXT DEFAULT '',
  //       event_date  TEXT DEFAULT NULL,
  //       created_at  TEXT NOT NULL DEFAULT (datetime('now'))
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS users (
  //       id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  //       name                TEXT    NOT NULL,
  //       email               TEXT    NOT NULL DEFAULT '',
  //       phone               INTEGER NOT NULL DEFAULT 0,
  //       created_at          TEXT    NOT NULL DEFAULT (datetime('now')),
  //       google_id           TEXT    DEFAULT '',
  //       is_google_connected INTEGER DEFAULT 0
  //     )
  //   ''');

  //   await db.execute('''
  //     CREATE TABLE IF NOT EXISTS orders (
  //       id          INTEGER PRIMARY KEY AUTOINCREMENT,
  //       user_id     INTEGER NOT NULL,
  //       product_id  INTEGER NOT NULL,
  //       quantity    INTEGER NOT NULL DEFAULT 1,
  //       status      TEXT    NOT NULL DEFAULT 'pending',
  //       created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  //       FOREIGN KEY (user_id)    REFERENCES users(id),
  //       FOREIGN KEY (product_id) REFERENCES products(id)
  //     )
  //   ''');
  // }


  static Database get _database {
    if (_db == null) throw StateError('DatabaseService is not initialized.');
    return _db!;
  }

// ─────────────────────────────────────────────────────────────DRINK
  static Future<List<Drink>> getDrinks() async {
    final rows = await _database.query(
      'drinks',
      orderBy: 'series, name',
    );
    return rows.map(Drink.fromMap).toList();
  }


  static Future<List<Drink>> getDrinksBySeries(String series) async {
    final rows = await _database.query(
      'drinks',
      where: 'series = ?',
      whereArgs: [series],
      orderBy: 'name',
    );
    return rows.map(Drink.fromMap).toList();
  }

  static Future<List<String>> getSeries() async {
    final rows = await _database.rawQuery(
      'SELECT DISTINCT series FROM drinks ORDER BY series',
    );
    return rows.map((r) => r['series'] as String).toList();
  }

  static Future<Drink?> getDrinkById(int id) async {
    final rows = await _database.query(
      'drinks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Drink.fromMap(rows.first);
  }

// ─────────────────────────────────────────────────────────────POST
  static Future<List<Post>> getPosts() async {
    final rows = await _database.query(
      'posts',
      orderBy: 'created_at DESC',
    );
    return rows.map(Post.fromMap).toList();
  }


  static Future<List<Post>> getEvents() async {
    final rows = await _database.query(
      'posts',
      where: 'type = ?',
      whereArgs: ['event'],
      orderBy: 'event_date ASC',
    );
    return rows.map(Post.fromMap).toList();
  }

  static Future<List<Post>> getPostsByType(String type) async {
    final rows = await _database.query(
      'posts',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );
    return rows.map(Post.fromMap).toList();
  }

// ─────────────────────────────────────────────────────────────PROFILE
  static Future<UserProfile?> getProfile() async {
    final rows = await _database.query('users', limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final existing = await getProfile();

    if (existing == null) {
      await _database.insert('users', profile.toMap());
    } else {
      await _database.update(
        'users',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }

  static Future<void> saveGoogleProfile({
    required String googleId,
    required String name,
    required String email,
  }) async {
    final existing = await getProfile();

    final data = {
      'google_id': googleId,
      'name': name,
      'email': email,
      'is_google_connected': 1,
    };

    if (existing == null) {
      await _database.insert('users', data);
    } else {
      await _database.update(
        'users',
        data,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }


  static Future<void> disconnectGoogle() async {
    final existing = await getProfile();
    if (existing == null) return;

    await _database.update(
      'users',
      {'google_id': '', 'is_google_connected': 0},
      where: 'id = ?',
      whereArgs: [existing.id],
    );
  }


// ─────────────────────────────────────────────────────────────ORDER
  static Future<List<Order>> getOrders() async {
    final profile = await getProfile();
    if (profile == null) return [];

    final rows = await _database.rawQuery('''
      SELECT 
        o.id,
        o.user_id,
        o.drink_id,
        o.quantity,
        o.status,
        o.created_at,
        p.name        AS drink_name,
        p.series      AS drink_series,
        p.price       AS drink_price,
        p.image_path  AS drink_image
      FROM orders o
      JOIN drinks p ON o.drink_id = p.id
      WHERE o.user_id = ?
      ORDER BY o.created_at DESC
    ''', [profile.id]);

    return rows.map(Order.fromMap).toList();
  }

  static Future<int> saveOrder({
    required int drinkId,
    required int quantity,
  }) async {
    final profile = await getProfile();

    int userId;
    if (profile == null) {
      userId = await _database.insert('users', {
        'name': 'Гість',
        'email': '',
        'phone': 0,
      });
    } else {
      userId = profile.id!;
    }

    return _database.insert('orders', {
      'user_id':    userId,
      'drink_id': drinkId,
      'quantity':   quantity,
      'status':     'pending',
    });
  }

  static Future<void> updateOrderStatus(int orderId, String status) async {
    await _database.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}