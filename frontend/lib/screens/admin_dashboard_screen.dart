import 'package:flutter/material.dart';
import '../../common/common_navigation_bar.dart';
import '../services/user/user_service.dart';
import '../models/user/user.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<_DashboardItem> items = const [
    _DashboardItem('Users', Icons.people),
    _DashboardItem('Expenses', Icons.receipt_long),
    _DashboardItem('Timesheets', Icons.access_time),
    _DashboardItem('Documents', Icons.description),
    _DashboardItem('Reports', Icons.bar_chart),
    _DashboardItem('Activity', Icons.history),
  ];

  final List<Color> tileColors = const [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonNavigationBar(
        title: 'Admin Dashboard',
        onSearch: () {},
        onProfile: () {},
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _ResizableSidebar(
            maxWidth: constraints.maxWidth,
            items: items,
            tileColors: tileColors,
            selectedIndex: selectedIndex,
            onTileSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}

class _ResizableSidebar extends StatefulWidget {
  final double maxWidth;
  final List<_DashboardItem> items;
  final List<Color> tileColors;
  final int selectedIndex;
  final ValueChanged<int> onTileSelected;

  const _ResizableSidebar({
    Key? key,
    required this.maxWidth,
    required this.items,
    required this.tileColors,
    required this.selectedIndex,
    required this.onTileSelected,
  }) : super(key: key);

  @override
  State<_ResizableSidebar> createState() => _ResizableSidebarState();
}

class _ResizableSidebarState extends State<_ResizableSidebar> {
  late double sidebarFraction;
  static const double minFraction = 0.10;
  static const double maxFraction = 0.40;

  @override
  void initState() {
    super.initState();
    sidebarFraction = 0.20;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      double newFraction = sidebarFraction + details.delta.dx / widget.maxWidth;
      sidebarFraction = newFraction.clamp(minFraction, maxFraction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = widget.maxWidth * sidebarFraction;
    return Row(
      children: [
        Container(
          width: sidebarWidth,
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              ...List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final color = widget.tileColors[index % widget.tileColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: SidebarTile(
                    title: item.title,
                    icon: item.icon,
                    color: color,
                    selected: widget.selectedIndex == index,
                    onTap: () {
                      widget.onTileSelected(index);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: _onDragUpdate,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 8,
              height: double.infinity,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildMainContent(widget.selectedIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(int selectedIndex) {
    if (selectedIndex == 0) {
      return UserGrid();
    }
    // ...other screens can be added here
    return Center(
      child: Text(
        'Select an item from the toolbar to view actions/details.',
        style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
      ),
    );
  }
}

class SidebarTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const SidebarTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: Colors.black26, width: 2) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserGrid extends StatefulWidget {
  const UserGrid({Key? key}) : super(key: key);

  @override
  State<UserGrid> createState() => _UserGridState();
}

class _UserGridState extends State<UserGrid> {
  List<User> users = [];
  List<bool> selected = [];
  int rowsPerPage = 10;
  int page = 0;
  String search = '';
  String sortColumn = 'id';
  bool sortAsc = true;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final fetched = await UserService().fetchUsers();
      setState(() {
        users = fetched;
        selected = List.filled(users.length, false);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _sort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAsc = !sortAsc;
      } else {
        sortColumn = column;
        sortAsc = true;
      }
      users.sort((a, b) {
        final aValue = _getColumnValue(a, column);
        final bValue = _getColumnValue(b, column);
        if (sortAsc) {
          return aValue.compareTo(bValue);
        } else {
          return bValue.compareTo(aValue);
        }
      });
    });
  }

  dynamic _getColumnValue(User user, String column) {
    switch (column) {
      case 'id':
        return user.id;
      case 'name':
        return user.name;
      case 'email':
        return user.email;
      case 'role':
        return user.role;
      default:
        return '';
    }
  }

  void _search(String value) {
    setState(() {
      search = value;
      page = 0;
    });
  }

  void _toggleSelect(int index, bool? value) {
    setState(() {
      selected[index] = value ?? false;
    });
  }

  void _deleteUser(int index) {
    setState(() {
      users.removeAt(index);
      selected.removeAt(index);
    });
  }

  Future<void> _showUserForm({User? user, int? index}) async {
    await showDialog(
      context: context,
      builder: (ctx) => UserFormModal(
        user: user,
        onSubmit: (newUser, password) async {
          if (user == null) {
            // Add user
            try {
              await UserService().createUser(newUser, password ?? '');
              await _fetchUsers();
            } catch (e) {
              setState(() { error = e.toString(); });
            }
          } else if (index != null) {
            // Edit user
            try {
              await UserService().updateUser(newUser);
              await _fetchUsers();
            } catch (e) {
              setState(() { error = e.toString(); });
            }
          }
        },
      ),
    );
  }

  List<int> get filteredIndexes {
    if (search.isEmpty) {
      return List.generate(users.length, (i) => i);
    }
    return List.generate(users.length, (i) => i).where((i) {
      final u = users[i];
      return u.name.toLowerCase().contains(search.toLowerCase()) ||
        u.email.toLowerCase().contains(search.toLowerCase()) ||
        u.role.toLowerCase().contains(search.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredIndexes;
    final paged = filtered.skip(page * rowsPerPage).take(rowsPerPage).toList();
    final allSelected = paged.isNotEmpty && paged.every((i) => selected[i]);
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
                onPressed: () => _showUserForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search users',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _search,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SingleChildScrollView(
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.blue.shade50),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                columns: [
                  DataColumn(
                    label: Row(
                      children: [
                        Checkbox(
                          value: allSelected,
                          tristate: true,
                          onChanged: (val) {
                            setState(() {
                              for (var i in paged) {
                                selected[i] = val ?? false;
                              }
                            });
                          },
                        ),
                        if (paged.any((i) => selected[i]))
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Selected',
                            onPressed: () {
                              setState(() {
                                for (var i = selected.length - 1; i >= 0; i--) {
                                  if (selected[i]) {
                                    users.removeAt(i);
                                    selected.removeAt(i);
                                  }
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  DataColumn(
                    label: _sortableLabel('ID', 'id'),
                    numeric: true,
                    onSort: (i, _) => _sort('id'),
                  ),
                  DataColumn(
                    label: _sortableLabel('Name', 'name'),
                    onSort: (i, _) => _sort('name'),
                  ),
                  DataColumn(
                    label: _sortableLabel('Email', 'email'),
                    onSort: (i, _) => _sort('email'),
                  ),
                  DataColumn(
                    label: _sortableLabel('Role', 'role'),
                    onSort: (i, _) => _sort('role'),
                  ),
                  DataColumn(label: const Text('Actions')),
                ],
                rows: List.generate(paged.length, (idx) {
                  final i = paged[idx];
                  final u = users[i];
                  return DataRow(
                    selected: selected[i],
                    color: MaterialStateProperty.resolveWith<Color?>((states) {
                      return idx % 2 == 0 ? Colors.grey.shade100 : Colors.grey.shade300;
                    }),
                    onSelectChanged: (val) => _toggleSelect(i, val),
                    cells: [
                      DataCell(Checkbox(
                        value: selected[i],
                        onChanged: (val) => _toggleSelect(i, val),
                      )),
                      DataCell(Text(u.id)),
                      DataCell(Text(u.name)),
                      DataCell(Text(u.email)),
                      DataCell(Text(u.role)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showUserForm(user: u, index: i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(i),
                          ),
                        ],
                      )),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: page > 0 ? () => setState(() => page--) : null,
            ),
            Text('Page ${page + 1} of ${((filtered.length - 1) / rowsPerPage).floor() + 1}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: (page + 1) * rowsPerPage < filtered.length ? () => setState(() => page++) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _sortableLabel(String label, String column) {
    return InkWell(
      onTap: () => _sort(column),
      child: Row(
        children: [
          Text(label),
          if (sortColumn == column)
            Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
        ],
      ),
    );
  }
}

class UserFormModal extends StatefulWidget {
  final User? user;
  final void Function(User user, String? password) onSubmit;
  const UserFormModal({Key? key, this.user, required this.onSubmit}) : super(key: key);

  @override
  State<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends State<UserFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _roleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _roleController = TextEditingController(text: widget.user?.role ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (v) => v == null || v.isEmpty ? 'Enter role' : null,
              ),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final user = User(
                id: widget.user?.id ?? '',
                name: _nameController.text,
                email: _emailController.text,
                role: _roleController.text,
              );
              widget.onSubmit(user, widget.user == null ? _passwordController.text : null);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  const _DashboardItem(this.title, this.icon);
}