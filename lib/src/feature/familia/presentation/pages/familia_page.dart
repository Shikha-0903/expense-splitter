import 'package:flutter/material.dart';

class FamiliaPage extends StatefulWidget {
  const FamiliaPage({super.key});

  @override
  State<FamiliaPage> createState() => _FamiliaPageState();
}

class _FamiliaPageState extends State<FamiliaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("This is familia page")));
  }
}
