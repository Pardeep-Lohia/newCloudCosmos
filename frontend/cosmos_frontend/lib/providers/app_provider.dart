import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';

class AppProvider with ChangeNotifier {
  List<String> _uploadedFiles = [];
  List<ChatMessage> _chatHistory = [];
  final String _userId = 'user123'; // Default user ID, can be made dynamic later

  List<String> get uploadedFiles => _uploadedFiles;
  List<ChatMessage> get chatHistory => _chatHistory;
  String get userId => _userId;

  AppProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _uploadedFiles = prefs.getStringList('uploadedFiles') ?? [];
    final chatHistoryJson = prefs.getStringList('chatHistory') ?? [];
    _chatHistory = chatHistoryJson
        .map((json) => ChatMessage.fromJson(Map<String, dynamic>.from(
            jsonDecode(json) as Map)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('uploadedFiles', _uploadedFiles);
    final chatHistoryJson = _chatHistory
        .map((message) => jsonEncode(message.toJson()))
        .toList();
    await prefs.setStringList('chatHistory', chatHistoryJson);
  }

  void addFile(String fileName) {
    if (!_uploadedFiles.contains(fileName)) {
      _uploadedFiles.add(fileName);
      _saveData();
      notifyListeners();
    }
  }

  void removeFile(String fileName) {
    _uploadedFiles.remove(fileName);
    _saveData();
    notifyListeners();
  }

  void addChatMessage(ChatMessage message) {
    _chatHistory.add(message);
    _saveData();
    notifyListeners();
  }

  void clearChatHistory() {
    _chatHistory.clear();
    _saveData();
    notifyListeners();
  }
}
