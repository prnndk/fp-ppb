import 'package:final_project_ppb/components/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFEF7E4),
      ),
      backgroundColor: const Color(0xFFFEF7E4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),
              Image(
                image: AssetImage('lib/assets/logo.png'),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                exampleText: 'abecede@gmail.com',
                validator: (email) {
                  if (email == null || email.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                exampleText: 'keledaI12@',
                validator: (password) {
                  if (password == null || password.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (password.length < 6) {
                    return 'Password harus minimal 6 karakter';
                  }
                  return null;
                },
                isPassword: true,
              ),
              const SizedBox(height: 12),
              _errorCode != ""
                  ? Column(
                    children: [
                      Text(_errorCode, style: GoogleFonts.montserrat()),
                      const SizedBox(height: 24),
                    ],
                  )
                  : const SizedBox(height: 0),
              OutlinedButton(
                onPressed: signIn,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ), // Add padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                        : Text(
                          'Login',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum mempunyai akun?',
                    style: GoogleFonts.montserrat(),
                  ),
                  TextButton(
                    onPressed: navigateRegister,
                    child: Text(
                      'Register di sini',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF8B4513),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
