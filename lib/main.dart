import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/User/HomePages/home.dart' as user_home;
import 'package:carex/authentication/register.dart';
import 'package:carex/firebase_options.dart';
import 'package:carex/services/app_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareX',
      debugShowCheckedModeBanner: false,
      locale: const Locale('th', 'TH'),
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final role = data['role']?.toString();
        final name = data['name']?.toString() ?? '';
        final phone = data['phone']?.toString() ?? '';

        if (role == 'caregiver') {
          return Home(
            profile: caregiverData(
              fullName: name,
              phone: phone,
            ),
          );
        }

        if (role == 'client') {
          return const user_home.home();
        }

        return const Register();
      },
    );
  }

  Future<Map<String, dynamic>> _loadSession() async {
    final role = await AppSession.getRole();
    final name = await AppSession.getUserName();
    final phone = await AppSession.getPhone();
    return {
      'role': role,
      'name': name,
      'phone': phone,
    };
  }
}
