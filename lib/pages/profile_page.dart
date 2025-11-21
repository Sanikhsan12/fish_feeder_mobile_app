import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import './login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  UserModel? _user;
  bool _isLoading = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await _profileService.getUserProfile(uid);
      setState(() {
        _user = user ??
            UserModel(
              uid: uid,
              name: '',
              gender: '',
              birthdate: '',
              photoUrl: null,
            );
        _nameController.text = _user!.name;
        _genderController.text = _user!.gender;
        _birthdateController.text = _user!.birthdate;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final updatedUser = UserModel(
          uid: uid,
          name: _nameController.text,
          gender: _genderController.text,
          birthdate: _birthdateController.text,
          photoUrl: null,
        );
        await _profileService.saveUserProfile(updatedUser);
        setState(() {
          _user = updatedUser;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final genderValue = (_genderController.text == 'Laki-Laki')
        ? 'Laki-laki'
        : _genderController.text;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              // Profile Picture Placeholder
              CircleAvatar(
                radius: 50,
                child: _user?.photoUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 16),
              // UID Display
              Text(
                'UID: ${_user?.uid ?? "-"}',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 100),
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Gender
              DropdownButtonFormField<String>(
                value: genderValue.isNotEmpty ? genderValue : null,
                items: const [
                  DropdownMenuItem(
                      value: 'Laki-laki',
                      child: Text('Laki-laki', style: TextStyle(fontSize: 20))),
                  DropdownMenuItem(
                      value: 'Perempuan',
                      child: Text('Perempuan', style: TextStyle(fontSize: 20))),
                ],
                dropdownColor: Colors.cyan,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                onChanged: (value) {
                  _genderController.text = value ?? '';
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Gender wajib dipilih'
                    : null,
              ),
              const SizedBox(height: 16),
              // Birthdate
              TextFormField(
                controller: _birthdateController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 20),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(_birthdateController.text) ??
                        DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _birthdateController.text =
                        pickedDate.toIso8601String().split('T').first;
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal lahir wajib diisi'
                    : null,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Simpan',
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
