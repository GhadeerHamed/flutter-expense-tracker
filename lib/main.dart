import 'package:expense_tracker_project/widgets/expenses.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Expense Tracker')),
        body: Center(child: Expenses()),
      ),
    ),
  );
}
