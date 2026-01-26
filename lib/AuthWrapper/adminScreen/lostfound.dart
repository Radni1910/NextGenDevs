import 'package:flutter/material.dart';

class AdminLostFoundScreen extends StatefulWidget {
  const AdminLostFoundScreen({super.key});

  @override
  State<AdminLostFoundScreen> createState() => _AdminLostFoundScreenState();
}

class _AdminLostFoundScreenState extends State<AdminLostFoundScreen> {
  String selectedFilter = "All";
  String searchText = "";

  final List<Map<String, String>> lostFoundItems = [
    {
      "item": "Black Wallet",
      "location": "Block A - Room 203",
      "date": "12 Sept 2025",
      "status": "Lost",
    },
    {
      "item": "Water Bottle",
      "location": "Mess Hall",
      "date": "11 Sept 2025",
      "status": "Found",
    },
    {
      "item": "Calculator",
      "location": "Study Room",
      "date": "10 Sept 2025",
      "status": "Claimed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = lostFoundItems.where((item) {
      final matchesStatus =
          selectedFilter == "All" || item["status"] == selectedFilter;
      final matchesSearch =
      item["item"]!.toLowerCase().contains(searchText.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9),
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _header(),
          _summaryRow(),
          _searchBar(),
          _filterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _itemCard(filteredList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🌊 HEADER
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "Lost & Found",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 SUMMARY
  Widget _summaryRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryBox("Lost", Colors.red),
          _summaryBox("Found", Colors.green),
          _summaryBox("Claimed", const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _summaryBox(String status, Color color) {
    final count =
        lostFoundItems.where((e) => e["status"] == status).length;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 SEARCH
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (value) => setState(() => searchText = value),
        decoration: InputDecoration(
          hintText: "Search items...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🏷 FILTERS
  Widget _filterChips() {
    final filters = ["All", "Lost", "Found", "Claimed"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: const Color(0xFF38BDF8),
                onSelected: (_) =>
                    setState(() => selectedFilter = filter),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 📦 ITEM CARD
  Widget _itemCard(Map<String, String> item) {
    final statusColor = _statusColor(item["status"]!);

    return GestureDetector(
      onTap: () => _showDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.inventory_2, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["item"]!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(item["location"]!,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Chip(
              label: Text(item["status"]!),
              backgroundColor: statusColor.withOpacity(0.15),
              labelStyle: TextStyle(color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧾 DETAILS
  void _showDetails(Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item["item"]!,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("📍 ${item["location"]}"),
            Text("📅 ${item["date"]}"),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(item["status"]!),
                  backgroundColor:
                  _statusColor(item["status"]!).withOpacity(0.15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Lost":
        return Colors.red;
      case "Found":
        return Colors.green;
      case "Claimed":
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }
}
