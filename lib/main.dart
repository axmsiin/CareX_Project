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
      theme: ThemeData(
        primaryColor: const Color(0xFFEE711E),
        scaffoldBackgroundColor: const Color(0xFFFDF0E8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEE711E),
          primary: const Color(0xFFEE711E),
          surface: const Color(0xFFFCFAFF),
          onPrimary: Colors.white,
          onSurface: const Color(0xFF564444),
          error: const Color(0xFFF04444),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDF0E8),
          foregroundColor: Color(0xFF564444),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFEE711E)),
          titleTextStyle: TextStyle(
            color: Color(0xFF564444),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF564444)),
          bodyMedium: TextStyle(color: Color(0xFF564444)),
          titleLarge: TextStyle(color: Color(0xFF564444)),
          titleMedium: TextStyle(color: Color(0xFF564444)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFCFAFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEE711E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEE711E), width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEE711E)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF564444)),
          labelStyle: const TextStyle(color: Color(0xFF564444)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEE711E),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFFEE711E),
        ),
      ),
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
