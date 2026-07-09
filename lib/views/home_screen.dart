import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_admin.dart';
import 'ajustes_screen.dart';
import 'facturas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = auth.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Image.asset('assets/icon.png', height: 48),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Oasis',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      Text(
                        'Panel de administración',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5E8DB5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Grid de secciones
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _SeccionCard(
                      icono: Icons.people,
                      nombre: 'Visitas',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DashboardAdmin(tabInicial: 0),
                        ),
                      ),
                    ),
                    _SeccionCard(
                      icono: Icons.receipt_long,
                      nombre: 'Cobros',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DashboardAdmin(tabInicial: 1),
                        ),
                      ),
                    ),
                    _SeccionCard(
                      icono: Icons.home,
                      nombre: 'Pagos',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DashboardAdmin(tabInicial: 2),
                        ),
                      ),
                    ),
                    _SeccionCard(
                      icono: Icons.request_page,
                      nombre: 'Recibos',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FacturasScreen(),
                        ),
                      ),
                    ),
                    _SeccionCard(
                      icono: Icons.settings,
                      nombre: 'Ajustes',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AjustesScreen(),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),

              // Footer con usuario y cerrar sesión
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid)
                    .get(),
                builder: (context, snapshot) {
                  final nombre = snapshot.data?.get('nombre') ?? 'Admin';
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD0E4F5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1565C0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const Text(
                                'Administrador',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5E8DB5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await auth.FirebaseAuth.instance.signOut();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.logout,
                                  color: Colors.red, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Salir',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeccionCard extends StatelessWidget {
  final IconData icono;
  final String nombre;
  final VoidCallback onTap;

  const _SeccionCard({
    required this.icono,
    required this.nombre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0E4F5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icono, size: 28, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}