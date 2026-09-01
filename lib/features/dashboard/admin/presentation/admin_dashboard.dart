import 'package:flutter/material.dart';
class AdminDashboard extends StatelessWidget {
  final String title;
  const AdminDashboard({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
  }
}

