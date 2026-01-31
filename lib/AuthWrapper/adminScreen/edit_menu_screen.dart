import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart'; // ✅ Ensure this is imported

class EditMenuScreen extends StatefulWidget {
  const EditMenuScreen({super.key});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  String selectedDay = "Monday";
  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color backgroundGreen = const Color(0xFFF1F8E9);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGreen,
      // 🔥 Remove the appBar property entirely
      body: Column(
        children: [
          _buildHeader(context), // 🚀 Add the new custom header here
          _buildDaySelector(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mess_menu')
                  .doc(selectedDay.toLowerCase())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryGreen),
                  );
                }

                var menu = snapshot.data?.data() as Map<String, dynamic>? ?? {};

                // Inside your StreamBuilder's builder:
                return ListView(
                  // Use physics to make it feel smooth on iOS/Android
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    100,
                  ), // Extra bottom padding for the Navbar
                  children: [
                    _editDualMealTile(
                      "Breakfast",
                      menu['breakfast_veg'] ?? "",
                      menu['breakfast_nonveg'] ?? "",
                      const Color(0xFF2E7D32),
                      'animations/breakfast.json',
                      isHero: true,
                    ),
                    const SizedBox(height: 12),
                    _editDualMealTile(
                      "Lunch",
                      menu['lunch_veg'] ?? "",
                      menu['lunch_nonveg'] ?? "",
                      const Color(0xFF388E3C),
                      'animations/lunch.json',
                    ),
                    const SizedBox(height: 12),
                    _editDualMealTile(
                      "Dinner",
                      menu['dinner_veg'] ?? "",
                      menu['dinner_nonveg'] ?? "",
                      const Color(0xFF1B5E20),
                      'animations/dinner.json',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D2310), // Ultra dark green
            Color(0xFF1B5E20), // Forest green
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mess Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Update daily food menu",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const Opacity(
            opacity: 0.2,
            child: Icon(Icons.restaurant_menu, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  // ================= DUAL MEAL TILE WITH LOTTIE =================
  // ================= DUAL MEAL TILE WITH LARGER LOTTIE =================
  // ================= REARRANGED DUAL MEAL TILE =================
  Widget _editDualMealTile(
      String meal,
      String vegItems,
      String nonVegItems,
      Color color,
      String lottiePath, {
        bool isHero = false,
      }) {
    return GestureDetector(
      onTap: () => _showDualEditDialog(meal, vegItems, nonVegItems),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: isHero ? 210 : 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color
                  .withBlue(color.blue + 20)
                  .withGreen(color.green + 10), // Subtle gradient
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. Background Visual Decoration (Large faint icon)
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: Lottie.asset(lottiePath, width: 200),
              ),
            ),

            // 2. Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // LEFT SIDE: TEXT CONTENT
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal Label with Icon
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meal.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Split Veg/Non-Veg Layout
                        Row(
                          children: [
                            // Vertical Green/Red Bars
                            Column(
                              children: [
                                _statusIndicator(Colors.greenAccent),
                                const SizedBox(height: 12),
                                _statusIndicator(Colors.redAccent),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Items List
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _menuText(vegItems, "Veg Option"),
                                  const SizedBox(height: 12),
                                  _menuText(nonVegItems, "Non-Veg Option"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // RIGHT SIDE: LARGE ANIMATION
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Transform.scale(
                        scale: 1.4, // 🚀 Making it really pop
                        child: Lottie.asset(lottiePath, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _statusIndicator(Color color) {
    return Container(
      width: 4,
      height: 35,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _menuText(String items, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          items.isEmpty ? placeholder : items,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: items.isEmpty ? Colors.white38 : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // (Remaining helper widgets: _menuRow, _showDualEditDialog, _buildDaySelector stay the same as previous)

  Widget _menuRow(
      IconData icon,
      Color iconColor,
      String label,
      String items,
      bool isHero,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Icon(icon, color: iconColor, size: 10),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                items.isEmpty ? "Not set" : items,
                maxLines: isHero ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDualEditDialog(
      String meal,
      String currentVeg,
      String currentNonVeg,
      ) {
    final vegController = TextEditingController(text: currentVeg);
    final nonVegController = TextEditingController(text: currentNonVeg);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Update $meal Menu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField("Veg Menu", vegController, Colors.green),
              const SizedBox(height: 20),
              _dialogField("Non-Veg Menu", nonVegController, Colors.red),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('mess_menu')
                  .doc(selectedDay.toLowerCase())
                  .set({
                '${meal.toLowerCase()}_veg': vegController.text.trim(),
                '${meal.toLowerCase()}_nonveg': nonVegController.text
                    .trim(),
              }, SetOptions(merge: true));
              if (mounted) Navigator.pop(context);
            },
            child: const Text(
              "Update All",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
      String label,
      TextEditingController controller,
      Color color,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundGreen,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          bool isSelected = selectedDay == days[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(days[index]),
              selected: isSelected,
              onSelected: (val) {
                setState(() => selectedDay = days[index]);
              },
              // 🔥 COLORS UPDATED HERE
              selectedColor: primaryGreen, // The bubble background
              backgroundColor: backgroundGreen, // The unselected background
              showCheckmark: true, // Set to true if you want the 'tick' icon
              checkmarkColor: Colors.white, // ✅ Makes the 'check' white
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected
                    ? Colors.white
                    : primaryGreen, // ✅ Makes text white when selected
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryGreen : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
