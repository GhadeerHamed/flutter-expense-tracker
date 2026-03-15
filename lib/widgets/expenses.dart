import 'dart:io';

import 'package:expense_tracker_project/widgets/chart/chart.dart';
import 'package:expense_tracker_project/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker_project/models/expense.dart';
import 'package:expense_tracker_project/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import '../db/expense_database.dart';
import '../services/exchange_rate_service.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  static const int _pageSize = 6;

  List<Expense> _registeredExpenses = [];
  List<Expense> _chartExpenses = [];
  final ExchangeRateService _exchangeRateService = ExchangeRateService();
  Map<String, double> _exchangeRatesToRon = const {'RON': 1.0};
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialExpenses();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMoreExpenses();
    }
  }

  Future<void> _loadInitialExpenses() async {
    final firstPage = await ExpenseDatabase.instance.fetchExpensesPage(
      limit: _pageSize,
      offset: 0,
    );
    final allExpenses = await ExpenseDatabase.instance.fetchExpenses();
    final codes = allExpenses.map((e) => e.currencyCode).toSet();
    final rates = await _exchangeRateService.fetchRatesToRon(codes);

    if (!mounted) {
      return;
    }

    setState(() {
      _registeredExpenses = firstPage;
      _chartExpenses = allExpenses.isNotEmpty ? allExpenses : firstPage;
      _exchangeRatesToRon = rates;
      _offset = firstPage.length;
      _hasMore = firstPage.length == _pageSize;
      _isLoading = false;
    });
  }

  Future<void> _loadMoreExpenses() async {
    setState(() {
      _isLoadingMore = true;
    });

    final nextPage = await ExpenseDatabase.instance.fetchExpensesPage(
      limit: _pageSize,
      offset: _offset,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _registeredExpenses = [..._registeredExpenses, ...nextPage];
      _offset += nextPage.length;
      _hasMore = nextPage.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshExpenses() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _hasMore = true;
      _offset = 0;
    });

    await _loadInitialExpenses();
  }

  _openAddExpenseOverlay() {
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(maxHeight: screenHeight),
      builder: (ctx) => SizedBox(
        height: screenHeight,
        child: NewExpense(
          onAddExpense: addExpense,
        ),
      ),
    );
  }

  Future<void> addExpense(Expense expense) async {
    await ExpenseDatabase.instance.insertExpense(expense);
    await _refreshExpenses();
  }

  Future<void> removeExpense(Expense expense) async {
    await ExpenseDatabase.instance.deleteExpense(expense.id);
    await _refreshExpenses();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted.'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ExpenseDatabase.instance.insertExpense(expense);
            await _refreshExpenses();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final chartData = _chartExpenses.isNotEmpty
        ? _chartExpenses
        : _registeredExpenses;

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: removeExpense,
        scrollController: _scrollController,
        isLoadingMore: _isLoadingMore,
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
        title: const Text('Expense Tracker'),
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(
                  expenses: chartData,
                  exchangeRatesToRon: _exchangeRatesToRon,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: mainContent,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(
                    expenses: chartData,
                    exchangeRatesToRon: _exchangeRatesToRon,
                  ),
                ),
                Expanded(
                  child: mainContent,
                ),
              ],
            ),
    );
  }
}
