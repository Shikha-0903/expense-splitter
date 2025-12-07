import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:expense_splitter/src/feature/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(
      MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}
