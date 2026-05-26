import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => provider.logout()),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            width: double.infinity,
            child: Text('Bentornato, ${provider.loggedUser}\nAbilitazione valida', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.success)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Incarichi in sospeso', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.assignedTasks.length,
              itemBuilder: (context, index) {
                final task = provider.assignedTasks[index];
                return Card(
                  color: AppTheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.mediaButtonBg, child: Icon(Icons.build, color: AppTheme.primary)),
                    title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${task.location}\nSettore: ${task.type}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textLight),
                    onTap: () => context.read<AppProvider>().setTab(1), // Vai alla tab Ispezione
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}