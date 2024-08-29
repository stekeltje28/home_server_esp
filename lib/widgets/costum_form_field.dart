import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String hintText;
  final double height;
  final RegExp validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;

  const CustomFormField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validationRegEx,
    required this.onSaved,
    this.obscureText = false,
  });

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscureText;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: TextFormField(
        onSaved: widget.onSaved,
        obscureText: _obscureText,
        validator: (value) {
          if (value != null && widget.validationRegEx.hasMatch(value)) {
            setState(() {
              _hasError = false;
            });
            return null;
          } else {
            setState(() {
              _hasError = true;
            });
            if (MediaQuery.of(context).size.height >= 620) {
              return "Voer een geldig ${widget.hintText.toLowerCase()} in";
            }
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[600], ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: _hasError ? Colors.red : Colors.blueAccent,
              width: 2.0,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20.0),
          suffixIcon: widget.obscureText
              ? Padding(
            padding: const EdgeInsets.only(right: 10.0), // Voeg padding toe aan de rechterkant
            child: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.blueAccent,
      ),
    );
  }
}
