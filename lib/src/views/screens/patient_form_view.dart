import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/patient_viewmodel.dart';
import '../../widgets/custom_action_button.dart';
import '../../widgets/small_fields.dart';

class PatientFormView extends StatefulWidget {
  const PatientFormView({super.key});

  @override
  State<PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<PatientFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _chronicCtrl =
      TextEditingController(); // used as input to add one disease
  final _notesCtrl = TextEditingController();
  final _ecgCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  @override    
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _chronicCtrl.dispose();
    _notesCtrl.dispose();
    _ecgCtrl.dispose();
    _bpCtrl.dispose();
    _spo2Ctrl.dispose();
    _hrCtrl.dispose();
    _rrCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PatientViewModel>(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Information'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 900 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _ageCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Age is required';
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 0)
                                return 'Enter a valid age';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                const ['Male', 'Female', 'Other']
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            value: _selectedGender ?? vm.patient.gender,
                            onChanged:
                                (v) => setState(() => _selectedGender = v),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Gender is required'
                                        : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Blood Type (optional)',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                const [
                                      "A+",
                                      "A-",
                                      "B+",
                                      "B-",
                                      "AB+",
                                      "AB-",
                                      "O+",
                                      "O-",
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            value:
                                vm
                                    .patient
                                    .bloodType, // ✅ ده اللي يحدد القيمة المبدئية
                            onChanged: (v) => vm.updateBloodType(v),
                            // blood type optional now: no validator
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Has chronic diseases'),
                      value: vm.patient.hasChronic,
                      onChanged: (v) => vm.updateHasChronic(v),
                    ),
                    if (vm.patient.hasChronic) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chronicCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Add a chronic disease',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (v) {
                                if (v.trim().isEmpty) return;
                                vm.addChronicDisease(v.trim());
                                _chronicCtrl.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final v = _chronicCtrl.text.trim();
                              if (v.isEmpty) return;
                              vm.addChronicDisease(v);
                              _chronicCtrl.clear();
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            vm.patient.chronicDiseases
                                .map(
                                  (d) => Chip(
                                    label: Text(d),
                                    onDeleted: () => vm.removeChronicDisease(d),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Medical Readings (optional)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'ECG',
                                controller: _ecgCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'Blood Pressure',
                                controller: _bpCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'SpO₂',
                                controller: _spo2Ctrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'Heart Rate (bpm)',
                                controller: _hrCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'Respiratory Rate',
                                controller: _rrCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SmallFieldFlexible(
                                label: 'Temperature',
                                controller: _tempCtrl,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Left column: Random (icon) above Analyze
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomActionButton(
                                label: 'Random',
                                icon: Icons.shuffle,
                                bgColor: Colors.blue.shade50,
                                tooltip: 'Random',
                                iconOnly: true,
                                onPressed: () => _fillRandom(vm),
                              ),
                              const SizedBox(height: 8),
                              CustomActionButton(
                                label: 'Analyze',
                                icon: Icons.analytics,
                                bgColor: Colors.green.shade50,
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  final result = await vm.sendToApi();
                                  _showAnalysisDialog(context, result);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right column: Save above Open Chat
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomActionButton(
                                label: 'Save',
                                icon: Icons.save,
                                bgColor: Colors.yellow.shade50,
                                onPressed: () {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  vm.updateName(_nameCtrl.text.trim());
                                  vm.updateAge(_ageCtrl.text.trim());
                                  vm.updateGender(
                                    _selectedGender ?? vm.patient.gender,
                                  );
                                  vm.updateNotes(_notesCtrl.text.trim());
                                  vm.updateReading('ecg', _ecgCtrl.text.trim());
                                  vm.updateReading('bp', _bpCtrl.text.trim());
                                  vm.updateReading('hr', _hrCtrl.text.trim());
                                  vm.updateReading(
                                    'spo2',
                                    _spo2Ctrl.text.trim(),
                                  );
                                  vm.updateReading('rr', _rrCtrl.text.trim());
                                  vm.updateReading(
                                    'temp',
                                    _tempCtrl.text.trim(),
                                  );
                                  vm.save();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Saved patient: ${vm.patient.name}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              CustomActionButton(
                                label: 'Open Chat',
                                icon: Icons.chat,
                                bgColor: Colors.purple.shade50,
                                onPressed:
                                    () => Navigator.pushNamed(context, '/chat'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // small field widgets extracted to ../../widgets/small_fields.dart

  // Returns a ButtonStyle that visually matches an outlined TextField with a soft background color
  ButtonStyle _outlinedButtonStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: Colors.black87,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  void _fillRandom(PatientViewModel vm) {
    // Minimal random generator
    final rnd = DateTime.now().millisecondsSinceEpoch % 1000;
    final names = ['Alex', 'Sara', 'Omar', 'Lina', 'John', 'Maya'];
    final genders = ['Male', 'Female', 'Other'];
    final bloods = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    final name = names[rnd % names.length];
    final age = 20 + (rnd % 60);
    final gender = genders[rnd % genders.length];
    final blood = bloods[rnd % bloods.length];
    final ecg = '${60 + (rnd % 40)}';
    final bp = '${100 + (rnd % 40)}/${60 + (rnd % 30)}';
    final hr = '${60 + (rnd % 60)}';
    final spo2 = '${95 + (rnd % 5)}';
    final rr = '${12 + (rnd % 10)}';
    final temp = '${36 + (rnd % 4)}.${rnd % 10}';

    // Fill controllers
    setState(() {
      _nameCtrl.text = name;
      _ageCtrl.text = age.toString();
      _selectedGender = gender;
      // blood type optional — set it
      // update vm directly for chronic list
      _ecgCtrl.text = ecg;
      _bpCtrl.text = bp;
      _hrCtrl.text = hr;
      _spo2Ctrl.text = spo2;
      _rrCtrl.text = rr;
      _tempCtrl.text = temp;
      _notesCtrl.text = 'Randomly generated patient';
    });

    vm.updateName(_nameCtrl.text.trim());
    vm.updateAge(_ageCtrl.text.trim());
    vm.updateGender(_selectedGender);
    vm.updateBloodType(blood);
    vm.updateReading('ecg', _ecgCtrl.text.trim());
    vm.updateReading('bp', _bpCtrl.text.trim());
    vm.updateReading('hr', _hrCtrl.text.trim());
    vm.updateReading('spo2', _spo2Ctrl.text.trim());
    vm.updateReading('rr', _rrCtrl.text.trim());
    // Ensure the 'hasChronic' flag is true so the UI shows the chronic chips
    if (!vm.patient.hasChronic) vm.updateHasChronic(true);
    vm.addChronicDisease('Hypertension');
    if (rnd % 2 == 0) vm.addChronicDisease('Diabetes');
  }

  void _showAnalysisDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (ctx) {
        final patientData = result.values.first; // يجيب أول patient object
        final lastAnalysis = patientData['last_analysis'] ?? {};

        final combined = lastAnalysis['combined_assessment'] ?? {};
        final recsRaw = lastAnalysis['unified_recommendations'];

        // unified_recommendations ممكن تكون List أو حاجة تانية
        final List<String> recs =
            (recsRaw is List) ? recsRaw.map((e) => e.toString()).toList() : [];

        return AlertDialog(
          title: const Text("🔎 Analysis Results"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(
                    "Risk Level: ${combined['combined_risk_level'] ?? 'N/A'}",
                  ),
                  subtitle: Text(
                    "Alert Color: ${combined['alert_color'] ?? 'N/A'}",
                  ),
                ),
                const Divider(),
                const Text(
                  "Recommendations:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (recs.isEmpty) const Text("No recommendations available"),
                ...recs.map((rec) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(rec),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
