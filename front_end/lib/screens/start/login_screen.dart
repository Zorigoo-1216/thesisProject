import 'package:flutter/material.dart';
import '../../constant/styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 88,
                    height: 89,
                    child: Image.asset('assets/images/group-12.png'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Хөдөлмөр зуучлал',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: AppFonts.logoFont,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  /// 📩 Email or Phone
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Утасны дугаар эсвэл и-мэйл хаяг',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF424955),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _emailOrPhoneController,
                    decoration: InputDecoration(
                      hintText: 'Утасны дугаар эсвэл и-мэйл хаягаа оруулна уу',
                      prefixIcon: const Icon(Icons.mail, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Утас эсвэл и-мэйл оруулна уу';
                      }

                      final input = value.trim();

                      final isEmail = RegExp(r'[A-Za-z]').hasMatch(input);
                      if (isEmail) {
                        if (!input.contains('@')) {
                          return 'Зөв и-мэйл хаяг оруулна уу';
                        }
                      } else {
                        if (!RegExp(r'^[6-9][0-9]{7}$').hasMatch(input)) {
                          return '8 оронтой, 6-9-өөр эхэлсэн дугаар оруулна уу';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  /// 🔐 Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Нууц үг',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF424955),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Нууц үг ээ оруулна уу',
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      suffixIcon: const Icon(
                        Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Нууц үг дор хаяж 6 тэмдэгт байх ёстой';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Нууц үг ээ мартсан уу?',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  /// ✅ Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary, // 🎨 цэнхэр background
                        foregroundColor: AppColors.white, // 📝 цагаан текст
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius,
                          ),
                        ),
                      ),
                      onPressed: _submitLogin,
                      child: const Text("Нэвтрэх"),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Шинээр бүртгүүлэх үү?',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
