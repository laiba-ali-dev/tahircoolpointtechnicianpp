import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tahircoolpointtechnician/order.dart';

import 'home.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
String username = "";
String email = "";

// Hash function to convert plain password to hash
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
@override
void initState() {
  super.initState();
  _fetchTechnicianData();
}


void _fetchTechnicianData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Assuming 'technicians' collection uses email as document field
      final snapshot = await FirebaseFirestore.instance
          .collection('technicians')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          username = data['full_name'] ?? 'No Name';
          email = data['email'] ?? user.email!;
        });
      }
    }
  } catch (e) {
    print("Error fetching technician data: $e");
  }
}



  void _showEmailUpdateDialog() {
  TextEditingController emailController = TextEditingController(text: email);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Update Email',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Email',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final newEmail = emailController.text.trim();
              final user = FirebaseAuth.instance.currentUser;

              if (user != null && newEmail.isNotEmpty && newEmail != email) {
                try {
                await user.verifyBeforeUpdateEmail(newEmail);


                  // Update Firestore
                  final query = await FirebaseFirestore.instance
                      .collection('technicians')
                      .where('email', isEqualTo: email)
                      .limit(1)
                      .get();

                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.update({'email': newEmail});
                  }

                  setState(() {
                    email = newEmail;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email updated successfully")),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.message}")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid and different email")),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}


  void _showPasswordChangeDialog() {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Old Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
           onPressed: () async {
  final oldPassword = oldPasswordController.text.trim();
  final newPassword = newPasswordController.text.trim();
  final user = FirebaseAuth.instance.currentUser;

  if (user != null && oldPassword.isNotEmpty && newPassword.length >= 6) {
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      String hashedPassword = hashPassword(newPassword);
      await FirebaseFirestore.instance
          .collection('technicians')
          .doc(user.uid)
          .update({'password': hashedPassword});

      // Close dialog only after successful update
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } on FirebaseAuthException catch (e) {
      // Dialog stays open on error, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  } else {
    // Dialog stays open on invalid input, show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter valid old and new passwords")),
    );
  }
},

            child: const Text('Change Password'),
          ),
        ],
      );
    },
  );
}
  void _logout() {
    // Implement logout logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'images/icon.png',
              height: 30,
              width: 30,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.business, color: Colors.red),
            ),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
            ),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileItem(
                      icon: Icons.person,
                    
                      label: 'Username',
                      value: username,
                    ),
                    const Divider(color: Colors.grey),
                    GestureDetector(
                      onTap: _showEmailUpdateDialog,
                      child: _buildProfileItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: email,
                        isClickable: true,
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    GestureDetector(
                      onTap: _showPasswordChangeDialog,
                      child: _buildProfileItem(
                        icon: Icons.lock,
                        label: 'Change Password',
                        value: 'Tap to change password',
                        isClickable: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _logout,
              child: const Text(
                'Log Out',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  OrderPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isClickable ? Colors.red : Colors.white,
                    fontSize: 16,
                    fontWeight: isClickable ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (isClickable) const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    );
  }
}