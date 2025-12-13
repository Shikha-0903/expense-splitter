import 'package:flutter/material.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _eventName = TextEditingController();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _date = TextEditingController();
  final _tags = TextEditingController();
  final _participants = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense to split..")),
      body: Column(
        children: [
          TextField(
            controller: _eventName,
            decoration: InputDecoration(hintText: "Event Name"),
          ),
          TextField(
            controller: _description,
            decoration: InputDecoration(hintText: "Description"),
          ),
          TextField(
            controller: _amount,
            decoration: InputDecoration(hintText: "Amount"),
          ),
          TextField(
            controller: _date,
            decoration: InputDecoration(hintText: "Date"),
          ),
          TextField(
            controller: _tags,
            decoration: InputDecoration(hintText: "Tags"),
          ),
          TextField(
            controller: _participants,
            decoration: InputDecoration(hintText: "Participants"),
          ),
        ],
      ),
    );
  }
}
