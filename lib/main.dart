import 'package:expense_tracker_project/widgets/expenses.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Center(child: Expenses()),
      ),
    ),
  );
}
