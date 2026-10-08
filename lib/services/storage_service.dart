import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoredStudyFile {
  final String id;
  final String name;
  final int size;
  final String uploadedOn;
  final String extension;
  final String bytesBase64;

  const StoredStudyFile({
    required this.id,
    required this.name,
    required this.size,
    required this.uploadedOn,
    required this.extension,
    required this.bytesBase64,
  });

  factory StoredStudyFile.fromJson(Map<String, dynamic> json) {
    return StoredStudyFile(
      id: json['id'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      uploadedOn: json['uploadedOn'] as String,
      extension: json['extension'] as String,
      bytesBase64: json['bytesBase64'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'uploadedOn': uploadedOn,
        'extension': extension,
        'bytesBase64': bytesBase64,
      };
}

class StorageService {
  static const _nameKey = 'user_name';
  static const _emailKey = 'user_email';
  static const _passwordKey = 'user_password';
  static const _departmentKey = 'user_department';
  static const _loggedInKey = 'is_logged_in';
  static const _filesKey = 'study_files';

  static Future<void> saveUser({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setString(_departmentKey, department);
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedEmail == email.trim() && savedPassword == password) {
      await prefs.setBool(_loggedInKey, true);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  static Future<String> getDepartment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_departmentKey) ?? '';
  }

  static Future<String> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  static Future<List<StoredStudyFile>> getFiles({
    required String department,
    required int semester,
    required String subject,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allFiles = prefs.getStringList(_filesKey) ?? [];
    return allFiles
        .map((value) => StoredStudyFile.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .where((file) => file.id.startsWith('$department|$semester|$subject|'))
        .toList()
      ..sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));
  }

  static Future<void> saveFile({
    required String department,
    required int semester,
    required String subject,
    required int unit,
    required String name,
    required int size,
    required List<int> bytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs.getStringList(_filesKey) ?? [];
    final now = DateTime.now().toIso8601String();
    final extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    final file = StoredStudyFile(
      id: '$department|$semester|$subject|$unit|$now',
      name: name,
      size: size,
      uploadedOn: now,
      extension: extension,
      bytesBase64: base64Encode(bytes),
    );
    files.add(jsonEncode(file.toJson()));
    await prefs.setStringList(_filesKey, files);
  }

  static Future<void> deleteFile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final files = prefs.getStringList(_filesKey) ?? [];
    files.removeWhere((value) => StoredStudyFile.fromJson(jsonDecode(value) as Map<String, dynamic>).id == id);
    await prefs.setStringList(_filesKey, files);
  }
}
