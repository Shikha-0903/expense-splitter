import 'package:flutter/material.dart';

class SelfPage extends StatefulWidget {
  const SelfPage({super.key});

  @override
  State<SelfPage> createState() => _SelfPageState();
}

class _SelfPageState extends State<SelfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("This is self expense page")));
  }
}
