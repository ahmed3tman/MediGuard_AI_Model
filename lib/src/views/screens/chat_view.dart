import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/patient_viewmodel.dart';
import '../../widgets/voice_recorder.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  final _chronicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _ecgCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();

  String? _selectedGender;

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
                    // ====================
                    // BASIC INFO
                    // ====================
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
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
                              if (v == null || v.trim().isEmpty) {
                                return 'Age is required';
                              }
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 0) return 'Enter valid age';
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
                            items: const ['Male', 'Female', 'Other']
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                                .toList(),
                            value: _selectedGender ?? vm.patient.gender,
                            onChanged: (v) => setState(() {
                              _selectedGender = v;
                            }),
                            validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Gender is required'
                                : null,
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
                        children: vm.patient.chronicDiseases
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

                    // ====================
                    // VITALS + UPLOAD FILE
                    // ====================
                    Row(
                      children: [
                        const Text(
                          'Medical Readings (optional)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _pickFileAndFill(vm),
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Upload File"),
                        ),
                      ],
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

                    // ====================
                    // ACTION BUTTONS
                    // ====================
                    Row(
                      children: [
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
                                      _selectedGender ?? vm.patient.gender);
                                  vm.updateNotes(_notesCtrl.text.trim());
                                  vm.updateReading('ecg', _ecgCtrl.text.trim());
                                  vm.updateReading('bp', _bpCtrl.text.trim());
                                  vm.updateReading('hr', _hrCtrl.text.trim());
                                  vm.updateReading('spo2', _spo2Ctrl.text.trim());
                                  vm.updateReading('rr', _rrCtrl.text.trim());
                                  vm.updateReading('temp', _tempCtrl.text.trim());
                                  vm.save();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Saved patient: ${vm.patient.name}'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              CustomActionButton(
                                label: 'Open Chat',
                                icon: Icons.chat,
                                bgColor: Colors.purple.shade50,
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/chat'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================
  // FILE PICKER
  // ====================
  Future<void> _pickFileAndFill(PatientViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    try {
      final data = jsonDecode(content) as Map<String, dynamic>;

      setState(() {
        // ==================== BASIC INFO ====================
        _nameCtrl.text = data['name']?.toString() ?? '';
        _ageCtrl.text = data['age']?.toString() ?? '';
        _selectedGender = data['gender']?.toString();
        _notesCtrl.text = data['notes']?.toString() ?? '';

        // ==================== VITALS ====================
        _ecgCtrl.text = data['ecg']?.toString() ?? '';
        _bpCtrl.text = data['bp']?.toString() ?? '';
        _hrCtrl.text = data['hr']?.toString() ?? '';
        _spo2Ctrl.text = data['spo2']?.toString() ?? '';
        _rrCtrl.text = data['rr']?.toString() ?? '';
        _tempCtrl.text = data['temp']?.toString() ?? '';
      });

      // ==================== UPDATE VIEWMODEL ====================
      vm.updateName(_nameCtrl.text.trim());
      vm.updateAge(_ageCtrl.text.trim());
      vm.updateGender(_selectedGender);

      vm.updateNotes(_notesCtrl.text.trim());
      vm.updateReading('ecg', _ecgCtrl.text.trim());
      vm.updateReading('bp', _bpCtrl.text.trim());
      vm.updateReading('hr', _hrCtrl.text.trim());
      vm.updateReading('spo2', _spo2Ctrl.text.trim());
      vm.updateReading('rr', _rrCtrl.text.trim());
      vm.updateReading('temp', _tempCtrl.text.trim());

      // chronic_conditions لو موجودة في الملف
      if (data['chronic_conditions'] is List) {
        vm.updateHasChronic(true);
        for (var d in data['chronic_conditions']) {
          vm.addChronicDisease(d.toString());
        }
      } else {
        vm.updateHasChronic(false);
      }
    } catch (e) {
      debugPrint("❌ Error parsing file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid file format")),
      );
    }
  }

  // ====================
  // RANDOM DATA
  // ====================
  void _fillRandom(PatientViewModel vm) {
    final rnd = DateTime.now().millisecondsSinceEpoch % 1000;
    final names = ['Alex', 'Sara', 'Omar', 'Lina', 'John', 'Maya'];
    final genders = ['Male', 'Female', 'Other'];

    final name = names[rnd % names.length];
    final age = 20 + (rnd % 60);
    final gender = genders[rnd % genders.length];
    final ecg = '${60 + (rnd % 40)}';
    final bp = '${100 + (rnd % 40)}/${60 + (rnd % 30)}';
    final hr = '${60 + (rnd % 60)}';
    final spo2 = '${95 + (rnd % 5)}';
    final rr = '${12 + (rnd % 10)}';
    final temp = '${36 + (rnd % 4)}.${rnd % 10}';

    setState(() {
      _nameCtrl.text = name;
      _ageCtrl.text = age.toString();
      _selectedGender = gender;
      _ecgCtrl.text = ecg;
      _bpCtrl.text = bp;
      _hrCtrl.text = hr;
      _spo2Ctrl.text = spo2;
      _rrCtrl.text = rr;
      _tempCtrl.text = temp;
      _notesCtrl.text = 'Random patient';
    });

    vm.updateName(_nameCtrl.text);
    vm.updateAge(_ageCtrl.text);
    vm.updateGender(_selectedGender);
    vm.updateReading('ecg', ecg);
    vm.updateReading('bp', bp);
    vm.updateReading('hr', hr);
    vm.updateReading('spo2', spo2);
    vm.updateReading('rr', rr);
    vm.updateReading('temp', temp);
  }

  // void _showAnalysisDialog(BuildContext context, Map<String, dynamic> result) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) {
  //       final patientData = result.values.first;
  //
  //       // 🟢 هنا تحط الكود الجديد بتاع lastAnalysis
  //       final lastAnalysis = patientData['last_analysis'] ?? {};
  //
  //       final ecg = lastAnalysis['ecg_analysis'] ?? {};
  //       final vitals = lastAnalysis['vital_signs_analysis'] ?? {};
  //       final combined = lastAnalysis['combined_assessment'] ?? {};
  //       final recommendations = lastAnalysis['unified_recommendations'] ?? [];
  //
  //       final buffer = StringBuffer();
  //
  //       // ECG Analysis
  //       buffer.writeln("❤️ ECG Analysis");
  //       buffer.writeln("Class: ${ecg['class_name'] ?? 'N/A'}");
  //       buffer.writeln("Risk Level: ${ecg['risk_level'] ?? 'N/A'}\n");
  //
  //       // Vital Signs
  //       buffer.writeln("📊 Vital Signs");
  //       final cleaned = vitals['cleaned_vital_signs'] ?? {};
  //       buffer.writeln("Risk Level: ${vitals['news_analysis']?['total_news_score']} → "
  //           "${vitals['news_analysis']?['risk_category']?['level']}\n");
  //
  //       // Alerts
  //       buffer.writeln("⚠️ Alerts & Issues");
  //       final errors = vitals['sensor_errors'] ?? [];
  //       for (var e in errors) {
  //         buffer.writeln("${e['sensor']} issue: ${e['error']}");
  //       }
  //       for (var f in combined['contributing_factors'] ?? []) {
  //         buffer.writeln(f);
  //       }
  //       buffer.writeln("");
  //
  //       return AlertDialog(
  //         title: const Text("📑 Patient Report"),
  //         content: SingleChildScrollView(
  //           child: SelectableText(
  //             buffer.toString(),
  //             style: const TextStyle(fontSize: 15, height: 1.4),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(ctx),
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showAnalysisDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (ctx) {
        final patientData = result.values.first;

        final lastAnalysis = patientData['last_analysis'] ?? {};
        final ecg = lastAnalysis['ecg_analysis'] ?? {};
        final vitals = lastAnalysis['vital_signs_analysis'] ?? {};
        final combined = lastAnalysis['combined_assessment'] ?? {};
        final recommendations = lastAnalysis['unified_recommendations'] ?? [];

        final sensorErrors = vitals['sensor_errors'] ?? [];
        final contributingFactors = combined['contributing_factors'] ?? [];

        return AlertDialog(
          title: const Text("📑 Patient Report"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= ECG =================
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("❤️ ECG Analysis",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text("Class: ${ecg['class_name'] ?? 'N/A'}"),
                        Text("Risk Level: ${ecg['risk_level'] ?? 'N/A'}"),
                      ],
                    ),
                  ),
                ),

                // ================= Vital Signs =================
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("📊 Vital Signs",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Text(
                          "Risk Level: ${vitals['news_analysis']?['total_news_score']} → "
                              "${vitals['news_analysis']?['risk_category']?['level']}",
                        ),
                        if (sensorErrors.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Text(
                            "Sensor Issues:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...sensorErrors.map(
                                  (e) => Text("- ${e['sensor']} issue: ${e['error']}")),
                        ],
                      ],
                    ),
                  ),
                ),

                // ================= Combined Factors =================
                if (contributingFactors.isNotEmpty)
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("⚠️ Alerts & Contributing Factors",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Divider(),
                          ...contributingFactors.map((f) => Text("- $f")),
                        ],
                      ),
                    ),
                  ),

                // ================= Recommendations =================
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

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Detect if the message contains Arabic
  bool _containsArabic(String s) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(s);
  }

  @override
  Widget build(BuildContext context) {
    final chatVm = Provider.of<ChatViewModel>(context);
    final patientVm = Provider.of<PatientViewModel>(context);

    // Now send uses patientName instead of fixed patientId
    final patientName =
    patientVm.patient.name.isNotEmpty ? patientVm.patient.name : "unknown";

    // For input field direction
    final appIsRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: chatVm.messages.length,
                itemBuilder: (context, i) {
                  final m = chatVm.messages[i];

                  // alignment: user → right, bot → left
                  final alignment = m.isUser
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart;

                  // detect language for this bubble
                  final isArabicMessage = _containsArabic(m.text);
                  final bubbleDirection =
                  isArabicMessage ? TextDirection.rtl : TextDirection.ltr;

                  return Align(
                    alignment: alignment,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: m.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Directionality(
                        textDirection: bubbleDirection,
                        child: Text(
                          m.text,
                          textAlign: TextAlign.start, // start follows direction
                          style: TextStyle(
                            color: m.isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textAlign: appIsRtl ? TextAlign.right : TextAlign.left,
                      decoration: InputDecoration(
                        hintText: appIsRtl ? 'اكتب رسالة' : 'Type a message',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(chatVm, patientName),
                    ),
                  ),
                  const SizedBox(width: 8),
                  VoiceRecorder(
                    onRecorded: (filePath) {
                      // Send the recorded audio file path to the viewmodel
                      chatVm.sendAudio(filePath, patientName: patientName);
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    key: const Key('sendButton'),
                    onPressed: () => _send(chatVm, patientName),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send(ChatViewModel chatVm, String patientName) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    chatVm.send(text, patientName: patientName);
    _ctrl.clear();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
