import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FormLabel({super.key, required this.label, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827), // Neutral 900
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
