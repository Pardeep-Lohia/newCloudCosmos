import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // For iOS simulator or web

Future<UploadResponse> uploadNotesWeb(String userId, Uint8List bytes, String fileName) async {
  var uri = Uri.parse('$baseUrl/upload_notes');
  var request = http.MultipartRequest('POST', uri)
    ..fields['user_id'] = userId
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));

  var response = await request.send();
  if (response.statusCode == 200) {
    var body = await response.stream.bytesToString();
    return UploadResponse.fromJson(jsonDecode(body));
  } else {
    throw Exception('Failed to upload: ${response.statusCode}');
  }
}


  Future<UploadResponse> uploadNotes(String userId, File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_notes'),
    );

    request.fields['user_id'] = userId;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    if (response.statusCode == 200) {
      return UploadResponse.fromJson(json.decode(responseString));
    } else {
      throw Exception('Failed to upload notes: ${response.statusCode}');
    }
  }

  Future<QueryResponse> askQuestion(String userId, String query) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'query': query,
      }),
    );

    if (response.statusCode == 200) {
      return QueryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get answer: ${response.statusCode}');
    }
  }



  Future<QuizResponse> generateQuiz(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate_quiz'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      return QuizResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to generate quiz: ${response.statusCode}');
    }
  }
}
