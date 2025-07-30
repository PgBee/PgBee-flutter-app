import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/enquiry_provider.dart';
import '../../providers/hostel_provider.dart';
import '../../models/enquiry_model.dart';
import '../../services/local_storage_service.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnquiries();
    });
  }

  void _loadEnquiries() async {
    final enquiryProvider = Provider.of<EnquiryProvider>(context, listen: false);
    
    try {
      // Load enquiries with local storage sync
      await enquiryProvider.loadEnquiries('owner_1'); // Replace with actual owner ID
      
      // Check if we're in fallback mode
      final isFallbackMode = await LocalStorageService.isFallbackMode();
      if (isFallbackMode || enquiryProvider.errorMessage != null) {
        print('Using local storage mode for enquiries');
        await LocalStorageService.setFallbackMode(true);
        
        // Initialize mock data if no local data exists
        final localEnquiries = await LocalStorageService.getEnquiries();
        if (localEnquiries.isEmpty) {
          await LocalStorageService.initMockData();
          // Reload from local storage after initializing mock data
          await enquiryProvider.loadFromLocalStorage();
        }
      }
    } catch (e) {
      print('Error loading enquiries: $e');
      await LocalStorageService.setFallbackMode(true);
      await enquiryProvider.loadFromLocalStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEnquiries,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Denied'),
          ],
          labelColor: LightColor.black,
          unselectedLabelColor: LightColor.grey,
          indicatorColor: LightColor.black,
        ),
      ),
      body: Consumer<EnquiryProvider>(
        builder: (context, enquiryProvider, child) {
          if (enquiryProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (enquiryProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${enquiryProvider.errorMessage}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEnquiries,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEnquiryList(enquiryProvider.pendingEnquiries, 'pending'),
              _buildEnquiryList(enquiryProvider.acceptedEnquiries, 'accepted'),
              _buildEnquiryList(enquiryProvider.deniedEnquiries, 'denied'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnquiryList(List<EnquiryModel> enquiries, String status) {
    if (enquiries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.inbox : 
              status == 'accepted' ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: LightColor.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No ${status} enquiries',
              style: TextStyle(
                fontSize: 18,
                color: LightColor.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadEnquiries(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: enquiries.length,
        itemBuilder: (context, index) {
          final enquiry = enquiries[index];
          return _buildEnquiryCard(enquiry);
        },
      ),
    );
  }

  Widget _buildEnquiryCard(EnquiryModel enquiry) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: LightColor.black,
                  child: Text(
                    enquiry.studentName.isNotEmpty ? enquiry.studentName[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: LightColor.background,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enquiry.studentName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: LightColor.black,
                        ),
                      ),
                      Text(
                        enquiry.studentEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: LightColor.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(enquiry.status),
              ],
            ),
            SizedBox(height: 12),
            
            // Show phone number if enquiry is accepted
            if (enquiry.status == 'accepted') ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      enquiry.studentPhone,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () => _makePhoneCall(enquiry.studentPhone),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],
            
            // Enquiry message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: LightColor.grey.withOpacity(0.3)),
              ),
              child: Text(
                enquiry.message,
                style: TextStyle(
                  fontSize: 14,
                  color: LightColor.black,
                ),
              ),
            ),
            SizedBox(height: 12),
            
            // Time and date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: LightColor.grey),
                SizedBox(width: 4),
                Text(
                  _formatDateTime(enquiry.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: LightColor.grey,
                  ),
                ),
                if (enquiry.respondedAt != null) ...[
                  SizedBox(width: 16),
                  Icon(Icons.reply, size: 16, color: LightColor.grey),
                  SizedBox(width: 4),
                  Text(
                    'Responded: ${_formatDateTime(enquiry.respondedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: LightColor.grey,
                    ),
                  ),
                ],
              ],
            ),
            
            // Action buttons for pending enquiries
            if (enquiry.status == 'pending') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptEnquiry(enquiry),
                      icon: Icon(Icons.check, color: LightColor.background),
                      label: Text(
                        'Accept',
                        style: TextStyle(color: LightColor.background),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _denyEnquiry(enquiry),
                      icon: Icon(Icons.close, color: Colors.red),
                      label: Text(
                        'Deny',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'denied':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _acceptEnquiry(EnquiryModel enquiry) async {
    final enquiryProvider = Provider.of<EnquiryProvider>(context, listen: false);
    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Enquiry'),
        content: Text('Are you sure you want to accept this enquiry from ${enquiry.studentName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Accept'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Accept enquiry (this now handles local storage persistence automatically)
        final enquirySuccess = await enquiryProvider.acceptEnquiry(enquiry.id);
        
        if (enquirySuccess) {
          // Try to update counter
          bool counterSuccess = false;
          
          try {
            // Try backend counter update first
            counterSuccess = await hostelProvider.updateAdmittedStudents(1);
            
            if (!counterSuccess) {
              // Backend failed, use local storage for persistent counter
              print('Backend counter update failed, using local storage');
              await LocalStorageService.incrementAdmittedStudents();
              counterSuccess = true;
            } else {
              // Sync with local storage for persistence
              await LocalStorageService.incrementAdmittedStudents();
            }
          } catch (e) {
            print('Counter update error: $e');
            // Fallback to local storage
            await LocalStorageService.incrementAdmittedStudents();
            counterSuccess = true;
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(counterSuccess 
                ? 'Enquiry accepted! Student count updated.'
                : 'Enquiry accepted but failed to update student count.'),
              backgroundColor: counterSuccess ? Colors.green : Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept enquiry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error in accept enquiry: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while accepting the enquiry'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _denyEnquiry(EnquiryModel enquiry) async {
    final enquiryProvider = Provider.of<EnquiryProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deny Enquiry'),
        content: Text('Are you sure you want to deny this enquiry from ${enquiry.studentName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Deny'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Deny enquiry (this now handles local storage persistence automatically)
        final success = await enquiryProvider.denyEnquiry(enquiry.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Enquiry denied.' : 'Failed to deny enquiry'),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
      } catch (e) {
        print('Error denying enquiry: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while denying the enquiry'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber) {
    // In a real app, you would use url_launcher to make phone calls
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phoneNumber...')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
