class UploadResponse {
  final String message;
  final int chunksCount;

  UploadResponse({required this.message, required this.chunksCount});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      message: json['message'],
      chunksCount: json['chunks_count'],
    );
  }
}

class QueryResponse {
  final String answer;
  final String? context;

  QueryResponse({required this.answer, this.context});

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    return QueryResponse(
      answer: json['answer'],
      context: json['context'],
    );
  }
}

class QuizResponse {
  final String quiz;

  QuizResponse({required this.quiz});

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      quiz: json['quiz'],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
