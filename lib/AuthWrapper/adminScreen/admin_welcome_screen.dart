import 'dart:async'; // ✅ Required for the Timer
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'admin_navigation_hub.dart'; // ✅ Pointing to the Admin version of the navigation hub

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({super.key});

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer; // ✅ Controller for the autoscroll

  // DormTrack Admin Theme Colors (Dark Green Palette)
  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color accentGreen = const Color(0xFF4CAF50);

  // ✅ Admin specific slides for Management tasks
  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Manage Issues",
      "desc":
      "Review student complaints and assign maintenance staff in real-time.",
      "lottie":
      "animations/admin_repair.json", // Make sure to have these lottie files
      "color": const Color(0xFF1B5E20),
    },
    {
      "title": "Approve Leaves",
      "desc":
      "Quickly review and approve or reject student leave applications.",
      "lottie": "animations/admin_approval.json",
      "color": const Color(0xFF2E7D32),
    },
    {
      "title": "Mess Control",
      "desc": "Update the daily mess menu and monitor student food feedback.",
      "lottie": "animations/admin_mess.json",
      "color": const Color(0xFF388E3C),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoscroll(); // ✅ Trigger autoscroll on load
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ Prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  // ✅ Timer logic for 4-second delay
  void _startAutoscroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _slides.length - 1) {
        _currentPage++;
      } else {
        // Stop timer at the last page
        _timer?.cancel();
        return;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  // ✅ UPDATED: Navigates to AdminMainWrapper
  void _finishOnboarding() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminNavigationHub()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background Transition (Green)
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            color: _slides[_currentPage]['color'],
          ),

          // 2. Sliding Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
              // Reset timer if user manually swipes
              _timer?.cancel();
              if (page < _slides.length - 1) _startAutoscroll();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index], index == _currentPage);
            },
          ),

          // 3. Skip Button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _finishOnboarding,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2), // Glass effect
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),

          // 4. Navigation UI (Indicator + Action Button)
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: Column(
              children: [
                // Animated Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                        (index) => _buildDot(index == _currentPage),
                  ),
                ),
                const SizedBox(height: 40),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGreen, // Green text for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_currentPage == _slides.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? "ADMIN DASHBOARD"
                          : "CONTINUE",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> slide, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation Container
          SizedBox(
            height: 300,
            child: Lottie.asset(
              slide['lottie'],
              repeat: true,
              animate: isCurrent,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            slide['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide['desc'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.4),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
