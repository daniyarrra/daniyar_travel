import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import '../utils/postgres_config.dart';

class PostgresService {
  Connection? _connection;

  Future<void> connect() async {
    if(_connection != null && _connection!.isOpen) return;

    try {
      _connection = await Connection.open(
        Endpoint(
          host: PostgresConfig.host,
          database: PostgresConfig.database,
          username: PostgresConfig.username,
          password: PostgresConfig.password,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      debugPrint('Connected to PostgreSQL database: ${PostgresConfig.database}');
    } catch (e) {
      debugPrint('Error connecting to PostgreSQL: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();

      // Предполагаем, что есть таблица users
      final result = await _connection!.execute(
        Sql.named('SELECT * FROM users WHERE email = @email AND password = @password'),
        parameters: {'email': email, 'password': password},
      );

      if (result.isNotEmpty) {
        final row = result.first;
        // Преобразуем строку в Map. В реальном проекте лучше использовать модель
        return row.toColumnMap();
      }
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();

      await _connection!.execute(
        Sql.named('INSERT INTO users (email, password) VALUES (@email, @password)'),
        parameters: {'email': email, 'password': password},
      );
      debugPrint('User registered in PostgreSQL (donk)!');
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  // --- PLACES METHODS ---

  Future<List<Map<String, dynamic>>> getPlaces() async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();
      final result = await _connection!.execute('SELECT * FROM places ORDER BY created_at DESC');
      final places = <Map<String, dynamic>>[];
      for (final row in result) {
        places.add(row.toColumnMap());
      }
      return places;
    } catch (e) {
      debugPrint('Error fetching places: $e');
      return [];
    }
  }

  Future<void> addPlace(String title, String description, String imageUrl, String category) async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();
      await _connection!.execute(
        Sql.named('INSERT INTO places (title, description, image_url, category) VALUES (@title, @description, @imageUrl, @category)'),
        parameters: {
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'category': category,
        },
      );
    } catch (e) {
      debugPrint('Error adding place: $e');
      rethrow;
    }
  }

  Future<void> updatePlace(int id, String title, String description, String imageUrl, String category) async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();
      await _connection!.execute(
        Sql.named('UPDATE places SET title = @title, description = @description, image_url = @imageUrl, category = @category WHERE id = @id'),
        parameters: {
          'id': id,
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'category': category,
        },
      );
    } catch (e) {
      debugPrint('Error updating place: $e');
      rethrow;
    }
  }

  Future<void> deletePlace(int id) async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();
      await _connection!.execute(
        Sql.named('DELETE FROM places WHERE id = @id'),
        parameters: {'id': id},
      );
    } catch (e) {
      debugPrint('Error deleting place: $e');
      rethrow;
    }
  }

  // --- ADMIN METHODS ---

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      if (_connection == null || !_connection!.isOpen) await connect();
      final result = await _connection!.execute('SELECT id, email, created_at FROM users ORDER BY created_at DESC');
      final users = <Map<String, dynamic>>[];
      for (final row in result) {
        users.add(row.toColumnMap());
      }
      return users;
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  Future<void> close() async {
    await _connection?.close();
  }
}
