import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700, // Modern purple background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Welcome! I am Umar Bisharat.\nThis is my first Flutter login screen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.deepPurple.shade400,
                  prefixIcon: const Icon(Icons.email, color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.amberAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password Field
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.deepPurple.shade400,
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.amberAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              // Log In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
