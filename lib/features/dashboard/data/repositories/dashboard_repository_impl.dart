import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  DashboardRepositoryImpl({required DashboardDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<DashboardSummary> getSummary() async {
    return await _dataSource.getSummary();
  }
}
