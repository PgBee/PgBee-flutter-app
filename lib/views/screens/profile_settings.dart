import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pgbee/providers/screens_provider.dart';
class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool pushNotifications = true;
  bool notificationsSound = false;
  bool chatNotifications = false;
  bool walletUpdates = false;
  bool promoNotifications = true;
  bool twoFactorAuth = true;
  String currentPassword = '';
  String newPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             // Back button and settings title row
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                           Provider.of<ScreensProvider>(context, listen: false).changeProfileScreen('security');
                        },
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      'Notification Settings',
                      style: TextStyle(
                        color: const Color(0xFF1F1F1F),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    buildSwitchTile('Push Notifications', pushNotifications, (value) {
                      setState(() => pushNotifications = value);
                    }),
                    buildSwitchTile('Notifications Sound', notificationsSound, (value) {
                      setState(() => notificationsSound = value);
                    }),
                    buildSwitchTile('Chat Notifications', chatNotifications, (value) {
                      setState(() => chatNotifications = value);
                    }),
                    buildSwitchTile('Wallet Updates', walletUpdates, (value) {
                      setState(() => walletUpdates = value);
                    }),
                    buildSwitchTile('Promotional Notifications', promoNotifications, (value) {
                      setState(() => promoNotifications = value);
                    }),
                    Divider(color: Color(0xFF1F1F1F), thickness: 0.50),
                    Text(
                      'Two-factor Authentication',
                      style: TextStyle(
                        color: const Color(0xFF1F1F1F),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    buildSwitchTile('Enable or disable two factor authentication', twoFactorAuth, (value) {
                      setState(() => twoFactorAuth = value);
                    }),
                    Divider(color: Color(0xFF1F1F1F), thickness: 0.50),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        color: const Color(0xFF1F1F1F),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    buildPasswordField('Current Password', currentPassword, (value) {
                      setState(() => currentPassword = value);
                    }),
                    buildPasswordField('New Password', newPassword, (value) {
                      setState(() => newPassword = value);
                    }),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Integrate with backend API to update password
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF424242),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Edit Password',
                        style: TextStyle(
                          color: Color(0xFFFAFAFA),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Divider(color: Color(0xFF1F1F1F), thickness: 0.50),
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        color: const Color(0xFF1F1F1F),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Note : This action is irreversible.',
                      style: TextStyle(
                        color: const Color(0xFF1F1F1F),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Integrate with backend API to delete account
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF1F1F1F), width: 0.50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Color(0xFFE53636),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 283.83,
            child: Text(
              title,
              style: TextStyle(
                color: const Color.fromARGB(255, 134, 107, 107),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Custom switch background
          Container(
            decoration: BoxDecoration(
              color: value ? const Color(0xFF232323) : const Color.fromARGB(255, 134, 107, 107), // Light when ON, dark when OFF
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white, // Thumb stays white
              inactiveThumbColor: Colors.white, // Thumb stays white
              activeTrackColor: Colors.transparent, // Remove default track color
              inactiveTrackColor: Colors.transparent, // Remove default track color
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField(String label, String value, Function(String) onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1F1F1F),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0x4C424242),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '**********',
              hintStyle: TextStyle(
                color: Color(0x99414141),
                fontSize: 14.24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
