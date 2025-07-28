import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // Editable controllers
  final nameController = TextEditingController(text: "Charlene Reed");
  final emailController = TextEditingController(text: "charlenereed@gmail.com");
  final dobController = TextEditingController(text: "25 January 1990");
  final permanentAddressController = TextEditingController(text: "San Jose, California, USA");
  final cityController = TextEditingController(text: "San Jose");
  final usernameController = TextEditingController(text: "Charlene Reed");
  final passwordController = TextEditingController(text: "*********");
  final countryController = TextEditingController(text: "USA");
  final presentAddressController = TextEditingController(text: "San Jose, California, USA");
  final postalCodeController = TextEditingController(text: "45962");

  // Profile image state
  File? _profileImage;

  // Calendar for Date of Birth
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(
      _parseDate(dobController.text),
    ) ??
        DateTime(1990, 1, 25);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text =
            "${picked.day.toString().padLeft(2, '0')} ${_monthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _parseDate(String dateText) {
    // Expects format: "25 January 1990"
    final parts = dateText.split(' ');
    if (parts.length == 3) {
      final months = {
        "January": "01",
        "February": "02",
        "March": "03",
        "April": "04",
        "May": "05",
        "June": "06",
        "July": "07",
        "August": "08",
        "September": "09",
        "October": "10",
        "November": "11",
        "December": "12",
      };
      return "${parts[2]}-${months[parts[1]] ?? "01"}-${parts[0].padLeft(2, '0')}";
    }
    return "1990-01-25";
  }

  String _monthName(int month) {
    const names = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return names[month - 1];
  }

  // Function to handle profile photo edit
  Future<void> _editProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper for field label
    Widget fieldLabel(String label) => Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0, top: 22.0),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFF878787),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'Roboto',
            ),
          ),
        );

    // Helper for editable field (now enabled)
    Widget editableField(TextEditingController controller,
        {bool isObscure = false, bool enableTap = false, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: TextField(
          controller: controller,
          obscureText: isObscure,
          readOnly: enableTap,
          onTap: enableTap ? onTap : null,
          style: TextStyle(
            color: Color(0xFF373737),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4D4D4), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.white,
            filled: true,
            suffixIcon: enableTap
                ? Icon(Icons.calendar_today, color: Colors.grey)
                : null,
          ),
        ),
      );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          elevation: 0,
          currentIndex: 3,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/pg-details');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/inbox');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: 'PG Details',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PgBee logo at the top, center-aligned
                Padding(
                  padding: const EdgeInsets.only(bottom: 18.0, top: 4),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Pg',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.yellow[700],
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: 'Bee',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Back button and Profile title row
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Profile",
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
                // Profile image with edit button overlay (square, rounded corners)
                Center(
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _profileImage != null
                              ? Image.file(_profileImage!, fit: BoxFit.cover)
                              : Image.asset('assets/profile_sample.png', fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _editProfilePhoto,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              width: 32,
                              height: 32,
                              child: Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // "Save" button below image
                Center(
                  child: SizedBox(
                    width: 120, // Match profile image width
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6),
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      onPressed: () {
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Editable profile fields
                fieldLabel("Your Name"),
                editableField(nameController),
                fieldLabel("Email"),
                editableField(emailController),
                fieldLabel("Date of Birth"),
                editableField(dobController, enableTap: true, onTap: () => _selectDate(context)),
                fieldLabel("Permanent Address"),
                editableField(permanentAddressController),
                fieldLabel("City"),
                editableField(cityController),
                fieldLabel("User Name"),
                editableField(usernameController),
                fieldLabel("Password"),
                editableField(passwordController, isObscure: true),
                fieldLabel("Country"),
                editableField(countryController),
                fieldLabel("Present Address"),
                editableField(presentAddressController),
                fieldLabel("Postal Code"),
                editableField(postalCodeController),
                SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}