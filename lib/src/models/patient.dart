class Patient {
  String name;
  int? age;
  String? bloodType;
  bool hasChronic;
  String? chronicDetails;
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
    this.bloodType,
    this.hasChronic = false,
    this.chronicDetails,
    this.notes,
    this.ecg,
    this.bloodPressure,
    this.spo2,
    this.respiratoryRate,
    this.heartRate,
    this.temperature,
  });
}         
