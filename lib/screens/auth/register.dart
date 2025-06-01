import 'package:final_project_ppb/components/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void register() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateLogin();
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
          'Register',
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
                image: AssetImage('lib/assets/register.png'),
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
                onPressed: register,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 24.0,
                  ),
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
                          'Register',
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
                    'Already have an account?',
                    style: GoogleFonts.montserrat(),
                  ),
                  TextButton(
                    onPressed: navigateLogin,
                    child: Text(
                      'Login',
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
