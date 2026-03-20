import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fotoloca/screen/login.dart';
import 'package:fotoloca/services/auth_service.dart';

class HomepageKasir extends StatelessWidget {
  const HomepageKasir({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing homepage kasir'),
        actions: [
          IconButton(onPressed: () async {
            const storage = FlutterSecureStorage();

            await storage.delete(key: 'auth_token');
            await storage.delete(key: 'user_role');
            await AuthService().logout();

            if(context.mounted)  {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Login()), (Route<dynamic> route) => false);
            }

          }, icon: const Icon(Icons.logout, color: Colors.red),)
        ],
      ),
      body: const Center(
        child: Text('Selamat datang kasir!'),
      ),

    );
  }
}