import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 393,
        padding: const EdgeInsets.only(top: 64),
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Color(0xFFFAFAFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Owner update feature
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OwnerUpdateSection(),
              ),
              const SizedBox(height: 32),
              // Student Feedback Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StudentFeedbackSection(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentFeedbackSection extends StatefulWidget {
  const StudentFeedbackSection({super.key});

  @override
  State<StudentFeedbackSection> createState() => _StudentFeedbackSectionState();
}

class _StudentFeedbackSectionState extends State<StudentFeedbackSection> {
  String _selectedFilter = 'Highest Rated';

  // Dummy data for demonstration
  final Map<String, List<Map<String, String>>> _feedbackData = {
    'Highest Rated': [
      {'name': 'Student A', 'feedback': 'Mathew is kind and helpful, good, helpful staff. Clean peaceful property'},
      {'name': 'Student B', 'feedback': 'Absolutely fantastic! Best experience ever.'},
    ],
    'Lowest Rated': [
      {'name': 'Student C', 'feedback': 'Very disappointing, would not recommend.'},
    ],
    'Positive': [
      {'name': 'Student D', 'feedback': 'A very positive and pleasant stay.'},
      {'name': 'Student E', 'feedback': 'Staff was friendly and helpful.'},
      {'name': 'Student F', 'feedback': 'Clean rooms and great amenities.'},
    ],
    'Negative': [
      {'name': 'Student G', 'feedback': 'The WiFi was very slow and unreliable.'},
    ],
  };

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> currentFeedback = _feedbackData[_selectedFilter] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x4C424242),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _feedbackData.keys.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildFilterChip(context, filter),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Feedback Table
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Student Name',
                      style: TextStyle(
                        color: Color(0x99414141),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Feedback',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0x99414141),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(color: Color(0x4C424242), thickness: 1),
              const SizedBox(height: 8),
              // Feedback Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentFeedback.length,
                itemBuilder: (context, index) {
                  final feedback = currentFeedback[index];
                  return _buildFeedbackRow(feedback['name']!, feedback['feedback']!);
                },
                separatorBuilder: (context, index) => const Divider(color: Color(0x0C424242), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Text(
              'View More',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => _onFilterSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF1F1F1F) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFF1F1F1F),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFAFAFA) : const Color(0xFF1F1F1F),
            fontSize: 11,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackRow(String studentName, String feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              studentName,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              feedback,
              style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Owner update section widget
class OwnerUpdateSection extends StatefulWidget {
  const OwnerUpdateSection({super.key});

  @override
  State<OwnerUpdateSection> createState() => _OwnerUpdateSectionState();
}

class _OwnerUpdateSectionState extends State<OwnerUpdateSection> {
  int _studentCount = 0; // Initial value, should be fetched from backend
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHostelData();
    });
  }

  void _loadHostelData() {
    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    hostelProvider.loadHostelDetails('owner_1'); // Replace with actual owner ID
  }

  void _decrement() {
    if (_studentCount > 0) {
      setState(() {
        _studentCount--;
      });
    }
  }

  void _increment() {
    setState(() {
      _studentCount++;
    });
  }

  Future<void> _updateStudents() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    final success = await hostelProvider.updateAdmittedStudents(_studentCount);
    
    setState(() {
      _isLoading = false;
      if (success) {
        _message = 'Updated successfully to $_studentCount students!';
      } else {
        _message = 'Failed to update student count';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HostelProvider>(
      builder: (context, hostelProvider, child) {
        // Update local count when hostel data changes
        if (hostelProvider.hostel != null && _studentCount != hostelProvider.hostel!.admittedStudents) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _studentCount = hostelProvider.hostel!.admittedStudents;
            });
          });
        }

        return Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Update Admitted Students',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decrement Button
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 36),
                      onPressed: _decrement,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Count Display
                    Text(
                      '$_studentCount',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                    // Increment Button
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 36),
                      onPressed: _increment,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: (_isLoading || hostelProvider.isLoading) ? null : _updateStudents,
                    child: (_isLoading || hostelProvider.isLoading)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                        : const Text('Confirm Update', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('Failed') ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (hostelProvider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    hostelProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}