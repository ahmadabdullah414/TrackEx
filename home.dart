import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackex/add_trans.dart';
import 'package:trackex/filter.dart';
import 'package:trackex/functions.dart';
import 'package:trackex/list.dart';
import 'package:trackex/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'All'; // 'All', 'Today', 'Week', 'Month', 'Year'
  final List<String> _filters = ['All', 'Today', 'Week', 'Month', 'Year'];

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    switch (_filter) {
      case 'Today':
        return transactions.where((t) => 
          t.date.day == now.day && 
          t.date.month == now.month && 
          t.date.year == now.year
        ).toList();
      case 'Week':
       return transactions.where((t) => 
  t.date.isAfter(now.subtract(const Duration(days: 7)))
).toList();
      case 'Month':
        return transactions.where((t) => 
          t.date.month == now.month && 
          t.date.year == now.year
        ).toList();
      case 'Year':
        return transactions.where((t) => t.date.year == now.year).toList();
      default:
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker Pro'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>();
          final filteredTransactions = _filterTransactions(transactions);

          final totalIncome = filteredTransactions
              .where((t) => t.isIncome)
              .fold(0.0, (sum, item) => sum + item.amount);

          final totalExpense = filteredTransactions
              .where((t) => !t.isIncome)
              .fold(0.0, (sum, item) => sum + item.amount);

          final totalBalance = totalIncome - totalExpense;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return FilterChipWidget(
                        label: filter,
                        selected: _filter == filter,
                        onSelected: (selected) {
                          setState(() => _filter = filter);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Balance Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Balance',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rs.${totalBalance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: totalBalance >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Income',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Rs.${totalIncome.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Expense',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Rs.${totalExpense.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Pie Chart
                if (filteredTransactions.isNotEmpty)
                  PieChart(
                    dataMap: {
                      'Income': totalIncome,
                      'Expense': totalExpense,
                    },
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                    colorList: const [Colors.green, Colors.red],
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Transactions List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${filteredTransactions.length} items',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Transactions List
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add one',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : TransactionList(transactions: filteredTransactions),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}