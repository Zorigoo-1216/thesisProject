import 'package:flutter/material.dart';
import '../../constant/styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool agree = false;
  String? gender;
  late TabController _tabController;

  final Map<String, TextEditingController> controllers = {
    'lastName': TextEditingController(),
    'firstName': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'companyName': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? getGenderValue(String? genderText) {
    switch (genderText) {
      case 'Эрэгтэй':
        return 'male';
      case 'Эмэгтэй':
        return 'female';
      case 'Бусад':
        return 'other';
      default:
        return null;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && agree) {
      final isIndividual = _tabController.index == 0;
      final body =
          isIndividual
              ? {
                'role': 'individual',
                'lastName': controllers['lastName']!.text.trim(),
                'firstName': controllers['firstName']!.text.trim(),
                'phone': controllers['phone']!.text.trim(),
                'password': controllers['password']!.text.trim(),
                'gender': getGenderValue(gender),
              }
              : {
                'role': 'company',
                'companyName': controllers['companyName']!.text.trim(),
                'representative': controllers['firstName']!.text.trim(),
                'email': controllers['email']!.text.trim(),
                'password': controllers['password']!.text.trim(),
              };

      try {
        final response = await http.post(
          Uri.parse('${baseUrl}auth/register'),

          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Бүртгэл амжилттай')));
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          final error = jsonDecode(response.body)['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Бүртгэл хийхэд алдаа гарлаа')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сервертэй холбогдож чадсангүй')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIndividual = _tabController.index == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Image.asset('assets/images/logo.png', width: 88, height: 88),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Хөдөлмөр зуучлал',
                  style: TextStyle(fontSize: 20, fontFamily: AppFonts.logoFont),
                ),
                const SizedBox(height: AppSpacing.md),

                /// 🧑‍💼 Tab Toggle
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.subtitle,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  onTap: (_) => setState(() {}),
                  tabs: const [Tab(text: 'Хувь хүн'), Tab(text: 'Компани')],
                ),
                const SizedBox(height: AppSpacing.md),

                /// 👤 Form Fields
                if (isIndividual) ...[
                  _formField(
                    'Овог',
                    'lastName',
                    'Өөрийн овгийг оруулна уу',
                    isCyrillic: true,
                  ),
                  _formField(
                    'Нэр',
                    'firstName',
                    'Өөрийн нэрийг оруулна уу',
                    isCyrillic: true,
                  ),
                  _formField(
                    'Утасны дугаар',
                    'phone',
                    'Утасны дугаараа оруулна уу',
                    isPhone: true,
                  ),
                  _formField(
                    'Нууц үг',
                    'password',
                    '8-с дээш тэмдэгт',
                    obscure: true,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: _dropdownStyle('Хүйс'),
                    value: gender,
                    onChanged: (val) => setState(() => gender = val),
                    items:
                        ['Эрэгтэй', 'Эмэгтэй', 'Бусад']
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                    validator:
                        (val) => val == null ? 'Хүйсээ сонгоно уу' : null,
                  ),
                ] else ...[
                  _formField(
                    'Компаны нэр',
                    'companyName',
                    'Компаны нэрийг оруулна уу',
                  ),
                  _formField('Төлөөлөгчийн нэр', 'firstName', 'Нэр'),
                  _formField('Email', 'email', 'example@email.com'),
                  _formField(
                    'Нууц үг',
                    'password',
                    '8-с дээш тэмдэгт',
                    obscure: true,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),

                /// ✅ Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: agree,
                      onChanged: (val) => setState(() => agree = val ?? false),
                      activeColor: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text('I agree with Terms & Conditions'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                /// 📩 Register Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: agree ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary, // Set background color
                      foregroundColor: Colors.white, // Set text color
                    ),
                    child: const Text("Бүртгүүлэх"),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                /// ➖ Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("эсвэл"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                /// 🔁 Login Navigation
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    "Нэвтрэх",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔤 Form Field
  Widget _formField(
    String label,
    String key,
    String hint, {
    bool obscure = false,
    bool isCyrillic = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controllers[key],
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return '$label оруулна уу';

              if (isCyrillic && !RegExp(r"^[А-Яа-яӨөҮүЁё\s]+$").hasMatch(val)) {
                return '$label зөвхөн кирилл үсгээр байна';
              }

              if (isPhone && !RegExp(r'^[6-9][0-9]{7}$').hasMatch(val.trim())) {
                return '8 оронтой, 6-9-өөр эхэлсэн дугаар оруулна уу';
              }

              if (key == 'email' &&
                  !RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  ).hasMatch(val.trim())) {
                return 'Зөв и-мэйл хаяг оруулна уу';
              }

              if (key == 'password' && val.length < 6) {
                return 'Нууц үг дор хаяж 6 тэмдэгт байх ёстой';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  /// ⬇ Dropdown style
  InputDecoration _dropdownStyle(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        borderSide: BorderSide.none,
      ),
    );
  }
}
