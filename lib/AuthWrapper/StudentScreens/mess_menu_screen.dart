import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class MessMenuScreen extends StatelessWidget {
  const MessMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String today = _getDayName(DateTime.now().weekday);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FE,
      ), // Ultra-light grey/blue background
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Stylized Modern App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "$today's Menu",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A237E),
                  fontSize: 22,
                ),
              ),
            ),
          ),

          // 2. Menu Content
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mess_menu')
                .doc(today.toLowerCase())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              var menu = snapshot.data!.data() as Map<String, dynamic>;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader("Morning Fuel"),
                    _menuCard(
                      context,
                      title: "Breakfast",
                      items: menu['breakfast'] ?? "No Menu Set",
                      color: const Color(0xFFFFE0B2), // Very soft orange
                      accentColor: const Color(0xFFFB8C00),
                      lottiePath: 'animations/breakfast.json',
                    ),
                    _buildSectionHeader("Mid-day Meal"),
                    _menuCard(
                      context,
                      title: "Lunch",
                      items: menu['lunch'] ?? "No Menu Set",
                      color: const Color(0xFFE3F2FD), // Very soft blue
                      accentColor: const Color(0xFF1E88E5),
                      lottiePath: 'animations/lunch.json',
                    ),
                    _buildSectionHeader("Night Cravings"),
                    _menuCard(
                      context,
                      title: "Dinner",
                      items: menu['dinner'] ?? "No Menu Set",
                      color: const Color(0xFFE8EAF6), // Very soft indigo
                      accentColor: const Color(0xFF3949AB),
                      lottiePath: 'animations/dinner.json',
                    ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Premium UI Components ---

  Widget _buildSectionHeader(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10, left: 4),
      child: Text(
        subtitle.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _menuCard(
      BuildContext context, {
        required String title,
        required String items,
        required Color color,
        required Color accentColor,
        required String lottiePath,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: () => _showMenuDetails(context, title, items, accentColor),
          child: SizedBox(
            height: 170,
            child: Stack(
              children: [
                // Text Content
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: accentColor.withOpacity(0.8),
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Tap to view",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Large Lottie Background Effect
                Positioned(
                  right: -20,
                  top: -10,
                  bottom: -10,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 200,
                      child: Lottie.asset(lottiePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// (Keep your _showMenuDetails, _submitRating, and _getDayName the same as before)
// Note: Just update the colors in _showMenuDetails to match the 'accentColor' passed in.
}
// --- Logic: Tap to View & Rate ---

void _showMenuDetails(
    BuildContext context,
    String title,
    String items,
    Color color,
    ) {
  int tempRating = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(35),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                items,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const Divider(height: 50, thickness: 1),

              // Star Rating
              const Text(
                "How was the meal today?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setModalState(() => tempRating = index + 1);
                    },
                    icon: Icon(
                      index < tempRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < tempRating
                          ? Colors.amber
                          : Colors.grey[400],
                      size: 45,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 25),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: tempRating == 0
                      ? null
                      : () async {
                    await _submitRating(title, tempRating);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thanks for your feedback!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Submit Feedback",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Using a subtle icon or you could even use a "no data" Lottie here
        Icon(
          Icons.restaurant_rounded,
          size: 100,
          color: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 20),
        Text(
          "No Menu Uploaded Yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Check back again in a little while.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        ),
      ],
    ),
  );
}

// --- Database Logic ---

Future<void> _submitRating(String mealType, int rating) async {
  final user = FirebaseAuth.instance.currentUser;
  final dateStr = DateTime.now().toIso8601String().split('T')[0];

  try {
    await FirebaseFirestore.instance.collection('ratings').add({
      'userId': user?.uid,
      'mealType': mealType,
      'rating': rating,
      'date': dateStr,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint("Rating Error: $e");
  }
}

String _getDayName(int day) {
  const days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];
  return days[day - 1];
}