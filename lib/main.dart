import 'package:flutter/material.dart';
import 'package:fotoloca/screen/introduction/main_navigation.dart';
import 'package:fotoloca/screen/introduction/onboarding.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  String? role = await storage.read(key: 'user_role');

  await Supabase.initialize(
    url: "https://mrrovxvnbaapmlckdrof.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ycm92eHZuYmFhcG1sY2tkcm9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwMTEzMDQsImV4cCI6MjA4ODU4NzMwNH0.tnfL2nX_FkRNU12D_Y9kJ3nTZmvo7oscug0UNJOwgW4",
  );

  Widget firstPage;

  if (token != null && role != null) {
    List<String> validRoles = ['admin', 'kasir', 'owner'];

    if (validRoles.contains(role)) {
      firstPage = MainNavigation(role: role);
    } else {
      firstPage = const Login();
    }
  } else {
    //Jika token kosong arahkan ke onboarding
    firstPage = const OnboardingScreen();
  }

  runApp(MyApp(initialScreen: firstPage));
}

class MyApp extends StatefulWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FotoLoca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoSansTextTheme(),
      ),
      home: widget.initialScreen,
    );
  }
}
