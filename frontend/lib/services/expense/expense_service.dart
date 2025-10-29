import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/expense/expense.dart';
import '../../common/app_config.dart';

class ExpenseService {
  final String baseUrl;

  ExpenseService({this.baseUrl = AppConfig.expenseServiceUrl});

  Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<void> submitExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to submit expense');
    }
  }
}
