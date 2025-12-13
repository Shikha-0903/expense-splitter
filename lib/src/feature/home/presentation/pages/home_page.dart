import 'package:expense_splitter/src/core/router/all/expense_routes.dart';
import 'package:expense_splitter/src/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Splitter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: "Search for expenses...",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.lightLavender),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(ExpenseRoutes.expensePage),
        child: Icon(Icons.add),
      ),
    );
  }
}
