import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  String loggedUser = '';
  int currentTabIndex = 0;

  final List<Task> assignedTasks = [
    Task(id: '1', title: 'Manutenzione Impianto', location: 'Sede Centrale', type: 'Antincendio'),
  ];
  final List<Report> completedReports = [];

  void login(String username, String password) {
    isAuthenticated = true;
    loggedUser = username;
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    currentTabIndex = 0;
    loggedUser = '';
    notifyListeners();
  }

  void setTab(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  // --- CHIAMATA AL TUO FUTURO SERVER RENDER ---
  Future<String> callBackend(String prompt) async {
    final url = Uri.parse('/api/chat'); 

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'prompt': prompt});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? "Nessuna risposta.";
      } else {
        return "Errore Server Backend (${response.statusCode})";
      }
    } catch (e) {
      return "Errore di connessione al server: $e";
    }
  }

  void addGeneratedReport(String title, String content) {
    completedReports.insert(0, Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskTitle: title,
      date: 'Oggi',
      status: 'Generato',
      aiSummary: content,
    ));
    setTab(1); // Vai all'archivio
  }
}