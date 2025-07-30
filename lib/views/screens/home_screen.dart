import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pgbee/providers/hostel_provider.dart';
import 'package:pgbee/services/local_storage_service.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
  int _studentCount = 0;  // Initialize to 0
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    // Load data in order of priority
    _initializeStudentCount();
  }

    Future<void> _initializeStudentCount() async {
    // First try to load from local storage
    final persistentCount = await LocalStorageService.getAdmittedStudentsCount();
    if (mounted) {
      setState(() {
        _studentCount = persistentCount;
      });
    }
    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    if (hostelProvider.hostel == null) {
      await hostelProvider.loadHostelDetails('owner_1');
    } else if (hostelProvider.hostel?.admittedStudents != null) {
      setState(() {
        _studentCount = hostelProvider.hostel!.admittedStudents;
      });
    }
  }


  void _decrement() {
    if (_studentCount > 0) {
      setState(() {
        _studentCount = _studentCount - 1;
      });
    }
  }

  void _increment() {
    setState(() {
      _studentCount = _studentCount + 1;
    });
  }

  Future<void> _updateStudents() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
      
      // Try backend update first
      bool backendSuccess = false;
      try {
        await hostelProvider.updateAdmittedStudents(_studentCount);
        backendSuccess = true;
      } catch (e) {
        print('Backend update failed: $e');
      }
      
      // Always update local storage for persistence
      await LocalStorageService.setAdmittedStudentsCount(_studentCount);
      
      setState(() {
        _isLoading = false;
        _message = backendSuccess 
            ? 'Updated successfully to $_studentCount students!'
            : 'Updated locally to $_studentCount students (backend unavailable)';
      });
      
      if (!backendSuccess) {
        await LocalStorageService.setFallbackMode(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Failed to update student count';
      });
    }
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
          color: LightColor.background,
          elevation: 4,
          shadowColor: LightColor.shadowColor,
          shape: AppTheme.borderShape,
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
                      icon: Icon(Icons.remove_circle_outline, size: 36,color: LightColor.black,),
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
                      icon: Icon(Icons.add_circle_outline, size: 36,color: LightColor.black,),
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