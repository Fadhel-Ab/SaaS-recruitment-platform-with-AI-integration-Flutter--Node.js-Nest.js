import 'dart:typed_data';

import 'package:frontend/features/applications/model/create_application_request.dart';

abstract class ApplicationEvent {}

class UploadCvRequested extends ApplicationEvent {
  final String? path;
  final Uint8List? bytes;
  final String fileName;

  UploadCvRequested({this.path, this.bytes, required this.fileName});
}

class SubmitApplicationRequested extends ApplicationEvent {
  final String shareToken;
  final CreateApplicationRequest request;

  SubmitApplicationRequested(this.shareToken, this.request);
}
