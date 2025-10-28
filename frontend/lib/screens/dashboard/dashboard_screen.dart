import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'unknown';
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Dashboard!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            Text('Role: $role', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            if (role == 'admin') ...[
              const Text('Admin Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Approve timesheets'),
              const Text('• View all reports'),
              const Text('• Manage employees'),
            ] else if (role == 'employee') ...[
              const Text('Employee Panel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('• Book timesheet'),
              const Text('• Submit expenses'),
              const Text('• Upload documents'),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
