import 'package:flutter/material.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _overviewSection(),
            const SizedBox(height: 24),
            _sectionTitle("Issue Status"),
            const SizedBox(height: 12),
            _statusProgress(),
            const SizedBox(height: 24),
            _sectionTitle("Category Breakdown"),
            const SizedBox(height: 12),
            _categoryCards(),
            const SizedBox(height: 24),
            _sectionTitle("Recent Insights"),
            const SizedBox(height: 12),
            _recentInsights(),
          ],
        ),
      ),
    );
  }

  // 🔹 Overview Cards
  Widget _overviewSection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _overviewCard("Total Issues", "128", Icons.assignment, Colors.blue),
        _overviewCard("Resolved", "92", Icons.check_circle, Colors.green),
        _overviewCard("Pending", "36", Icons.pending, Colors.orange),
        _overviewCard("Lost & Found", "18", Icons.find_in_page, Colors.purple),
      ],
    );
  }

  Widget _overviewCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔹 Status Progress
  Widget _statusProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _progressTile("Resolved", 0.72, Colors.green),
          _progressTile("In Progress", 0.18, Colors.orange),
          _progressTile("Open", 0.10, Colors.red),
        ],
      ),
    );
  }

  Widget _progressTile(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Category Cards
  Widget _categoryCards() {
    final categories = [
      {'name': 'Electrical', 'count': 34, 'color': Colors.amber},
      {'name': 'Plumbing', 'count': 28, 'color': Colors.blue},
      {'name': 'Cleaning', 'count': 22, 'color': Colors.green},
      {'name': 'Others', 'count': 16, 'color': Colors.grey},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat['count'].toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cat['color'] as Color,
                ),
              ),
              const SizedBox(height: 6),
              Text(cat['name'].toString()),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Recent Insights
  Widget _recentInsights() {
    final insights = [
      "Most issues reported from Block B",
      "Electrical issues increased this week",
      "Average resolution time: 2.3 days",
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: insights
            .map(
              (text) => ListTile(
            leading: const Icon(Icons.insights, color: Colors.indigo),
            title: Text(text),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
