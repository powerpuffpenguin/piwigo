import 'dart:async';

import 'package:sqflite/sqflite.dart';

_exception(String func) => Exception('Helper function not override: $func');

abstract class Helper<T> {
  Helper(this.db);
  final Database db;

  String get tableName => throw _exception('get tableName');
  T fromMap(Map<String, dynamic> map) => throw _exception('fromMap');
  Map<String, dynamic> toMap(T data, {bool insert = false}) =>
      throw _exception('toMap');
}

mixin HasId {
  String get byId => 'id';
}
mixin HasName {
  String get byName => 'name';
}

/// 爲 helper 提供一些通用的 方法
mixin Executor<T> on Helper<T> {
  /// 查詢數據
  Future<List<T>> query({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final result = <T>[];
    final list = await db.query(
      tableName,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      limit: limit,
      offset: offset,
    );
    for (var m in list) {
      result.add(fromMap(m));
    }
    return result;
  }

  /// 查詢第一條數據
  Future<T?> first({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final list = await db.query(
      tableName,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      limit: 1,
    );
    return list.isEmpty ? null : fromMap(list.first);
  }

  /// 添加一條記錄
  Future<int> add(T data,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    return db.insert(
      tableName,
      toMap(data, insert: true),
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// 添加多條記錄
  FutureOr<List<int>> addAll(Iterable<T> iterable,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    if (iterable.isNotEmpty) {
      return <int>[];
    }

    return db.transaction((txn) async {
      final result = <int>[];
      for (var data in iterable) {
        result.add(await txn.insert(
          tableName,
          toMap(data, insert: true),
          nullColumnHack: nullColumnHack,
          conflictAlgorithm: conflictAlgorithm,
        ));
      }
      return result;
    });
  }

  /// 刪除記錄
  Future<int> delete({String? where, List<Object?>? whereArgs}) => db.delete(
        tableName,
        where: where,
        whereArgs: whereArgs,
      );

  /// 修改記錄
  Future<int> update(
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) =>
      db.update(
        tableName,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm,
      );
}

/// 提供 xxxById 函數
mixin ById<T, TypeID> on Helper<T>, HasId {
  /// 返回 id 爲指定值的數據
  Future<T?> getById(
    TypeID id, {
    bool? distinct,
    List<String>? columns,
    String? groupBy,
    String? having,
    String? orderBy,
    int? offset,
  }) async {
    final list = await db.query(
      tableName,
      distinct: distinct,
      columns: columns,
      where: '$byId = ?',
      whereArgs: [id],
      groupBy: groupBy,
      having: having,
      limit: 1,
    );
    return list.isEmpty ? null : fromMap(list.first);
  }

  /// 刪除 id 爲指定值的 數據
  Future<int> deleteById(TypeID id) => db.delete(
        tableName,
        where: '$byId = ?',
        whereArgs: [id],
      );

  /// 更新 id 爲指定值的 數據
  Future<int> updateById(
    TypeID id,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) =>
      db.update(
        tableName,
        values,
        where: '$byId = ?',
        whereArgs: [id],
        conflictAlgorithm: conflictAlgorithm,
      );
}

/// 提供 xxxByName 函數
mixin ByName<T, TypeName> on Helper<T>, HasName {
  /// 返回 name 爲指定值的數據
  Future<T?> getByName(
    TypeName name, {
    bool? distinct,
    List<String>? columns,
    String? groupBy,
    String? having,
    String? orderBy,
    int? offset,
  }) async {
    final list = await db.query(
      tableName,
      distinct: distinct,
      columns: columns,
      where: '$byName = ?',
      whereArgs: [name],
      groupBy: groupBy,
      having: having,
      limit: 1,
    );
    return list.isEmpty ? null : fromMap(list.first);
  }

  /// 刪除 name 爲指定值的 數據
  Future<int> deleteByName(TypeName name) => db.delete(
        tableName,
        where: '$byName = ?',
        whereArgs: [name],
      );

  /// 更新 name 爲指定值的 數據
  Future<int> updateByName(
    TypeName name,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) =>
      db.update(
        tableName,
        values,
        where: '$byName = ?',
        whereArgs: [name],
        conflictAlgorithm: conflictAlgorithm,
      );
}
