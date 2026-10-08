import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const baseUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'http://172.17.42.187:3000',
  );

  static Future<Map<String, dynamic>> summarize(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) throw Exception('The selected file could not be read.');

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/summarize'))
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
    final response = await request.send().timeout(const Duration(seconds: 90));
    final body = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['error'] ?? 'The AI backend could not process this file.');
    }
    return body;
  }
}