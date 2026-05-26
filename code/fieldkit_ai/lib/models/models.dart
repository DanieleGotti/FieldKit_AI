class Task {
  final String id;
  final String title;
  final String location;
  final String type;

  Task({required this.id, required this.title, required this.location, required this.type});
}

class Report {
  final String id;
  final String taskTitle;
  final String date;
  final String status;
  final String aiSummary; 

  Report({
    required this.id, 
    required this.taskTitle, 
    required this.date, 
    required this.status, 
    required this.aiSummary
  });
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}