import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  String selectedFilter = 'All';

  final List<String> staffList = [
    'Ravi (Plumbing)',
    'Sunil (Electrical)',
    'Housekeeping Team',
    'Internet Support',
  ];

  final List<Map<String, dynamic>> assignments = [
    {
      'title': 'Water Leakage',
      'category': 'Plumbing',
      'location': 'Block A - Room 203',
      'priority': 'High',
      'status': 'Unassigned',
      'assignedTo': null,
    },
    {
      'title': 'Fan not working',
      'category': 'Electrical',
      'location': 'Block B - Room 101',
      'priority': 'Medium',
      'status': 'Assigned',
      'assignedTo': 'Sunil (Electrical)',
    },
    {
      'title': 'Room cleaning required',
      'category': 'Cleaning',
      'location': 'Block C - Room 305',
      'priority': 'Low',
      'status': 'Completed',
      'assignedTo': 'Housekeeping Team',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = assignments.where((a) {
      return selectedFilter == 'All' || a['status'] == selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Issue Assignment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummary(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _buildAssignmentCard(filtered[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔢 Summary cards
  Widget _buildSummary() {
    int unassigned =
        assignments.where((a) => a['status'] == 'Unassigned').length;
    int assigned =
        assignments.where((a) => a['status'] == 'Assigned').length;
    int completed =
        assignments.where((a) => a['status'] == 'Completed').length;

    return Row(
      children: [
        _summaryTile('Total', assignments.length, Colors.blue),
        _summaryTile('Unassigned', unassigned, Colors.red),
        _summaryTile('Assigned', assigned, Colors.orange),
        _summaryTile('Done', completed, Colors.green),
      ],
    );
  }

  Widget _summaryTile(String title, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 🏷 Filters
  Widget _buildFilters() {
    final filters = ['All', 'Unassigned', 'Assigned', 'Completed'];

    return Row(
      children: filters.map((filter) {
        final selected = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() => selectedFilter = filter);
            },
          ),
        );
      }).toList(),
    );
  }

  // 📋 Assignment Card
  Widget _buildAssignmentCard(Map<String, dynamic> issue) {
    Color priorityColor = issue['priority'] == 'High'
        ? Colors.red
        : issue['priority'] == 'Medium'
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Chip(
                  label: Text(issue['priority']),
                  backgroundColor: priorityColor.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(issue['location'],
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text('Category: ${issue['category']}'),
            const SizedBox(height: 6),
            Text(
              issue['assignedTo'] == null
                  ? 'Not Assigned'
                  : 'Assigned to: ${issue['assignedTo']}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: issue['assignedTo'] == null
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _openAssignSheet(issue),
                child: Text(
                  issue['assignedTo'] == null ? 'Assign' : 'Reassign',
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🧾 Assign Bottom Sheet
  void _openAssignSheet(Map<String, dynamic> issue) {
    String? selectedStaff;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assign Issue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: staffList
                    .map((staff) => DropdownMenuItem(
                  value: staff,
                  child: Text(staff),
                ))
                    .toList(),
                onChanged: (value) {
                  selectedStaff = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Select Staff',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      issue['assignedTo'] = selectedStaff;
                      issue['status'] = 'Assigned';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm Assignment'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
