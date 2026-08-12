import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _playerNameController = TextEditingController();
  final _characterController = TextEditingController();
  final _codeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  File? _licenseImage;

  static const Color gold = Color(0xFFFFC83D);
  static const Color goldDark = Color(0xFF9A6B00);
  static const Color background = Color(0xFF050505);

  @override
  void dispose() {
    _playerNameController.dispose();
    _characterController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickLicenseImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _licenseImage = File(image.path);
      });
    }
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null) {
      _showMessage('يرجى رفع صورة البروفايل');
      return;
    }

    if (_licenseImage == null) {
      _showMessage('يرجى رفع صورة الرخصة');
      return;
    }

    // في هذه المرحلة نحفظ البيانات محليًا فقط.
    // لاحقًا سنربط الحساب بقاعدة البيانات.
    _showMessage('تم إنشاء الحساب بنجاح');

    // لاحقًا نضع هنا الانتقال إلى الصفحة الرئيسية.
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF1B1B1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white54,
        fontSize: 16,
      ),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: const Color(0xFF0C0C0C),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF6F520D),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: gold,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePicker() {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: gold, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FFC83D),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
          color: const Color(0xFF101010),
        ),
        child: ClipOval(
          child: _profileImage == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white70,
                      size: 42,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'رفع صورة\nالبروفايل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : Image.file(
                  _profileImage!,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _licensePicker() {
    return GestureDetector(
      onTap: _pickLicenseImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6F520D),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.upload_rounded,
              color: gold,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _licenseImage == null
                    ? 'اضغط لرفع صورة الرخصة'
                    : 'تم اختيار صورة الرخصة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.badge_rounded,
              color: gold,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B0B0B),
                  Color(0xFF030303),
                ],
              ),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 35),
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: gold,
                    size: 58,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GOLDEN SYSTEM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    color: Color(0xFF6F520D),
                    thickness: 1,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'إنشاء حساب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gold,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Center(child: _profilePicker()),
                  const SizedBox(height: 35),

                  _sectionTitle('اسم اللاعب'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _playerNameController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'اكتب اسمك هنا',
                      icon: Icons.person_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اكتب اسم اللاعب';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('اسم الشخصية التي تريدها'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _characterController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'اكتب اسم الشخصية هنا',
                      icon: Icons.theater_comedy_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اكتب اسم الشخصية';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('الكود'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _codeController,
                    textAlign: TextAlign.right,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    decoration: _inputDecoration(
                      hint: 'اكتب كودك وتذكره جيدًا',
                      icon: Icons.lock_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 4) {
                        return 'يجب أن يكون الكود 4 أحرف أو أرقام على الأقل';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle('رفع صورة الرخصة'),
                  const SizedBox(height: 10),
                  _licensePicker(),

                  const SizedBox(height: 32),

                  SizedBox(
                    height: 62,
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        elevation: 10,
                        shadowColor: const Color(0x99FFC83D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                            color: Color(0xFFFFE59A),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: Colors.white38,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'الكود هو مفتاحك إلى حسابك، لا تنس حفظه جيدًا.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
