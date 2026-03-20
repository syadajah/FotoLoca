import 'package:flutter/material.dart';
import 'package:fotoloca/screen/admin/homepage_admin.dart';
import 'package:fotoloca/screen/admin/product_screen_admin.dart';
import 'package:fotoloca/screen/introduction/onboarding.dart';
import 'package:fotoloca/screen/kasir/homepage_kasir.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:fotoloca/screen/owner/homepage_owner.dart';
import 'package:fotoloca/test_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  String? role = await storage.read(key: 'user_role');

  Widget firstPage;

  if (token != null && role != null) {
    if (role == 'admin') {
      firstPage = const ProductScreenAdmin();
    } else if (role == 'kasir') {
      firstPage = const HomepageKasir();
    } else if (role == 'owner') {
      firstPage = const HomepageOwner();
    } else {
      firstPage = Login();
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
