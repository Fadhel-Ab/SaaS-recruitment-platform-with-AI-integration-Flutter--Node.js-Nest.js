import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/applications/bloc/application_bloc.dart';
import 'package:frontend/features/applications/bloc/application_event.dart';
import 'package:frontend/features/applications/bloc/application_state.dart';
import 'package:frontend/features/applications/model/create_application_request.dart';
import 'package:frontend/features/jobs/models/job_model.dart';
import 'package:frontend/widgets/status_dialog.dart';

class ApplicationScreen extends StatefulWidget {
  final String shareToken;

  const ApplicationScreen({super.key, required this.shareToken});
  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? filePath;
  String? fileName;
  Uint8List? fileBytes;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state.status == ApplicationStatus.success &&
            state.fileName != null) {
          final request = CreateApplicationRequest(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            resumeFileName: state.fileName!,
          );
          print('Upload successful: ${state.fileName}');
          print('Upload successful??????/: ${state.fileName}');
          context.read<ApplicationBloc>().add(
            SubmitApplicationRequested(widget.shareToken, request),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Apply')),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),

              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: pickCv,

                icon: const Icon(Icons.upload_file),

                label: Text(fileName ?? 'Select CV'),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,

                child: FilledButton(
                  onPressed: () {
                    if (fileName == null) {
                      StatusDialog.show(
                        context: context,
                        isSuccess: false,
                        title: 'No File uploaded',
                        message: 'Please add a file',
                      );

                      return;
                    }

                    context.read<ApplicationBloc>().add(
                      UploadCvRequested(
                        bytes: fileBytes,
                        path: filePath,
                        fileName: fileName!,
                      ),
                    );
                    print('works ? $fileName ');
                  },
                  child: const Text('Submit Application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
