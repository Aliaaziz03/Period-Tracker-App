import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController raceController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();

  bool informationCorrect = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _uploadedImage; // State variable to hold the uploaded image path

  // Dropdown options for race and nationality
  final List<String> raceOptions = ['Malay', 'Chinese', 'Indian', 'Others'];
  final List<String> nationalityOptions = ['Malaysian', 'Non-Malaysian'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        var data = userData.data() as Map<String, dynamic>;
        setState(() {
          fullNameController.text = data['fullName'] ?? '';
          dobController.text = data['dob'] ?? '';
          raceController.text = data['race'] ?? '';
          nationalityController.text = data['nationality'] ?? '';
          _uploadedImage = data['profileImage'] ?? '';
        });
      }
    }
  }

  Future<void> _saveInfoToFirestore(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user == null) {
          Fluttertoast.showToast(msg: "No user is currently logged in.");
          return;
        }

        // Update user personal information to Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'fullName': fullNameController.text,
          'dob': dobController.text,
          'race': raceController.text,
          'nationality': nationalityController.text,
          'profileImage': _uploadedImage, // Save image URL or path
        });

        Fluttertoast.showToast(msg: "Information saved successfully!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Failed to save information.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadPhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _uploadedImage = image.path; // Store the image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              InkWell(
                onTap: _uploadPhoto,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.pink.withOpacity(0.4),
                  backgroundImage: _uploadedImage != null
                      ? FileImage(File(_uploadedImage!)) // Use the uploaded image
                      : null,
                  child: _uploadedImage == null
                      ? Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Colors.pink.withOpacity(0.4),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              _buildTextFormField('Full Name', fullNameController),
              _buildTextFormField('DOB', dobController),
              _buildRaceDropdown(),
              _buildNationalityDropdown(),
              SizedBox(height: 40),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => _saveInfoToFirestore(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.withOpacity(0.4),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRaceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Race',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: raceOptions
            .map((race) => DropdownMenuItem(value: race, child: Text(race)))
            .toList(),
        onChanged: (value) {
          setState(() {
            raceController.text = value!;
          });
        },
      ),
    );
  }

  Widget _buildNationalityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Nationality',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: nationalityOptions
            .map((nationality) => DropdownMenuItem(value: nationality, child: Text(nationality)))
            .toList(),
        onChanged: (value) {
          setState(() {
            nationalityController.text = value!;
          });
        },
      ),
    );
  }
}
