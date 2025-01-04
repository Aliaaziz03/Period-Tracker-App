
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:individual1/authentication/login.dart';
import 'package:individual1/authentication/register.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Container(
          color : Colors.white,
         child: Center(
          child: Image.asset('assets/logo.jpg',
          width:150,
          height: 200 ), // Replace with your logo image asset
          ),
        ),
        );
      

    
  }
}