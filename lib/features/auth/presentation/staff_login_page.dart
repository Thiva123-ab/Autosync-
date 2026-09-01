import 'package:flutter/material.dart';
class StaffLoginPage extends StatelessWidget {
  final String title;
  const StaffLoginPage({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
  }
}

