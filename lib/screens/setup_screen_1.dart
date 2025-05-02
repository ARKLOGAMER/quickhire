import 'package:flutter/material.dart';
import 'setup_screen_2.dart'; // Next setup screen

class SetupScreen1 extends StatefulWidget {
  final String userId;
  SetupScreen1({required this.userId});

  @override
  _SetupScreen1State createState() => _SetupScreen1State();
}

class _SetupScreen1State extends State<SetupScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Step 1: Upload Profile Picture", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),

            // Profile Picture Placeholder
            CircleAvatar(radius: 50, backgroundColor: Colors.grey.shade300),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // TODO: Add Image Picker Functionality
              },
              child: Text("Upload Picture"),
            ),
            
            SizedBox(height: 40),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetupScreen2(userId: widget.userId)),
                  );
                },
                child: Text("Next", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
