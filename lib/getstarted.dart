import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DropdownButton<Locale>(
                  value: context.locale,
                  onChanged: (Locale? locale) {
                    if (locale != null) {
                      context.setLocale(locale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English',style: TextStyle(fontSize: 22),),
                    ),
                    DropdownMenuItem(
                      value: Locale('ta'),
                      child: Text('தமிழ்',style: TextStyle(fontSize: 22)),
                    ),
                    DropdownMenuItem(
                      value: Locale('hi'),
                      child: Text('हिन्दी',style: TextStyle(fontSize: 22)),
                    ),
                  ],
                ),
              ],),
            ),


            CircleAvatar(
              radius: 80,
              backgroundImage: const AssetImage("assets/logo.png"),
            ),
            const SizedBox(height: 20),

            // App Title
            Center(
              child: Text(
                'app_title'.tr(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 22),

            // Get Started Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text(
                'get_started'.tr(), // Multilingual
                style:
                const TextStyle(fontSize: 23, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
