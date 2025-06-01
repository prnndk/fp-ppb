import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String exampleText;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.exampleText,
    required this.controller,
    this.inputFormatters,
    this.keyboardType,
    required this.validator,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          obscureText: widget.isPassword ? _obscureText : false,
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                text: widget.labelText,
                style: TextStyle(
                  fontFamily: GoogleFonts.roboto().fontFamily,
                  fontSize: 16,
                  color: const Color(0xFF5E6368),
                ),
                children: const [
                  TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            floatingLabelStyle: TextStyle(
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontSize: 12,
              color: const Color(0xFF5E6368),
            ),
            hintText: 'Masukkan ${widget.labelText} Anda',
            hintStyle: TextStyle(
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontSize: 16,
              color: const Color(0xFF6C757D),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(color: Color(0xFF6B737A), width: 1),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF5E6368),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
            counterText: '',
          ),
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3, left: 12),
          child: Text(
            'Contoh ${widget.labelText}: ${widget.exampleText}',
            style: TextStyle(
              fontFamily: GoogleFonts.roboto().fontFamily,
              fontSize: 12,
              color: const Color(0xFF5E6368),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
