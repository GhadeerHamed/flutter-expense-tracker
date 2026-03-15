import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'currency.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

const expenseIcon = Icons.receipt_long;

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    this.currencyCode = 'RON',
    String? id,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String currencyCode;

  double amountInRon(Map<String, double> exchangeRatesToRon) {
    final rate = exchangeRatesToRon[currencyCode] ?? 1.0;
    return amount * rate;
  }

  String get formattedAmount {
    return '${CurrencyCatalog.symbolFor(currencyCode)} ${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'currency_code': currencyCode,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      currencyCode: (map['currency_code'] as String?) ?? 'RON',
    );
  }

  String get formattedDate {
    return formatter.format(date);
  }
}
