class Patient {
  String name;
  int? age;
  String? gender;
  String? bloodType;
  bool hasChronic;
  List<String> chronicDiseases;
  String? notes;
  String? ecg;
  String? bloodPressure;
  String? spo2;
  String? respiratoryRate;
  String? heartRate;
  String? temperature;
  Patient({
    this.name = '',
    this.age,
    this.gender,
    this.bloodType,
    this.hasChronic = false,
    List<String>? chronicDiseases,
    this.notes,
    this.ecg,
    this.bloodPressure,
    this.spo2,
    this.respiratoryRate,
    this.heartRate,
    this.temperature,
  }) : chronicDiseases = chronicDiseases ?? [];
}
