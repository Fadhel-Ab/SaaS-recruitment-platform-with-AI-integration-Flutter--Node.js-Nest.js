import 'package:frontend/features/dashboard/data/dashboard_api.dart';
import 'package:frontend/features/dashboard/data/model/dashboard_summary.dart';

class DashboardRepository {
  final DashboardApi api;

  DashboardRepository(this.api);

  Future<DashboardSummary> getSummary() async {
    final json = await api.getSummary();
    return DashboardSummary.fromJson(json);
  }
}
