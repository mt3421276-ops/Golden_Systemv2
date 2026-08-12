import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'player_data.dart';
import 'user_storage.dart';

class RegisterScreen extends StatefulWidget {
  final Future<void> Function()? onRegistered;
  const RegisterScreen({super.key, this.onRegistered});

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
  File? _licenseImage;

  Future<void> _pickImage(String type) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          if (type == 'profile') {
            _profileImage = File(image.path);
          } else {
            _licenseImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
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
        licenseImagePath: _licenseImage?.path,
      );

      await UserStorage.save(player);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التسجيل بنجاح!'),
          backgroundColor: Color(0xFFFFC83D),
        ),
      );

      await widget.onRegistered?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFFFFC83D)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFC83D)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'تسجيل جديد',
          style: TextStyle(color: Color(0xFFFFC83D)),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFC83D),
                      backgroundImage:
                          _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.black)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickImage('profile'),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFC83D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'صورة الملف الشخصي',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _playerNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('اسم اللاعب', Icons.person),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _characterNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('اسم الشخصية', Icons.auto_awesome),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _playerIdController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _decoration('رقم اللاعب', Icons.numbers),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('البريد الإلكتروني', Icons.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                decoration: _decoration('كلمة المرور', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC83D),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
