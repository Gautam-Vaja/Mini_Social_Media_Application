import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime? selectedDate;
  String? selectedGender = "Male";

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          profileImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        fullNameController.text = user.displayName ?? '';
        usernameController.text = user.email?.split('@').first ?? '';
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final data = doc.data()!;
      fullNameController.text =
          data['fullName']?.toString() ?? user.displayName ?? '';
      usernameController.text = data['username']?.toString() ?? '';
      bioController.text = data['bio']?.toString() ?? '';
      phoneController.text = data['phoneNumber']?.toString() ?? '';

      final gender = data['gender']?.toString();
      const validGenders = ['Male', 'Female', 'Other'];
      if (validGenders.contains(gender)) {
        selectedGender = gender;
      } else {
        selectedGender = 'Male';
      }

      final dob = data['dateOfBirth'];
      if (dob is Timestamp) {
        selectedDate = dob.toDate();
      } else if (dob is DateTime) {
        selectedDate = dob;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Load profile error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateProfile() async {
    if (isSaving) return;

    try {
      setState(() {
        isSaving = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User is not logged in");

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': fullNameController.text.trim(),
        'username': usernameController.text.trim(),
        'bio': bioController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'gender': selectedGender,
        'dateOfBirth': selectedDate != null
            ? Timestamp.fromDate(selectedDate!)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(fullNameController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : const NetworkImage(
                                      'https://i.pravatar.cc/150?img=12',
                                    )
                                    as ImageProvider,
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: _showImagePickerModal,
                            icon: Icon(
                              Icons.camera_alt,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.alternate_email),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your username'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: bioController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: InputDecoration(
                        labelText: "Bio",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          selectedDate == null
                              ? "Select Date"
                              : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                    "${selectedDate!.year}",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGender,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        prefixIcon: const Icon(Icons.people_outline),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: "Male",
                          child: Text("Male"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Female",
                          child: Text("Female"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Other",
                          child: Text("Other"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  updateProfile();
                                }
                              },
                        child: isSaving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
