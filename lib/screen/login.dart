import 'package:flutter/material.dart';
import 'package:fotoloca/screen/introduction/main_navigation.dart';
import 'package:fotoloca/screen/introduction/onboarding.dart';
import 'package:fotoloca/services/auth_service.dart';
import 'package:fotoloca/utils/app_colors.dart';
import 'package:fotoloca/widget/custom_textfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  //Login Function
  Future<void> _prosesLogin() async {
    //validasi
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password harus diisi!')),
      );
      return;
    }
    //loading mulai
    setState(() {
      _isLoading = true;
    });

    //Panggil service untuk tembak laravel
    final result = await AuthService().login(
      _usernameController.text,
      _passwordController.text,
    );

    //matikan loading
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    if (result['success']) {
      //Berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );

      String userRole = result['role'];

      List<String> validRoles = ['admin', 'kasir', 'owner'];

      if (validRoles.contains(userRole)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(role: userRole),
          ),
        );
      } else {
        print("Role tidak dikenali: $userRole");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xFF737373),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- BAGIAN ATAS (Header & Logo) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF333333),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Placeholder Logo
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image(image: AssetImage('assets/images/Logo.png')),
                  ),
                  const SizedBox(height: 40),

                  // --- BAGIAN BAWAH (Form & Ornamen) ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Stack(
                          children: [
                            // Ornamen Gelombang di bawah
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 150,
                                child: CustomPaint(
                                  painter: BottomWavePainter(),
                                ),
                              ),
                            ),

                            // Konten Form
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Selamat datang kembali!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A4A4A),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Masuk terlebih dahulu untuk menggunakan sistem pengelolaan jasa sewa fotografer.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xE6454545),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  // Input Username
                                  CustomTextfield(
                                    hintText: 'Username',
                                    icon: Icons.person,
                                    controller: _usernameController,
                                  ),
                                  const SizedBox(height: 10),

                                  // Input Password
                                  CustomTextfield(
                                    hintText: 'Password',
                                    icon: Icons.lock,
                                    isObscure: true,
                                    controller: _passwordController,
                                  ),
                                  const SizedBox(height: 100),

                                  // Tombol Login
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _prosesLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF636363,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 5,
                                        shadowColor: Colors.black45,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter untuk Efek Gelombang
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..style = PaintingStyle.fill;

    var path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.3,
    );
    path1.quadraticBezierTo(
      size.width * 0.8,
      -0.1,
      size.width,
      size.height * 0.2,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    var path2 = Path();
    path2.moveTo(size.width * 0.3, size.height);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.7,
      size.width,
      size.height * 0.1,
    );
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
