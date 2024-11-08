import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  final String hintText;
  final double? height;
  final RegExp? validationRegEx;
  final bool obscureText;
  final void Function(String?) onSaved;
  final int maxLines;
  final TextInputType keyboardType;
  final List<String>? suggestions;
  final String? info;

  const CustomFormField({
    super.key,
    required this.hintText,
    this.height,
    this.info,
    this.validationRegEx,
    required this.onSaved,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suggestions,
  });

  @override
  _CustomFormFieldState createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  late bool _obscureText;
  final bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? (widget.maxLines > 1 ? null : 60.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (widget.suggestions != null && textEditingValue.text.isNotEmpty) {
            return widget.suggestions!.where((suggestion) {
              return suggestion.toLowerCase().contains(textEditingValue.text.toLowerCase());
            }).toList();
          }
          return const Iterable<String>.empty(); // Lege lijst als er geen suggesties zijn
        },
        onSelected: (String selection) {
          widget.onSaved(selection);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (value) {
              onFieldSubmitted();
            },
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
                  color: _hasError ? Colors.red : Colors.blueAccent,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Aangepaste padding
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
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Color(0xFF3C3F44),
              elevation: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.735,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // Border-radius gelijk aan TextFormField
                  border: Border.all(
                    color: Colors.blueAccent, // Borderkleur van de suggesties
                    width: 2.0,
                  ),
                ),
                constraints: BoxConstraints(
                  maxHeight: 250.0, // Maximale hoogte voor scrollen
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);

                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[600]!, width: 0.5),
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white, // Zelfde tekstkleur als TextFormField
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
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
