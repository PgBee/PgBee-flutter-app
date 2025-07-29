import 'package:flutter/material.dart';

import 'package:pgbee/providers/screens_provider.dart';
import 'package:provider/provider.dart';

class TermsConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
         
            // Terms & Conditions Title
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
                  "Terms & Conditions",
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
            // Terms & Conditions Content
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vitae dictum turpis. Fusce hendrerit quam vel mauris ullamcorper euismod.\n\n1. Integer congue leo non augue tincidunt varius. Duis consequat justo et urna vulputate ultricies. Cras malesuada ante eget eros tincidunt, at congue libero varius. Vivamus tincidunt tortor vel efficitur ullamcorper.\n\n2. Nam scelerisque aliquam nibh, a condimentum nulla sollicitudin vel. Proin bibendum velit eu justo scelerisque, vel tincidunt risus facilisis. Nulla facilisi. Sed ultrices efficitur nisl, non elementum justo tincidunt eu. Suspendisse eu fringilla risus. Curabitur efficitur nunc vel quam cursus, eu convallis orci commodo. Integer eget tristique libero, eu gravida elit.\n\n3. Etiam finibus, felis ut ultricies tincidunt, erat justo scelerisque dui, ac pharetra lectus tellus non justo. Suspendisse malesuada ligula in velit tincidunt, non vulputate metus laculis. Donec id dolor id purus varius ornare.\n\n4. Nulla facilisi Praesent tincidunt, mauris quis lacinia tincidunt, dolor enim ullamcorper purus, in convallis ligula justo in turpis. Quisque ut tincidunt felis.\n\n5. Sed id lacinia neque. Vestibulum vel turpis vulputate, libero odio bibendum felis, at tempus justo arcu at justo. Vivamus vel ex vulputate, bibendum odio vel, ullamcorper tellus. Quisque efficitur fringilla sem at aliquam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed auctor leo non sem tincidunt, at malesuada ex ullamcorper.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}