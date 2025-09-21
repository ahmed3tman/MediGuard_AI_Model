import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/patient_viewmodel.dart';
import '../../widgets/voice_recorder.dart';

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

  @override
  Widget build(BuildContext context) {
    final chatVm = Provider.of<ChatViewModel>(context);
    final patientVm = Provider.of<PatientViewModel>(context);

    // هنا بنجيب اسم المريض من PatientViewModel
    final patientName =
        patientVm.patient.name.isNotEmpty ? patientVm.patient.name : "unknown";

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
                  return Align(
                    alignment:
                        m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color:
                            m.isUser
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: m.isUser ? Colors.white : Colors.black87,
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
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                        isDense: true,
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
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),

        curve: Curves.easeOut,
      );
    });
  }
}
