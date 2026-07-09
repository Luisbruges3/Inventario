import 'package:flutter/material.dart';
import 'visitas_screen.dart';
import 'cobros_screen.dart';
import 'pagos_screen.dart';

class DashboardAdmin extends StatelessWidget {
  final int tabInicial;
  const DashboardAdmin({super.key, this.tabInicial = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: tabInicial,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE3F2FD),
          title: const Text(
            'App Oasis — Admin',
            style: TextStyle(
                color: Color(0xFF1565C0), fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF1565C0),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF1565C0),
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Visitas'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Cobros'),
              Tab(icon: Icon(Icons.home), text: 'Pagos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VisitasScreen(),
            CobrosScreen(),
            PagosScreen(),
          ],
        ),
      ),
    );
  }
}