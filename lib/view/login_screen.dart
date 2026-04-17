import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../res/widgets/gif_loader.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../viewModel/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    /// ❌ Do NOT load customerId
    _customerIdController.clear(); // ✅ ADD HERE

    // _customerIdController.text =
    //     prefs.getString('lastCustomerId') ?? '';

    _usernameController.text =
        prefs.getString('lastUsername') ?? '';

    _passwordController.text =
        prefs.getString('lastPassword') ?? '';
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final customerId = _customerIdController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final loginVM = Provider.of<LoginViewModel>(context, listen: false);

      loginVM.loginApi(
        username,
        password,
        customerId,
        context,
        rememberMe: _rememberMe, // ✅ ADD THIS
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = Provider.of<LoginViewModel>(context);

    return Theme(
        data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        floatingLabelStyle: TextStyle(color: primary),
      ),
    ),
    child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// 🌈 GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF554CCD), // primary
                  Color(0xFF7B73F0), // lighter shade
                  Color(0xFFF3F2FF), // very light background tint
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// Logo
                            Image.asset(
                              "assets/images/soulconnect_logo.png",
                              height: 100,
                            ),

                            const SizedBox(height: 16),

                            /// Title
                            const Text(
                              Strings.welcome,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              Strings.loginSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),

                            const SizedBox(height: 24),

                            /// Customer ID
                            TextFormField(
                              controller: _customerIdController,
                              decoration: InputDecoration(
                                labelText: Strings.customerId,
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? Strings.enterCustomerId
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            /// Username
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: Strings.username,
                                suffixIcon: const Icon(
                                    Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? Strings.enterUsername
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            /// Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: Strings.password,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                      !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? Strings.enterPassword
                                  : null,
                            ),

                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text("Remember Me"),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// SIGN IN BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: InkWell(
                                onTap: () => _handleLogin(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: buttonGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      Strings.signIn,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// Footer
                            const Text(
                              Strings.copyright,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🔄 LOADER OVERLAY
          if (loginVM.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: GifLoader(),
              ),
            ),
        ],
      ),
     ),
    );
  }
}