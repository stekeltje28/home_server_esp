import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String hintText;
  final double? height;
  final RegExp? validationRegEx;
  final bool obscureText;
  final void Function(String?) onsave;
  final int maxLines;
  final TextInputType keyboardType;
  final List<String>? suggestions;
  final String? info;
  final TextEditingController? controller;

  const CustomFormField({
    super.key,
    required this.hintText,
    this.height,
    this.info,
    this.validationRegEx,
    required this.onsave,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suggestions,
    this.controller,
  });

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? (widget.maxLines > 1 ? null : 60.0),
      child: TextFormField(
        controller: widget.controller,  // Always use the controller passed by the parent
        obscureText: _obscureText,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.blueAccent,
              width: 2.0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          suffixIcon: widget.info != null
              ? IconButton(
            icon: const Icon(Icons.info, color: Colors.grey),
            onPressed: () {
              _showInfoDialog(context, widget.info!);
            },
          )
              : null,
        ),
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.blueAccent,
        validator: (value) {
          if (widget.validationRegEx != null && value != null) {
            if (!widget.validationRegEx!.hasMatch(value)) {
              return 'Invalid input';
            }
          }
          return null;
        },
        onSaved: widget.onsave,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String info) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Info:"),
          content: Text(info),
          actions: [
            TextButton(
              child: const Text("Sluiten"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
