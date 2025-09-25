import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/integrated_api_service.dart';

class PatientViewModel extends ChangeNotifier {
  Patient _patient = Patient();
  final IntegratedApiService _api = IntegratedApiService();

  Patient get patient => _patient;

  // --- Basic Updates ---
  void updateName(String name) {
    _patient.name = name.trim();
    notifyListeners();
  }

  void updateAge(String ageStr) {
    _patient.age = int.tryParse(ageStr) ?? 0;
    notifyListeners();
  }

  void updateBloodType(String? blood) {
    _patient.bloodType = blood ?? "";
    notifyListeners();
  }

  void updateEcgSignal(List<double> ecg) {
    _patient.ecgSignalList = ecg;
    notifyListeners();
  }

  void updateGender(String? gender) {
    _patient.gender = gender ?? "";
    notifyListeners();
  }

  void updateHasChronic(bool has) {
    _patient.hasChronic = has;
    notifyListeners();
  }

  void addChronicDisease(String disease) {
    final d = disease.trim();
    if (d.isEmpty) return;
    if (!_patient.chronicDiseases.contains(d)) {
      _patient.chronicDiseases.add(d);
      notifyListeners();
    }
  }

  void removeChronicDisease(String disease) {
    _patient.chronicDiseases.remove(disease.trim());
    notifyListeners();
  }

  void updateNotes(String notes) {
    _patient.notes = notes.trim();
    notifyListeners();
  }

  // --- Vitals Updates ---
  void updateReading(String key, String? value) {
    final v = value?.trim();
    switch (key) {
      case 'ecg':
        _patient.ecg = v;
        break;
      case 'bp':
        _patient.bloodPressure = v;
        break;
      case 'spo2':
        _patient.spo2 = v;
        break;
      case 'hr':
        _patient.heartRate = v;
        break;
      case 'rr':
        _patient.respiratoryRate = v;
        break;
      case 'temp':
        _patient.temperature = v;
        break;
    }
    notifyListeners();
  }

  // --- Utils ---
  void save() {
    debugPrint("✅ Patient saved locally: ${_patient.name}");
    notifyListeners();
  }

  void reset() {
    _patient = Patient();
    notifyListeners();
  }

  // --- Send to API ---
  Map<String, dynamic> _removeNulls(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};

    data.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is Map<String, dynamic>) {
        final nested = _removeNulls(value);
        if (nested.isNotEmpty) cleaned[key] = nested;
      } else {
        cleaned[key] = value;
      }
    });

    return cleaned;
  }

  Future<Map<String, dynamic>> sendToApi() async {
    try {
      int? systolic, diastolic;
      if ((_patient.bloodPressure ?? "").contains("/")) {
        final parts = _patient.bloodPressure!.split("/");
        systolic = int.tryParse(parts.isNotEmpty ? parts[0] : "0");
        diastolic = int.tryParse(parts.length > 1 ? parts[1] : "0");
      }

      final ecgList = _patient.ecgSignalList ??
          (_patient.ecg
              ?.split(',')
              .map((e) => double.tryParse(e.trim()) ?? 0.0)
              .toList() ??
              []);

      final body = {
        "patient_id": _patient.name.isNotEmpty ? _patient.name : "unknown",
        "name": _patient.name,
        "age": _patient.age,
        "gender": _patient.gender,
        "chronic_conditions": _patient.chronicDiseases,
        "notes": _patient.notes,
        "ecg_signal": ecgList.isNotEmpty ? ecgList : null, // ✅ مش فاضي بس
        "vitals": {
          "spo2": _patient.spo2 != null
              ? {"value": int.tryParse(_patient.spo2!), "unit": "%"}
              : null,
          "bp": (systolic != null && diastolic != null)
              ? {"systolic": systolic, "diastolic": diastolic, "unit": "mmHg"}
              : null,
          "hr": _patient.heartRate != null
              ? {"value": int.tryParse(_patient.heartRate!), "unit": "bpm"}
              : null,
          "temp": _patient.temperature != null
              ? {"value": double.tryParse(_patient.temperature!), "unit": "C"}
              : null,
          "respiratory_rate": _patient.respiratoryRate != null
              ? {"value": int.tryParse(_patient.respiratoryRate!), "unit": "breaths/min"}
              : null,
        }
      };

      final cleanBody = _removeNulls(body); // ✅ فلترة قبل الإرسال

      final response = await _api.analyzePatient(cleanBody);
      debugPrint("🎯 Response from API: $response");
      return response;
    } catch (e, s) {
      debugPrint("❌ Error sending to API: $e\n$s");
      return {"error": e.toString()};
    }
  }



}
