import 'package:flutter/material.dart';
import '../../models/expense/expense.dart';
import '../../services/expense/expense_service.dart';

class AdminExpenseScreen extends StatefulWidget {
  const AdminExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AdminExpenseScreen> createState() => _AdminExpenseScreenState();
}

class _AdminExpenseScreenState extends State<AdminExpenseScreen> {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> allExpenses = [];
  List<Expense> filteredExpenses = [];
  List<bool> selected = [];
  
  int rowsPerPage = 25;
  int page = 0;
  String search = '';
  String sortColumn = 'createdAt';
  bool sortAsc = false;
  ExpenseStatus? statusFilter;
  
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    try {
      final expenses = await _expenseService.fetchAllExpenses();
      setState(() {
        allExpenses = expenses;
        _applyFilters();
        selected = List.filled(allExpenses.length, false);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredExpenses = allExpenses.where((expense) {
      // Search filter
      final matchesSearch = search.isEmpty ||
          expense.userName.toLowerCase().contains(search.toLowerCase()) ||
          expense.description.toLowerCase().contains(search.toLowerCase()) ||
          expense.id.toLowerCase().contains(search.toLowerCase());
      
      // Status filter
      final matchesStatus = statusFilter == null || expense.status == statusFilter;
      
      return matchesSearch && matchesStatus;
    }).toList();

    // Apply sorting
    _sort(sortColumn, notify: false);
    
    // Reset pagination
    page = 0;
  }

  void _sort(String column, {bool notify = true}) {
    setState(() {
      if (sortColumn == column) {
        sortAsc = !sortAsc;
      } else {
        sortColumn = column;
        sortAsc = true;
      }
      
      filteredExpenses.sort((a, b) {
        final aValue = _getColumnValue(a, column);
        final bValue = _getColumnValue(b, column);
        
        int comparison;
        if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is double && bValue is double) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }
        
        return sortAsc ? comparison : -comparison;
      });
    });
  }

  dynamic _getColumnValue(Expense expense, String column) {
    switch (column) {
      case 'id':
        return expense.id;
      case 'userName':
        return expense.userName;
      case 'amount':
        return expense.amount;
      case 'description':
        return expense.description;
      case 'date':
        return expense.date;
      case 'status':
        return expense.statusDisplayName;
      case 'createdAt':
        return expense.createdAt;
      default:
        return '';
    }
  }

  void _search(String value) {
    setState(() {
      search = value;
      _applyFilters();
    });
  }

  void _filterByStatus(ExpenseStatus? status) {
    setState(() {
      statusFilter = status;
      _applyFilters();
    });
  }

  Future<void> _approveExpense(Expense expense) async {
    try {
      await _expenseService.approveExpense(expense.id, 'Admin');
      await _fetchExpenses();
      _showSnackBar('Expense approved successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to approve expense: $e', Colors.red);
    }
  }

  Future<void> _rejectExpense(Expense expense) async {
    final reason = await _showRejectDialog();
    if (reason != null && reason.isNotEmpty) {
      try {
        await _expenseService.rejectExpense(expense.id, reason, 'Admin');
        await _fetchExpenses();
        _showSnackBar('Expense rejected successfully', Colors.red);
      } catch (e) {
        _showSnackBar('Failed to reject expense: $e', Colors.red);
      }
    }
  }

  Future<void> _requestMoreDetails(Expense expense) async {
    final message = await _showRequestDetailsDialog();
    if (message != null && message.isNotEmpty) {
      try {
        await _expenseService.requestMoreDetails(expense.id, message, 'Admin');
        await _fetchExpenses();
        _showSnackBar('Request for more details sent successfully', Colors.blue);
      } catch (e) {
        _showSnackBar('Failed to request more details: $e', Colors.red);
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRequestDetailsDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request More Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please specify what additional details are needed:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter details needed...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailDialog(
        expense: expense,
        onApprove: () => _approveExpense(expense),
        onReject: () => _rejectExpense(expense),
        onRequestDetails: () => _requestMoreDetails(expense),
      ),
    );
  }

  void _previewReceipt(Expense expense) {
    if (expense.receiptPath != null) {
      showDialog(
        context: context,
        builder: (context) => ReceiptPreviewDialog(expense: expense),
      );
    } else {
      _showSnackBar('No receipt attached to this expense', Colors.orange);
    }
  }

  void _downloadReceipt(Expense expense) async {
    if (expense.receiptPath != null) {
      try {
        await _expenseService.downloadReceipt(expense.id);
        _showSnackBar('Receipt downloaded successfully', Colors.green);
      } catch (e) {
        _showSnackBar('Failed to download receipt: $e', Colors.red);
      }
    } else {
      _showSnackBar('No receipt attached to this expense', Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagedExpenses = filteredExpenses
        .skip(page * rowsPerPage)
        .take(rowsPerPage)
        .toList();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchExpenses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact Header and Controls
        Container(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Expense Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _fetchExpenses,
                    tooltip: 'Refresh',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Compact Search and Filter Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search expenses...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: _search,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<ExpenseStatus?>(
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        value: statusFilter,
                        items: [
                          const DropdownMenuItem<ExpenseStatus?>(
                            value: null,
                            child: Text('All Statuses'),
                          ),
                          ...ExpenseStatus.values.map((status) =>
                            DropdownMenuItem<ExpenseStatus?>(
                              value: status,
                              child: Text(status.toString().split('.').last),
                            ),
                          ),
                        ],
                        onChanged: _filterByStatus,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Rows per page selector
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Rows',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      value: rowsPerPage,
                      items: [10, 25, 50, 100].map((count) =>
                        DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count'),
                        ),
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            rowsPerPage = value;
                            page = 0;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Compact Summary Cards
              Row(
                children: [
                  _buildCompactSummaryCard(
                    'Total',
                    allExpenses.length.toString(),
                    Icons.receipt,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildCompactSummaryCard(
                    'Pending',
                    allExpenses.where((e) => e.status == ExpenseStatus.pending).length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildCompactSummaryCard(
                    'Approved',
                    allExpenses.where((e) => e.status == ExpenseStatus.approved).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildCompactSummaryCard(
                    'Rejected',
                    allExpenses.where((e) => e.status == ExpenseStatus.rejected).length.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Compact Data Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2),
              ],
            ),
            child: Column(
              children: [
                // Table Header with help text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Click any row or the ⓘ icon to view full details. Use action buttons for quick approval/rejection.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTable(
                      showCheckboxColumn: false,
                      headingRowHeight: 35,
                      dataRowHeight: 40,
                      horizontalMargin: 6,
                      columnSpacing: 12,
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 11,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 11,
                      ),
                      columns: [
                        DataColumn(
                          label: _sortableLabel('ID', 'id'),
                          onSort: (_, __) => _sort('id'),
                        ),
                        DataColumn(
                          label: _sortableLabel('Employee', 'userName'),
                          onSort: (_, __) => _sort('userName'),
                        ),
                        DataColumn(
                          label: _sortableLabel('Amount', 'amount'),
                          onSort: (_, __) => _sort('amount'),
                          numeric: true,
                        ),
                        DataColumn(
                          label: _sortableLabel('Description', 'description'),
                          onSort: (_, __) => _sort('description'),
                        ),
                        DataColumn(
                          label: _sortableLabel('Date', 'date'),
                          onSort: (_, __) => _sort('date'),
                        ),
                        DataColumn(
                          label: _sortableLabel('Status', 'status'),
                          onSort: (_, __) => _sort('status'),
                        ),
                        const DataColumn(label: Text('Receipt')),
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: pagedExpenses.map((expense) {
                        return DataRow(
                          onSelectChanged: (selected) {
                            if (selected == true) {
                              _showExpenseDetails(expense);
                            }
                          },
                          cells: [
                            DataCell(
                              Text(
                                expense.id.length > 4 
                                  ? '${expense.id.substring(0, 4)}...'
                                  : expense.id,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                expense.userName.length > 10
                                  ? '${expense.userName.substring(0, 10)}...'
                                  : expense.userName,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                expense.description.length > 15
                                  ? '${expense.description.substring(0, 15)}...'
                                  : expense.description,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatCompactDate(expense.date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: expense.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: expense.statusColor, width: 0.5),
                                ),
                                child: Text(
                                  expense.status.toString().split('.').last.substring(0, 3).toUpperCase(),
                                  style: TextStyle(
                                    color: expense.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              expense.receiptPath != null 
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.attach_file, size: 14, color: Colors.green),
                                      const SizedBox(width: 2),
                                      InkWell(
                                        onTap: () => _previewReceipt(expense),
                                        child: const Icon(Icons.visibility, size: 12, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 2),
                                      InkWell(
                                        onTap: () => _downloadReceipt(expense),
                                        child: const Icon(Icons.download, size: 12, color: Colors.green),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.close, size: 14, color: Colors.grey),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _showExpenseDetails(expense),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.info, color: Colors.blue, size: 14),
                                    ),
                                  ),
                                  if (expense.status == ExpenseStatus.pending) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _approveExpense(expense),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, color: Colors.green, size: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () => _rejectExpense(expense),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.red, size: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                // Compact Pagination
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${pagedExpenses.length} of ${filteredExpenses.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.first_page, size: 16),
                            onPressed: page > 0 ? () => setState(() => page = 0) : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 16),
                            onPressed: page > 0 ? () => setState(() => page--) : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${page + 1}/${((filteredExpenses.length - 1) / rowsPerPage).floor() + 1}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 16),
                            onPressed: (page + 1) * rowsPerPage < filteredExpenses.length
                                ? () => setState(() => page++)
                                : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                          IconButton(
                            icon: const Icon(Icons.last_page, size: 16),
                            onPressed: (page + 1) * rowsPerPage < filteredExpenses.length
                                ? () => setState(() => page = ((filteredExpenses.length - 1) / rowsPerPage).floor())
                                : null,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortableLabel(String label, String column) {
    return InkWell(
      onTap: () => _sort(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.length > 8 ? '${label.substring(0, 8)}...' : label,
            style: const TextStyle(fontSize: 11),
          ),
          if (sortColumn == column)
            Icon(
              sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
            ),
        ],
      ),
    );
  }

  String _formatCompactDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }
}

// Expense Detail Dialog
class ExpenseDetailDialog extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRequestDetails;

  const ExpenseDetailDialog({
    Key? key, 
    required this.expense,
    this.onApprove,
    this.onReject,
    this.onRequestDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.receipt, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Details',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${expense.id}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: expense.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: expense.statusColor),
                  ),
                  child: Text(
                    expense.statusDisplayName,
                    style: TextStyle(
                      color: expense.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSection(
                      'Basic Information',
                      Icons.info,
                      [
                        _buildDetailRow('Employee', expense.userName, Icons.person),
                        _buildDetailRow('Amount', '\$${expense.amount.toStringAsFixed(2)}', Icons.attach_money),
                        _buildDetailRow('Expense Date', _formatDate(expense.date), Icons.calendar_today),
                        _buildDetailRow('Category', _getCategoryFromDescription(expense.description), Icons.category),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    _buildSection(
                      'Description',
                      Icons.description,
                      [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            expense.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Timeline
                    _buildSection(
                      'Timeline',
                      Icons.schedule,
                      [
                        _buildDetailRow('Submitted', _formatDateTime(expense.createdAt), Icons.upload),
                        if (expense.updatedAt != null)
                          _buildDetailRow('Last Updated', _formatDateTime(expense.updatedAt!), Icons.update),
                        if (expense.approvedBy != null)
                          _buildDetailRow('Approved By', expense.approvedBy!, Icons.person_pin),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Receipt Information
                    _buildSection(
                      'Receipt',
                      Icons.attach_file,
                      [
                        if (expense.receiptPath != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Receipt attached',
                                    style: TextStyle(color: Colors.green.shade700),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Preview'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Show receipt preview
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download'),
                                  onPressed: () {
                                    // Download receipt
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'No receipt attached',
                                  style: TextStyle(color: Colors.orange.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Status Information
                    if (expense.rejectionReason != null) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        'Status Information',
                        Icons.info_outline,
                        [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(
                                      expense.status == ExpenseStatus.rejected ? 'Rejection Reason:' : 'Additional Details Requested:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  expense.rejectionReason!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (expense.status == ExpenseStatus.pending) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Request Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onRequestDetails != null ? () {
                      Navigator.of(context).pop();
                      onRequestDetails!();
                    } : null,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onReject != null ? () {
                      Navigator.of(context).pop();
                      onReject!();
                    } : null,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onApprove != null ? () {
                      Navigator.of(context).pop();
                      onApprove!();
                    } : null,
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getCategoryFromDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('travel') || desc.contains('flight') || desc.contains('hotel')) {
      return 'Travel';
    } else if (desc.contains('meal') || desc.contains('lunch') || desc.contains('dinner') || desc.contains('food')) {
      return 'Meals & Entertainment';
    } else if (desc.contains('office') || desc.contains('supplies') || desc.contains('equipment')) {
      return 'Office Supplies';
    } else if (desc.contains('transport') || desc.contains('taxi') || desc.contains('fuel') || desc.contains('parking')) {
      return 'Transportation';
    } else if (desc.contains('software') || desc.contains('license') || desc.contains('subscription')) {
      return 'Software & Tools';
    } else if (desc.contains('training') || desc.contains('course') || desc.contains('conference')) {
      return 'Training & Development';
    } else {
      return 'General';
    }
  }
}

// Receipt Preview Dialog
class ReceiptPreviewDialog extends StatelessWidget {
  final Expense expense;

  const ReceiptPreviewDialog({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Receipt Preview - ${expense.id}'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Receipt Preview'),
                      Text('(Image would be displayed here)'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  onPressed: () {
                    // Download logic here
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Full Screen'),
                  onPressed: () {
                    // Full screen logic here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}