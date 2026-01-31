import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final reasonController = TextEditingController();
  final destinationController = TextEditingController();
  final parentContactController = TextEditingController();

  String? selectedLeaveType;
  DateTime? departureDate;
  DateTime? returnDate;
  bool isLoading = false;

  final List<String> leaveTypes = [
    'Home Visit',
    'Medical',
    'Academic',
    'Emergency',
  ];

  Future<void> submitLeaveRequest() async {
    if (!_formKey.currentState!.validate() ||
        departureDate == null ||
        returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'userId': user!.uid,
        'type': 'Leave Request',
        'leaveCategory': selectedLeaveType,
        'reason': reasonController.text.trim(),
        'destination': destinationController.text.trim(),
        'parentContact': parentContactController.text.trim(),
        'departureDate': departureDate,
        'returnDate': returnDate,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request Submitted Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          departureDate = null;
          returnDate = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          "Apply for Leave",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(),
              const SizedBox(height: 15),
              _buildTextField(
                destinationController,
                "Destination Address",
                Icons.map_rounded,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                parentContactController,
                "Parent/Guardian Phone",
                Icons.phone_android_rounded,
                isPhone: true,
              ),
              const SizedBox(height: 15),
              _buildDateTile(
                "Departure Date",
                departureDate,
                    (date) => setState(() => departureDate = date),
              ),
              const SizedBox(height: 15),
              _buildDateTile(
                "Return Date",
                returnDate,
                    (date) => setState(() => returnDate = date),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                reasonController,
                "Reason for Leave",
                Icons.edit_note_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedLeaveType,
        hint: const Text("Select Leave Type"),
        items: leaveTypes
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: (v) => setState(() => selectedLeaveType = v),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.category_rounded, color: Color(0xFF2196F3)),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        int maxLines = 1,
        bool isPhone = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateTile(
      String label,
      DateTime? date,
      Function(DateTime) onPick,
      ) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(
        Icons.calendar_today_rounded,
        color: Color(0xFF2196F3),
      ),
      title: Text(
        date == null ? label : "${date.day}/${date.month}/${date.year}",
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2026),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isLoading ? null : submitLeaveRequest,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Submit Request",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
