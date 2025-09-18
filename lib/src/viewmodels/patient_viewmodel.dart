import 'package:flutter/foundation.dart';
import '../models/patient.dart';

class PatientViewModel extends ChangeNotifier {
  final Patient _patient = Patient();

  Patient get patient => _patient;

  void updateName(String name) {
    _patient.name = name;
    notifyListeners();
  }

  void updateAge(String ageStr) {
    final n = int.tryParse(ageStr);
    _patient.age = n;
    notifyListeners();
  }

  void updateBloodType(String? blood) {
    _patient.bloodType = blood;
    notifyListeners();
  }

  void updateGender(String? gender) {
    _patient.gender = gender;
    notifyListeners();
  }

  void updateHasChronic(bool has) {
    _patient.hasChronic = has;
    notifyListeners();
  }

  void addChronicDisease(String disease) {
    if (disease.trim().isEmpty) return;
    _patient.chronicDiseases.add(disease.trim());
    notifyListeners();
  }

  void removeChronicDisease(String disease) {
    _patient.chronicDiseases.remove(disease);
    notifyListeners();
  }

  void updateNotes(String notes) {
    _patient.notes = notes;
    notifyListeners();
  }

  void updateReading(String key, String? value) {
    switch (key) {
      case 'ecg':
        _patient.ecg = value;
        break;
      case 'bp':
        _patient.bloodPressure = value;
        break;
      case 'spo2':
        _patient.spo2 = value;
        break;
      case 'hr':
        _patient.heartRate = value;
        break;
      case 'rr':
        _patient.respiratoryRate = value;
        break;
      case 'temp':
        _patient.temperature = value;
        break;
    }
    notifyListeners();
  }

  void save() {
    // No backend — for demo we just keep the data in-memory.
    notifyListeners();
  }
}
