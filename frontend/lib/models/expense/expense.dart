import 'package:flutter/material.dart';

enum ExpenseStatus {
  pending,
  approved,
  rejected,
  needsMoreDetails
}

class Expense {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseStatus status;
  final String? receiptPath;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? approvedBy;

  Expense({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.date,
    this.status = ExpenseStatus.pending,
    this.receiptPath,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.approvedBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown User',
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      receiptPath: json['receiptPath'],
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'receiptPath': receiptPath,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'approvedBy': approvedBy,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
      case ExpenseStatus.needsMoreDetails:
        return 'Needs More Details';
    }
  }

  Color get statusColor {
    switch (status) {
      case ExpenseStatus.pending:
        return const Color(0xFFF57F17); // Amber
      case ExpenseStatus.approved:
        return const Color(0xFF388E3C); // Green
      case ExpenseStatus.rejected:
        return const Color(0xFFD32F2F); // Red
      case ExpenseStatus.needsMoreDetails:
        return const Color(0xFF1976D2); // Blue
    }
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? userName,
    double? amount,
    String? description,
    DateTime? date,
    ExpenseStatus? status,
    String? receiptPath,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      receiptPath: receiptPath ?? this.receiptPath,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }
}
