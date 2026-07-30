import '../models/create_job_request.dart';


abstract class CreateJobEvent {}


class SubmitJobRequested extends CreateJobEvent {

  final CreateJobRequest request;


  SubmitJobRequested(this.request);

}