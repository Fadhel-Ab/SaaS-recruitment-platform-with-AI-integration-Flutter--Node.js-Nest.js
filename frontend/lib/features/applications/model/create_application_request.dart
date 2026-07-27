class CreateApplicationRequest {
  final String fullName;
  final String email;
  final String phone;
  final String resumeFileName;

  const CreateApplicationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.resumeFileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'resumeFileName': resumeFileName,
    };
  }
}
