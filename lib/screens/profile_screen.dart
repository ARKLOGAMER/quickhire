import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? profileImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      nameController.text = user!.displayName ?? "";
      emailController.text = user!.email ?? "";
      profileImageUrl = user!.photoURL;
      fetchUserData();
    }
  }

  void fetchUserData() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user!.uid).get();
    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc['name'];
        profileImageUrl = userDoc['photoURL'];
      });
    }
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);
    if (user != null) {
      await user!.updateDisplayName(nameController.text);
      await _firestore.collection('users').doc(user!.uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'photoURL': profileImageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> uploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String filePath = "profile_pictures/${user!.uid}.jpg";
    
    try {
      setState(() => isLoading = true);
      TaskSnapshot snapshot = await _storage.ref(filePath).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      setState(() => profileImageUrl = downloadUrl);
      await user!.updatePhotoURL(downloadUrl);
      await _firestore.collection('users').doc(user!.uid).set({
        'photoURL': downloadUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile picture updated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> changePassword() async {
    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a new password")),
      );
      return;
    }
    try {
      await user!.updatePassword(passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password")),
      );
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // Profile Image Upload
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : AssetImage('assests/assests/default_avatar.png') as ImageProvider,
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.teal),
                  onPressed: uploadProfileImage,
                ),
              ],
            ),

            SizedBox(height: 10),

            // Name
            Text(user?.displayName ?? "User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Edit Profile",
                style: TextStyle(fontSize: 14, color: Colors.grey)),

            SizedBox(height: 20),

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // Email Field (Non-editable)
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Your Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // Save & Update Buttons
            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text("Save Now",
                            style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text("Change Password",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
