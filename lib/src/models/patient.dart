class Patient {
  String? id; // لازم لو عايز تستعمله في API أو الداتا بيز
  String name;
  int? age;
  String? bloodType;
  String? gender;
  bool hasChronic;
  String? chronicDetails;
  List<String> chronicDiseases;
  final List<String> chronicConditions;
  final Map<String, dynamic> vitals;
  final List<double> ecgSignal;
  final Map<String, dynamic>? lastAnalysis;
  String? notes;

  // Optional readings
  String? ecg;
  String? bloodPressure;
  String? spo2;
  String? respiratoryRate;
  String? heartRate;
  String? temperature;
  List<double>? ecgSignalList;

  // لو محتاج ضغط الدم كسستوليك و دايستوليك
  int? bpSystolic;
  int? bpDiastolic;

  Patient({
    this.id,
    this.name = '',
    this.age,
    this.bloodType,
    this.gender,
    this.hasChronic = false,
    this.chronicDetails,
    List<String> chronicDiseases = const [],
    this.notes,
    this.ecg,
    this.bloodPressure,
    this.spo2,
    this.respiratoryRate,
    this.heartRate,
    this.temperature,
    this.bpSystolic,
    this.bpDiastolic,
    this.ecgSignalList,
    this.lastAnalysis,
    this.chronicConditions = const [],
    this.vitals = const {},
    this.ecgSignal = const [],
  }) : chronicDiseases = List<String>.from(chronicDiseases);

  // Ensure chronicDiseases is a mutable list even if default const [] was passed
  // (constructor body runs after initializers).
  // If the parameter was the const empty list, make a new mutable copy.
  // We do this in a redirecting factory to keep the class simple.

  factory Patient.withMutableLists({
    String? id,
    String name = '',
    int? age,
    String? bloodType,
    String? gender,
    bool hasChronic = false,
    String? chronicDetails,
    List<String> chronicDiseases = const [],
    String? notes,
    String? ecg,
    String? bloodPressure,
    String? spo2,
    String? respiratoryRate,
    String? heartRate,
    String? temperature,
    int? bpSystolic,
    int? bpDiastolic,
    List<double>? ecgSignalList,
    Map<String, dynamic>? lastAnalysis,
    List<String> chronicConditions = const [],
    Map<String, dynamic> vitals = const {},
    List<double> ecgSignal = const [],
  }) {
    final p = Patient(
      id: id,
      name: name,
      age: age,
      bloodType: bloodType,
      gender: gender,
      hasChronic: hasChronic,
      chronicDetails: chronicDetails,
      chronicDiseases: List<String>.from(chronicDiseases),
      notes: notes,
      ecg: ecg,
      bloodPressure: bloodPressure,
      spo2: spo2,
      respiratoryRate: respiratoryRate,
      heartRate: heartRate,
      temperature: temperature,
      bpSystolic: bpSystolic,
      bpDiastolic: bpDiastolic,
      ecgSignalList: ecgSignalList,
      lastAnalysis: lastAnalysis,
      chronicConditions: List<String>.from(chronicConditions),
      vitals: Map<String, dynamic>.from(vitals),
      ecgSignal: List<double>.from(ecgSignal),
    );
    return p;
  }

  Map<String, dynamic> toJson() {
    return {
      "patient_id": id,
      "name": name,
      "age": age,
      "gender": gender,
      "chronic_conditions": chronicConditions,
      "notes": notes,
      "vitals": vitals,
      "ecg_signal": ecgSignal,
      "last_analysis": lastAnalysis,
    };
  }
}
