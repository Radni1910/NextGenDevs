import 'package:flutter/material.dart';
class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String selectedCategory = 'Plumbing';
  String selectedPriority = 'Medium';
  bool isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report New Issue")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What is the problem?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Category Dropdown
            _buildLabel("Category"),
            DropdownButtonFormField(
              value: selectedCategory,
              items: ['Plumbing', 'Electrical', 'WiFi', 'Cleanliness', 'Furniture'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedCategory = val!),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 20),

            // Priority Selection
            _buildLabel("Priority Level"),
            Row(
              children: ['Low', 'Medium', 'High', 'Urgent'].map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(p, style: const TextStyle(fontSize: 11)),
                    selected: selectedPriority == p,
                    onSelected: (val) => setState(() => selectedPriority = p),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // Description
            _buildLabel("Description"),
            TextField(
              maxLines: 4,
              decoration: _inputDecoration().copyWith(hintText: "Explain the issue in detail..."),
            ),
            const SizedBox(height: 20),

            // Visibility Toggle
            SwitchListTile(
              title: const Text("Make this issue public"),
              subtitle: const Text("Other students can see and upvote this."),
              value: isPublic,
              onChanged: (val) => setState(() => isPublic = val),
            ),
            
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                onPressed: () { /* Submit Logic */ },
                child: const Text("Submit Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true, fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}