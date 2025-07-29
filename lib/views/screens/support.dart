import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';
import 'package:pgbee/providers/screens_provider.dart';
import 'package:provider/provider.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Support Title
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
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
                    "Support",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            // Greeting
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Hello Shravan! What can I help you with today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Search Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search some keywords from your problem for faster you',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Frequently Asked Questions
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
            ),
            // FAQ 1
            ExpansionTile(
              title: Text(
                'How do I create an account?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              initiallyExpanded: _isExpanded1,
              onExpansionChanged: (value) => setState(() => _isExpanded1 = value),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You can create a SmartPay account by downloading and open the SmartPay application first then select "Create Account" then follow the instructions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
            // FAQ 2
            ExpansionTile(
              title: Text(
                'How do I select a card for transactions?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              initiallyExpanded: _isExpanded2,
              onExpansionChanged: (value) => setState(() => _isExpanded2 = value),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You can create a card first then select "Add New Card" then follow the instructions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
            // FAQ 3
            ExpansionTile(
              title: Text(
                'How do I create a card for transactions?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              initiallyExpanded: _isExpanded3,
              onExpansionChanged: (value) => setState(() => _isExpanded3 = value),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You can create a card first then select "Add New Card" then follow the instructions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Chat with us
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LightColor.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Chat with us',
                style: TextStyle(
                  fontSize: 18,
                  color: LightColor.background,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}