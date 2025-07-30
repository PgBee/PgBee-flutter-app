import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pgbee/providers/screens_provider.dart';
import 'package:pgbee/providers/auth_provider.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "S",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Shravan Pandala",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Owner",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Column(
                    children: [
                      _ProfileMenuTile(
                        icon: Icons.person_outline,
                        title: "Profile",
                        onTap: () {
                          Provider.of<ScreensProvider>(context, listen: false)
                              .changeProfileScreen('profile_edit');
                        },
                      ),
                      _ProfileMenuTile(
                        icon: Icons.settings,
                        title: "Settings & Privacy",
                       onTap: () {
                        Provider.of<ScreensProvider>(context, listen: false).changeProfileScreen('settings');
                      },
                      ),
                      _ProfileMenuTile(
                        icon: Icons.help_outline,
                        title: "Get Support",
                        onTap: () {
                            Provider.of<ScreensProvider>(context, listen: false).changeProfileScreen('support');
                          },
                      ),
                      _ProfileMenuTile(
                        icon: Icons.assignment_outlined,
                        title: "Terms & Conditions",
                        onTap: () {
                          Provider.of<ScreensProvider>(context, listen: false).changeProfileScreen('terms');
                        },
                      ),
                      _ProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: "Privacy Policy",
                        onTap: () {
                          Provider.of<ScreensProvider>(context, listen: false).changeProfileScreen('privacy');
                        },
                      ),
                      _ProfileMenuTile(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () async {
                          // Show confirmation dialog
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // Perform logout
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              await authProvider.signOut();

                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Navigate to landing page instead of auth screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/landing',
                                (route) => false, // Remove all previous routes
                              );
                            } catch (e) {
                              // Close loading dialog if still open
                              Navigator.of(context).pop();
                              
                              // Show error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logout failed: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        titleStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                        iconColor: Colors.red,
                        trailingColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final TextStyle? titleStyle;
  final Color? iconColor;
  final Color? trailingColor;

  const _ProfileMenuTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleStyle,
    this.iconColor,
    this.trailingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 3.0),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Colors.black87,
                  size: 24,
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ??
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: trailingColor ?? Colors.black26,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}