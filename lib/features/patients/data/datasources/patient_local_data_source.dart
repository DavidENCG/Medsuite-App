import 'package:hive/hive.dart';
import '../models/patient_model.dart';

abstract class PatientLocalDataSource {
  Future<void> cachePatients(List<PatientModel> patients);
  Future<List<PatientModel>> getCachedPatients();
}

class PatientLocalDataSourceImpl implements PatientLocalDataSource {
  static const String _boxName = 'patients_box';

  @override
  Future<void> cachePatients(List<PatientModel> patients) async {
    final box = await Hive.openBox(_boxName);
    final data = patients.map((e) => e.toJson()).toList();
    await box.put('my_patients', data);
  }

  @override
  Future<List<PatientModel>> getCachedPatients() async {
    final box = await Hive.openBox(_boxName);
    final List? data = box.get('my_patients');
    if (data != null) {
      return data.map((e) => PatientModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }
}
