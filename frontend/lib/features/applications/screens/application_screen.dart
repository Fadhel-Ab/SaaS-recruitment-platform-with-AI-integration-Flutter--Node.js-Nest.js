import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/api/error_message.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/bloc/auth_state.dart';
import 'package:frontend/features/auth/data/models/user_role.dart';
import 'package:frontend/features/applications/bloc/application_bloc.dart';
import 'package:frontend/features/applications/bloc/application_event.dart';
import 'package:frontend/features/applications/bloc/application_state.dart';
import 'package:frontend/features/applications/data/application_repository.dart';
import 'package:frontend/features/applications/model/create_application_request.dart';
import 'package:frontend/features/applications/widgets/ai_call_waiting_overlay.dart';
import 'package:frontend/features/applications/widgets/form_label.dart';
import 'package:frontend/features/applications/widgets/resume_upload_zone.dart';
import 'package:frontend/widgets/status_dialog.dart';

class ApplicationScreen extends StatefulWidget {
  final String shareToken;

  const ApplicationScreen({super.key, required this.shareToken});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  String? filePath;
  String? fileName;
  Uint8List? fileBytes;

  bool _showAiCallingInterface = false;
  double _aiScore = 0.0;
  double _aiThreshold = 0.0;
  String? _applicationId;
  bool _isRequestingCall = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickCv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        fileName = file.name;
        fileBytes = file.bytes;
        filePath = file.path;
      });
    }
  }

  void _clearCv() {
    setState(() {
      fileName = null;
      fileBytes = null;
      filePath = null;
    });
  }

  void _submitForm() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user?.role == UserRole.manager) {
      StatusDialog.show(
        context: context,
        isSuccess: false,
        title: 'Managers Cannot Apply',
        message: 'Please sign in with a candidate account before applying.',
      );
      return;
    }

    // 1. Structural Form Validation
    if (!_formKey.currentState!.validate()) return;

    // 2. Resume Attachment Check
    if (fileName == null) {
      StatusDialog.show(
        context: context,
        isSuccess: false,
        title: 'Resume Required',
        message: 'Please upload your CV/Resume file to proceed.',
      );
      return;
    }

    // 3. Dispatch file streaming request to your Bloc layer
    context.read<ApplicationBloc>().add(
      UploadCvRequested(bytes: fileBytes, path: filePath, fileName: fileName!),
    );
  }

  Future<void> _requestCall() async {
    final applicationId = _applicationId;
    if (applicationId == null || _isRequestingCall) return;

    setState(() => _isRequestingCall = true);
    try {
      await context.read<ApplicationRepository>().startAiCall(applicationId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Calling you now — please answer!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start the call: ${friendlyErrorMessage(e)}')),
      );
    } finally {
      if (mounted) setState(() => _isRequestingCall = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state.status == ApplicationStatus.success &&
            state.fileName != null &&
            state.result == null) {
          final request = CreateApplicationRequest(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            phone: '+973${phoneController.text.trim()}',
            resumeFileName: state.fileName!,
          );

          context.read<ApplicationBloc>().add(
            SubmitApplicationRequested(widget.shareToken, request),
          );
        }

        final result = state.result;
        if (state.status == ApplicationStatus.success &&
            result != null &&
            result.shouldStartAiCall &&
            result.aiScore != null) {
          setState(() {
            _aiScore = result.aiScore!;
            _aiThreshold = result.threshold;
            _applicationId = result.applicationId;
            _showAiCallingInterface = true;
          });
        }

        if (state.status == ApplicationStatus.failure) {
          StatusDialog.show(
            context: context,
            isSuccess: false,
            title: 'Submission Failed',
            message: state.error ?? 'Something went wrong. Please try again.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE), // Theme background match
        appBar: AppBar(
          title: const Text('Submit Application'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
        ),
        body: _showAiCallingInterface
            ? Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AiCallWaitingOverlay(
                      score: _aiScore,
                      threshold: _aiThreshold,
                      isRequestingCall: _isRequestingCall,
                      onStartCall: _requestCall,
                    ),
                  ),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 👇 REPLACE THE STATIC TEXT WIDGETS WITH THIS BLOCBUILDER
                              BlocBuilder<ApplicationBloc, ApplicationState>(
                                builder: (context, state) {
                                  final jobTitle =
                                      state.job?.title ?? 'this role';
                                  final companyName = state.job?.company != null
                                      ? ' at ${state.job!.company}'
                                      : '';

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Apply for $jobTitle$companyName',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const Text(
                                        'Please complete all fields carefully.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              const FormLabel(label: 'Full Name'),
                              TextFormField(
                                controller: fullNameController,
                                decoration: const InputDecoration(
                                  hintText: 'John Doe',
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Please enter your name'
                                    : null,
                              ),

                              const FormLabel(label: 'Email Address'),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'john@example.com',
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                    ? 'Please provide a valid email'
                                    : null,
                              ),

                              const FormLabel(label: 'Phone Number'),
                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(8),
                                ],
                                decoration: InputDecoration(
                                  hintText: '3XXX XXXX',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          '🇧🇭',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '+973',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                ),
                                validator: (v) {
                                  final digits = (v ?? '').trim();
                                  if (digits.isEmpty) {
                                    return 'Phone number is mandatory';
                                  }
                                  if (digits.length != 8) {
                                    return 'Enter a valid 8-digit Bahrain phone number';
                                  }
                                  return null;
                                },
                              ),

                              const FormLabel(label: 'Curriculum Vitae (CV)'),
                              ResumeUploadZone(
                                fileName: fileName,
                                onPickFile: pickCv,
                                onClearFile: _clearCv,
                              ),

                              const SizedBox(height: 32),
                              BlocBuilder<ApplicationBloc, ApplicationState>(
                                builder: (context, state) {
                                  final isSubmitting =
                                      state.status ==
                                          ApplicationStatus.uploading ||
                                      state.status ==
                                          ApplicationStatus.submitting;

                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4F46E5,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: isSubmitting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Submit Application',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                    ),
                                  );
                                },
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
    );
  }
}
