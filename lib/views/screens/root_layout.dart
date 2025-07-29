import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/providers/screens_provider.dart';
import 'package:pgbee/views/screens/Privacy_policy.dart';
import 'package:pgbee/views/screens/home_screen.dart';
import 'package:pgbee/views/screens/profile.dart';
import 'package:pgbee/views/screens/profile_settings.dart';
import 'package:pgbee/views/screens/profile_edit.dart';
import 'package:pgbee/views/screens/support.dart';
import 'package:pgbee/views/screens/terms_conditions.dart';
import 'package:provider/provider.dart';

class RootLayout extends StatefulWidget {
  @override
  State<RootLayout> createState() => _StateRootLayout();
}

class _StateRootLayout extends State<RootLayout> {
  // Define a map to hold the screens for the profile section
  final Map<String, Widget> _profileScreens = {
    'security': SecuritySettingsPage(),
    'settings': ProfileSettings(),
    'profile_edit': ProfileEditPage(),
    'terms': TermsConditionsPage(),
    'privacy': PrivacyPolicyPage(),
    'support': SupportPage(),
    
  };

  final List<Widget> _screens = [
    HomePage(),
    Center(child: Text("PG Details")),
    Center(child: Text("Inbox")),
    // Profile section will be dynamically updated
    Container(), // Placeholder, will be set dynamically
  ];

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<ScreensProvider>(context);
    int selectedIndex = pageProvider.currentIndex;

    // Set the profile screen based on the provider's profileScreen state
    _screens[3] = _profileScreens[pageProvider.profileScreen] ?? SecuritySettingsPage();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          width: 230,
          height: 40,
          fit: BoxFit.fill,
        ),
        centerTitle: true,
      ),
      body: _screens[selectedIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BottomNavigationBar(
            onTap: pageProvider.changePage,
            selectedIconTheme: IconThemeData(
              color: LightColor.background,
            ),
            unselectedIconTheme: IconThemeData(
              color: LightColor.grey,
            ),
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: LightColor.black,
            selectedItemColor: LightColor.background,
            unselectedItemColor: LightColor.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  size: 30,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.description_outlined,
                  size: 30,
                ),
                label: "PG Details",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.mail_outline,
                  size: 30,
                ),
                label: "Inbox",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_2_outlined,
                  size: 30,
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}