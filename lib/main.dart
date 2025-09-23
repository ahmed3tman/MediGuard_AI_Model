import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/viewmodels/patient_viewmodel.dart';
import 'src/viewmodels/chat_viewmodel.dart';
import 'src/views/screens/patient_form_view.dart' as patient_screen;
import 'src/views/screens/chat_view.dart' as chat_screen;


void main() {
  runApp(const MediguardApp());
}    
        
class MediguardApp extends StatelessWidget {
  const MediguardApp({super.key});
      
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: MaterialApp(
        title: 'MediGuard Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const patient_screen.PatientFormView(),
          '/chat': (context) => const chat_screen.ChatView(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const patient_screen.PatientFormView(),
          );
        },
      ),
    );
  }
}
