import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart'; // ✅ Added for the animation
import 'issue_details_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  // ✅ Navigation Logic
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Others';
  String selectedPriority = 'Medium';
  bool isPublic = true;
  bool isSubmitting = false;
  bool isAIAnalyzing = false;

  Timer? _debounce;
  final String _apiKey = 'AIzaSyBKaRN2YIOIjFbKSSUJsEC9T5zl6r9S8DY'; // ⚠️ Ensure your key is here

  final ImagePicker _picker = ImagePicker();
  final List<XFile> pickedImages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const Color primaryGreen = Color.fromARGB(255, 5, 35, 81);
  static const Color lightGreenBg = Color(0xFFEFFAF2);
  static const Color borderGreen = Color(0xFFC8E6C9);

  @override
  void dispose() {
    _debounce?.cancel();
    descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- NAVIGATION METHODS ---
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 1);
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 0);
  }

  // --- AI LOGIC ---
  Future<void> _runAITriage(String text) async {
    if (text.trim().length < 10) return;
    setState(() => isAIAnalyzing = true);
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(temperature: 0.1),
      );

      final prompt = """
      You are a Maintenance Dispatcher. Categorize the issue into EXACTLY one of these categories:
      1. Plumbing, 2. Electrical, 3. WiFi, 4. Cleanliness, 5. Furniture, 6. Others.
      
      Priority:
      - Urgent: Danger/Fire/Flooding.
      - High: Total outage (No water/power).
      - Medium: Poor service (Slow wifi).
      - Low: Cosmetic (Squeak/Scratch).

      Response Format (Strict JSON): {"category": "CategoryName", "priority": "PriorityName"}
      ISSUE: "$text"
      """;

      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) {
        String cleanJson = response.text!.trim();
        if (cleanJson.contains("```")) {
          cleanJson = cleanJson.split("```")[1].replaceAll("json", "").trim();
        }
        final Map<String, dynamic> data = jsonDecode(cleanJson);
        setState(() {
          selectedCategory = _matchCategory(data['category'].toString());
          selectedPriority = _matchPriority(data['priority'].toString());
        });
      }
    } catch (e) {
      debugPrint("AI Error: $e");
      _manualTriageFallback(text.toLowerCase());
    } finally {
      setState(() => isAIAnalyzing = false);
    }
  }

// ✅ IMPROVED: This looks for the word ANYWHERE in the AI response
  String _matchCategory(String input) {
    final lowerInput = input.toLowerCase().trim();

    // 1. Check for WiFi
    if (lowerInput.contains("wifi") || lowerInput.contains("internet")) {
      return "WiFi";
    }

    // 2. Check for Electrical (Expanded keywords)
    if (lowerInput.contains("elect") ||
        lowerInput.contains("power") ||
        lowerInput.contains("light") ||
        lowerInput.contains("fan") ||
        lowerInput.contains("socket")) {
      return "Electrical";
    }

    // 3. Check for Plumbing
    if (lowerInput.contains("plumb") || lowerInput.contains("water") || lowerInput.contains("leak")) {
      return "Plumbing";
    }

    // 4. Check for Cleanliness
    if (lowerInput.contains("clean") || lowerInput.contains("trash") || lowerInput.contains("mess")) {
      return "Cleanliness";
    }

    // 5. Check for Furniture
    if (lowerInput.contains("furnit") || lowerInput.contains("chair") || lowerInput.contains("bed") || lowerInput.contains("table")) {
      return "Furniture";
    }

    return "Others";
  }

// ✅ IMPROVED: Same logic for Priority
  String _matchPriority(String input) {
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains("urg")) return "Urgent";
    if (lowerInput.contains("high")) return "High";
    if (lowerInput.contains("low")) return "Low";

    return "Medium"; // Default to Medium
  }

  void _manualTriageFallback(String text) {
    setState(() {
      if (text.contains("fire") || text.contains("spark") || text.contains("flood")) {
        selectedPriority = "Urgent";
      } else if (text.contains("leak") || text.contains("broken") || text.contains("no water")) {
        selectedPriority = "High";
      } else {
        selectedPriority = "Medium";
      }
      if (text.contains("water") || text.contains("tap") || text.contains("leak")) {
        selectedCategory = "Plumbing";
      } else if (text.contains("wifi") || text.contains("internet")) {
        selectedCategory = "WiFi";
      } else {
        selectedCategory = "Others";
      }
    });
  }

  void _onDescriptionChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () => _runAITriage(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreenBg,
      appBar: AppBar(
        title: Text(_currentStep == 0 ? "Reporting" : "New Issue", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        elevation: 0,
        leading: _currentStep == 1
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _previousPage)
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
        children: [
          _buildIntroPage(),
          _buildFormPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildIntroPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('animations/report_issues.json', height: 280), // Ensure path is in pubspec
        const Text(
          "Quick Report",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryGreen),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Describe the issue in your own words. Our AI will handle the classification and priority for you.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Issue Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)),
          const SizedBox(height: 20),
          _buildLabel("What's the problem?"),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            onChanged: _onDescriptionChanged,
            decoration: _inputDecoration().copyWith(
              hintText: "E.g. The fan in my room is making a weird noise...",
              suffixIcon: isAIAnalyzing
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, color: Colors.purple),
            ),
          ),
          if (descriptionController.text.length >= 10) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildAIStatusChip("Category: $selectedCategory", Icons.category_outlined),
                _buildAIStatusChip("Priority: $selectedPriority", Icons.speed),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildLabel("Add Photos"),
          _buildPhotoButtons(),
          if (pickedImages.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 14), child: _buildPickedImagesGrid()),
          const SizedBox(height: 24),
          _buildPublicToggle(),
        ],
      ),
    );
  }

  // --- UI COMPONENTS (KEEP FROM PREVIOUS) ---

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity, height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: (isSubmitting || isAIAnalyzing) ? null : (_currentStep == 0 ? _nextPage : _submitIssue),
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_currentStep == 0 ? "GET STARTED" : "SUBMIT REPORT",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAIStatusChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryGreen),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryGreen)),
        ],
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Row(children: [
      _photoBtn("Gallery", Icons.photo_library_outlined, false),
      const SizedBox(width: 12),
      _photoBtn("Camera", Icons.camera_alt_outlined, true),
    ]);
  }

  Widget _photoBtn(String label, IconData icon, bool fromCamera) {
    return Expanded(child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: borderGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
      ),
      onPressed: () => _pickImage(fromCamera: fromCamera),
      icon: Icon(icon, color: primaryGreen),
      label: Text(label, style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
    ));
  }

  Widget _buildPublicToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Make this issue public", style: TextStyle(fontWeight: FontWeight.w700)),
      value: isPublic,
      activeColor: primaryGreen,
      onChanged: (val) => setState(() => isPublic = val),
    );
  }

  Widget _buildPickedImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pickedImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10),
      itemBuilder: (context, index) => Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(pickedImages[index].path), fit: BoxFit.cover, width: 100, height: 100)),
        Positioned(right: 0, child: GestureDetector(onTap: () => setState(() => pickedImages.removeAt(index)), child: const Icon(Icons.cancel, color: Colors.red))),
      ]),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    final XFile? image = await _picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() => pickedImages.add(image));
  }

  Future<void> _submitIssue() async {
    if (descriptionController.text.trim().length < 10) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSubmitting = true);
    try {
      await _runAITriage(descriptionController.text);
      List<String> imageUrls = [];
      for (var img in pickedImages) {
        final ref = _storage.ref().child('issues/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(File(img.path));
        imageUrls.add(await ref.getDownloadURL());
      }
      final issueData = {
        'userId': user.uid,
        'description': descriptionController.text,
        'priority': selectedPriority,
        'category': selectedCategory,
        'imageUrls': imageUrls,
        'status': 'Reported',
        'createdAt': FieldValue.serverTimestamp(),
        'isPublic': isPublic,
      };
      await _firestore.collection('issues').add(issueData);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IssueDetailScreen(
          title: "Issue Reported",
          description: descriptionController.text,
          category: selectedCategory,
          priority: selectedPriority,
          imageUrls: imageUrls,
        )));
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)));

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true, fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: borderGreen)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryGreen, width: 2)),
  );
}