import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'visitas_screen.dart';

class DashboardPortero extends StatelessWidget {
  const DashboardPortero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        title: const Text(
          'App Oasis — Portero',
          style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1565C0)),
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body:  const VisitasScreen(),
    );
  }
}