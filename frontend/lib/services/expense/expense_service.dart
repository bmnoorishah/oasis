import 'dart:convert';
import 'dart:io';
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

  Future<List<Expense>> fetchAllExpenses() async {
    // For admin - fetch all expenses from all users
    final response = await http.get(Uri.parse('$baseUrl/admin/expenses'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<List<Expense>> fetchExpensesByStatus(ExpenseStatus status) async {
    final statusStr = status.toString().split('.').last;
    final response = await http.get(Uri.parse('$baseUrl/admin/expenses?status=$statusStr'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Expense> getExpenseById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/expenses/$id'));
    if (response.statusCode == 200) {
      return Expense.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load expense details');
    }
  }

  Future<void> submitExpense(Expense expense, {File? receiptFile}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/expense'),
    );

    // Add text fields
    request.fields['userId'] = expense.userId;
    request.fields['amount'] = expense.amount.toString();
    request.fields['description'] = expense.description;
    request.fields['date'] = expense.date.toIso8601String();

    // Add file if provided
    if (receiptFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'receipt',
        receiptFile.path,
      ));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to submit expense');
    }
  }

  Future<void> approveExpense(String expenseId, String approvedBy) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/expenses/$expenseId/approve'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'approvedBy': approvedBy}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to approve expense');
    }
  }

  Future<void> rejectExpense(String expenseId, String rejectionReason, String rejectedBy) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/expenses/$expenseId/reject'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'rejectionReason': rejectionReason,
        'rejectedBy': rejectedBy,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reject expense');
    }
  }

  Future<void> requestMoreDetails(String expenseId, String message, String requestedBy) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/expenses/$expenseId/request-details'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        'requestedBy': requestedBy,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to request more details');
    }
  }

  Future<String> getReceiptUrl(String expenseId) async {
    return '$baseUrl/expenses/$expenseId/receipt';
  }

  Future<void> downloadReceipt(String expenseId) async {
    final response = await http.get(Uri.parse('$baseUrl/expenses/$expenseId/receipt'));
    if (response.statusCode != 200) {
      throw Exception('Failed to download receipt');
    }
    // Handle file download - this would typically save to device storage
    // Implementation depends on platform-specific requirements
  }
}
