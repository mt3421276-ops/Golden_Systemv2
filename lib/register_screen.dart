import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'player_data.dart';
import 'user_storage.dart';

class RegisterScreen extends StatefulWidget {
  final Future<void> Function()? onRegistered;

  const RegisterScreen({
    super.key,
    this.onRegistered,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _playerNameController = TextEditingController();
  final _characterNameController = TextEditingController();
  final _playerIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  File? _profileImage;

  static const gold = Color(0xFFFFC83D);

  Future<void> _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (_playerNameController.text.trim().isEmpty ||
        _characterNameController.text.trim().isEmpty ||
        _playerIdController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final player = PlayerData(
        playerName: _playerNameController.text.trim(),
        characterName: _characterNameController.text.trim(),
        playerId: _playerIdController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        registered: true,
        profileImagePath: _profileImage?.path,
        licenseImagePath: null,
      );

      await UserStorage.save(player);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل بنجاح!'),
          backgroundColor: gold,
        ),
      );

      await widget.onRegistered?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: gold, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _characterNameController.dispose();
    _playerIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'تسجيل جديد',
          style: TextStyle(
            color: gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: gold,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 90,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: 2,
                      child: Material(
                        color: gold,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickProfileImage,
                          child: const Padding(
                            padding: EdgeInsets.all(11),
                            child: Icon(
                              Icons.camera_alt,
                              size: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'صورة الملف الشخصي',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              TextField(
                controller: _playerNameController,
                style: const TextStyle(color: Colors.white),
                textDirection: TextDirection.rtl,
                decoration: _decoration('اسم اللاعب', Icons.person),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _characterNameController,
                style: const TextStyle(color: Colors.white),
                textDirection: TextDirection.rtl,
                decoration: _decoration(
                  'اسم الشخصية',
                  Icons.auto_awesome,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _playerIdController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: _decoration('رقم اللاعب', Icons.numbers),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: _decoration('البريد الإلكتروني', Icons.email),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                textDirection: TextDirection.ltr,
                decoration: _decoration(
                  'كلمة المرور',
                  Icons.lock,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    disabledBackgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'تسجيل',
                          style: TextStyle(
                            fontSize: 18,
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
