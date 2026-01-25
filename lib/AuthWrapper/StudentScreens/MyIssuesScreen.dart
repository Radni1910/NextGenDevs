import 'package:dormtrack/AuthWrapper/StudentScreens/IssueDetailsScreen.dart';
import 'package:flutter/material.dart';

class MyIssuesScreen extends StatelessWidget {
  const MyIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reported Issues")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Dummy count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IssueDetailScreen())),
              leading: _statusIcon(index),
              title: Text("Leaking tap in Bathroom $index"),
              subtitle: const Text("Status: In Progress • Block B"),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  Widget _statusIcon(int index) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: index == 0 ? Colors.green.shade100 : Colors.blue.shade100, shape: BoxShape.circle),
      child: Icon(index == 0 ? Icons.check : Icons.sync, color: index == 0 ? Colors.green : Colors.blue, size: 20),
    );
  }
}