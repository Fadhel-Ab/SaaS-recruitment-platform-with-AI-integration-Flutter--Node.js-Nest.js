import 'package:flutter/material.dart';

class ResumeUploadZone extends StatelessWidget {
  final String? fileName;
  final VoidCallback onPickFile;
  final VoidCallback onClearFile;

  const ResumeUploadZone({
    super.key,
    required this.fileName,
    required this.onPickFile,
    required this.onClearFile,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasFile = fileName != null;

    return InkWell(
      onTap: hasFile ? null : onPickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFE6F4EA) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF137333) : const Color(0xFFE5E7EB),
            style: hasFile ? BorderStyle.solid : BorderStyle.solid, // Use custom painters if dashed lines are preferred
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
              size: 36,
              color: hasFile ? const Color(0xFF137333) : const Color(0xFF4F46E5),
            ),
            const SizedBox(height: 12),
            if (!hasFile) ...[
              const Text(
                'Upload your resume/CV',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Supports PDF, DOC, DOCX up to 10MB',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ] else ...[
              Text(
                fileName!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF137333)),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onClearFile,
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Remove file', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
