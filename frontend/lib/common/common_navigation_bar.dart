import 'package:flutter/material.dart';

class CommonNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearch;
  final VoidCallback? onProfile;
  final List<Widget>? actions;

  const CommonNavigationBar({
    Key? key,
    required this.title,
    this.onSearch,
    this.onProfile,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: onSearch,
        ),
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: onProfile,
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
