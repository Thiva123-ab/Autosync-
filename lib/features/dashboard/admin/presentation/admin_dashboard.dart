import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/staff_drawer.dart';

class AdminDashboard extends StatelessWidget {
  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: const StaffDrawer(currentRole: 'Admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('Total Users', '1,250', Icons.people, Colors.blue),
            _buildStatCard('Active Bookings', '45', Icons.calendar_today, Colors.orange),
            _buildStatCard('Completed Jobs', '320', Icons.check_circle, Colors.green),
            _buildStatCard('Revenue (This Month)', '\$12,400', Icons.attach_money, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
