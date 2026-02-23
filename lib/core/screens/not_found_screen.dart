import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("404 Error: User attempted to access non-existent route");
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '404',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A2D3E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Page not found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2D3E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'User attempted to access non-existent route.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Return to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
