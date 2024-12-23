import 'dart:ui';
import 'package:ecomapp/customwidget/custbutton.dart';
import 'package:ecomapp/view/bottomnavpage.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:flutter/material.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
       
          Container(
            width: double.infinity,
            child: Image.asset(
              'assets/image/image 45.png',
              fit: BoxFit.cover,
            ),
          ),
         
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          // Centered text
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to GemStore!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The home for a fashionista',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Button at the bottom
          Positioned(
            bottom: 150,
            left: 50,
            right: 50,
            child: CustomButton(
              text: 'Get Started',
              onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));
              },
            ),
          ),
        ],
      ),
    );
  }
}
