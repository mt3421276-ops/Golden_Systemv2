import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'player_data.dart';
import 'user_storage.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegistered;
  const RegisterScreen({super.key, this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerName = TextEditingController();
  final _characterName = TextEditingController();
  final _playerId = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  File? _profileImage;
  bool _saving = false;
  bool _showPassword = false;

  static const gold = Color(0xFFFFC83D);
  static const card = Color(0xFF101010);

  @override
  void dispose() {
    _playerName.dispose();
    _characterName.dispose();
    _playerId.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _chooseProfileImage() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (result == null || !mounted) return;
      setState(() => _profileImage = File(result.path));
    } catch (_) {
      if (mounted) _message('تعذر فتح معرض الصور');
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'أدخل $label';
    return null;
  }

  String? _emailValidator(String? value) {
    final error = _required(value, 'البريد الإلكتروني');
    if (error != null) return error;
    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final error = _required(value, 'كلمة المرور');
    if (error != null) return error;
    if (value!.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, textDirection: TextDirection.rtl)),
    );
  }

  Future<void> _register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final player = PlayerData(
        playerName: _playerName.text.trim(),
        characterName: _characterName.text.trim(),
        playerId: _playerId.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        registered: true,
        profileImagePath: _profileImage?.path,
        licenseImagePath: null,
      );

      await UserStorage.save(player);
      if (!mounted) return;
      _message('تم التسجيل بنجاح');
      widget.onRegistered?.call();
    } catch (_) {
      if (mounted) _message('تعذر حفظ الحساب. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: gold),
      suffixIcon: suffix,
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF292929)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _decoration(label, icon, suffix: suffix),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        Center(
                          child: GestureDetector(
                            onTap: _chooseProfileImage,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: gold,
                                    image: _profileImage != null
                                        ? DecorationImage(
                                            image: FileImage(_profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _profileImage == null
                                      ? const Icon(Icons.person, color: Colors.black, size: 62)
                                      : null,
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: gold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                      size: 21,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'اضغط على الصورة لاختيار صورة من الهاتف',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 22),
                        _field(
                          controller: _playerName,
                          label: 'اسم اللاعب',
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          validator: (v) => _required(v, 'اسم اللاعب'),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _characterName,
                          label: 'اسم الشخصية',
                          icon: Icons.auto_awesome_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (v) => _required(v, 'اسم الشخصية'),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _playerId,
                          label: 'رقم اللاعب',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (v) => _required(v, 'رقم اللاعب'),
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _email,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _password,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          textInputAction: TextInputAction.done,
                          obscureText: !_showPassword,
                          validator: _passwordValidator,
                          suffix: IconButton(
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white24,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'تسجيل الحساب',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'جميع البيانات تحفظ محليًا على الجهاز.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
