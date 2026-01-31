import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminLostFoundScreen extends StatefulWidget {
  const AdminLostFoundScreen({super.key});

  @override
  State<AdminLostFoundScreen> createState() => _AdminLostFoundScreenState();
}

class _AdminLostFoundScreenState extends State<AdminLostFoundScreen> {
  // 🎨 Premium Admin Palette
  static const Color primaryDark = Color(0xFF0D2310);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color bgLeaf = Color(0xFFF1F8E9);
  static const Color borderGreen = Color(0xFFC8E6C9);

  // 🔍 Filters
  String selectedFilter = "All";
  String searchText = "";

  // ✍️ Controllers
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  // 🧾 State Management
  String selectedStatus = "lost";
  DateTime selectedDate = DateTime.now();
  File? selectedImage;
  bool isUploadingImage = false;

  final Stream<QuerySnapshot> lostFoundStream = FirebaseFirestore.instance
      .collection('lost_found_items')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  // ===========================
  // IMAGE PICK & UPLOAD
  // ===========================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName = "lost_found/${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putFile(image);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      body: Column(
        children: [
          _premiumHeader(context),
          _summaryRow(),
          _filterChips(),
          Expanded(child: _itemsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDark,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Add Item",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _showAddItemSheet,
      ),
    );
  }

  // ===========================
  // HEADER (With Back Arrow)
  // ===========================
  Widget _premiumHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, forestGreen],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
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
                child: Text(
                  "Lost & Found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance the back button
            ],
          ),
          const SizedBox(height: 20),
          _searchBar(),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          onChanged: (v) => setState(() => searchText = v),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search items...",
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white70),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // ===========================
  // SUMMARY COUNTS
  // ===========================
  Widget _summaryRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: lostFoundStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        final lost = docs.where((e) => e['status'] == 'lost').length;
        final found = docs.where((e) => e['status'] == 'found').length;
        final claimed = docs.where((e) => e['status'] == 'claimed').length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Row(
            children: [
              _countBox("Lost", lost, Colors.redAccent),
              _countBox("Found", found, Colors.orange),
              _countBox("Claimed", claimed, forestGreen),
            ],
          ),
        );
      },
    );
  }

  Widget _countBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGreen),
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
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips() {
    final filters = ["All", "lost", "found", "claimed"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: filters.map((f) {
          final selected = selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              // 🎨 This changes the check mark color to white
              checkmarkColor: Colors.white,

              // ✅ Ensures the check mark is visible when selected
              showCheckmark: true,

              label: Text(
                f.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white : primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: selected,
              selectedColor: forestGreen, // The dark green background
              backgroundColor: Colors.white,
              onSelected: (_) => setState(() => selectedFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===========================
  // ITEMS LIST & ORIGINAL CARD
  // ===========================
  Widget _itemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: lostFoundStream,
      builder: (_, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final statusOk =
              selectedFilter == "All" || d['status'] == selectedFilter;
          final searchOk = d['description'].toString().toLowerCase().contains(
            searchText.toLowerCase(),
          );
          return statusOk && searchOk;
        }).toList();

        if (filteredDocs.isEmpty)
          return const Center(child: Text("No items found"));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: filteredDocs.length,
          itemBuilder: (_, i) => _adminItemCard(
            filteredDocs[i].data() as Map<String, dynamic>,
            filteredDocs[i].id,
          ),
        );
      },
    );
  }

  Widget _adminItemCard(Map<String, dynamic> d, String docId) {
    final status = d['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (d['imageUrl'] != null && d['imageUrl'] != "")
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  d['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: bgLeaf,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          Text(
            d['description'] ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            d['location'] ?? '',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusChip(status),
              const Spacer(),
              if (status == 'lost')
                _actionButton(
                  "Mark Found",
                  Icons.check_circle_outline,
                      () => _updateStatus(docId, 'found'),
                ),
              if (status == 'found')
                _actionButton(
                  "Mark Claimed",
                  Icons.verified_outlined,
                      () => _updateStatus(docId, 'claimed'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: forestGreen,
        side: const BorderSide(color: forestGreen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('lost_found_items')
        .doc(docId)
        .update({
      'status': newStatus,
      '${newStatus}At': FieldValue.serverTimestamp(),
    });
  }

  Widget _statusChip(String status) {
    Color color = status == 'lost'
        ? Colors.redAccent
        : (status == 'found' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===========================
  // ADD ITEM SHEET (Logic Preserved)
  // ===========================
  void _showAddItemSheet() {
    _descCtrl.clear();
    _locationCtrl.clear();
    selectedStatus = "lost";
    selectedDate = DateTime.now();
    selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Post Lost / Found Item",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Status selection
                Row(
                  children: [
                    _radio("lost", "Lost", setSheetState),
                    _radio("found", "Found", setSheetState),
                  ],
                ),

                const SizedBox(height: 16),
                _sheetInput(
                  Icons.description_outlined,
                  "Item Description",
                  _descCtrl,
                ),
                const SizedBox(height: 12),
                _sheetInput(
                  Icons.location_on_outlined,
                  "Location",
                  _locationCtrl,
                ),
                const SizedBox(height: 12),

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null)
                      setSheetState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgLeaf,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _imageBox(setSheetState),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isUploadingImage ? null : _addItem,
                    child: isUploadingImage
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Add Item",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _radio(String value, String label, StateSetter setSheetState) {
    return Expanded(
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedStatus,
        onChanged: (v) => setSheetState(() => selectedStatus = v!),
        title: Text(label),
        activeColor: forestGreen,
      ),
    );
  }

  Widget _sheetInput(IconData icon, String hint, TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: bgLeaf,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGreen),
        ),
      ),
    );
  }

  Widget _imageBox(StateSetter setSheetState) {
    return GestureDetector(
      onTap: () async {
        await _pickImage();
        setSheetState(() {});
      },
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgLeaf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderGreen),
        ),
        child: selectedImage == null
            ? const Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 30,
            color: forestGreen,
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(selectedImage!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Future<void> _addItem() async {
    String uploadedImageUrl = "";
    if (selectedImage != null) {
      setState(() => isUploadingImage = true);
      uploadedImageUrl = await _uploadImage(selectedImage!);
      setState(() => isUploadingImage = false);
    }

    await FirebaseFirestore.instance.collection('lost_found_items').add({
      'description': _descCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'status': selectedStatus,
      'date': "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
      'imageUrl': uploadedImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }
}
