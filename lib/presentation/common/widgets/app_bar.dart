import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/injection.dart';

class MentoraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const MentoraAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.bottom,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: AppTheme.elevationSmall,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      bottom: bottom,
      actions: actions ?? [
        Padding(
          padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

class RoleBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String role;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? leading;

  const RoleBasedAppBar({
    Key? key,
    required this.title,
    required this.role,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.bottom,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    
    switch (role) {
      case AppConstants.roleAdmin:
        backgroundColor = AppTheme.adminPrimaryColor;
        break;
      case AppConstants.roleTeacher:
        backgroundColor = AppTheme.teacherPrimaryColor;
        break;
      case AppConstants.roleStudent:
        backgroundColor = AppTheme.studentPrimaryColor;
        break;
      default:
        backgroundColor = Theme.of(context).primaryColor;
    }

    return MentoraAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      bottom: bottom,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String role;
  final VoidCallback onLogout;

  const ProfileAppBar({
    Key? key,
    required this.role,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoleBasedAppBar(
      title: 'Profile',
      role: role,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'logout') {
              onLogout();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String role;
  final Function(String) onSearch;
  final bool showBackButton;
  final List<Widget>? actions;

  const SearchAppBar({
    Key? key,
    required this.title,
    required this.role,
    required this.onSearch,
    this.showBackButton = true,
    this.actions,
  }) : super(key: key);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedAppBar(
      title: _isSearching ? '' : widget.title,
      role: widget.role,
      showBackButton: widget.showBackButton,
      actions: _isSearching
          ? [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    widget.onSearch('');
                  });
                },
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              ...?widget.actions,
            ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                  onChanged: widget.onSearch,
                  autofocus: true,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
