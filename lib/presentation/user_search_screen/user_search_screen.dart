import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/connection_service.dart';
import '../../services/user_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  final _userService = UserService();
  final _connectionService = ConnectionService();
  final _authService = AuthService();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.userId;
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getAllUsers(limit: 50);
      setState(() {
        _users = users.where((user) => user['id'] != _currentUserId).toList();
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to load users: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      _loadAllUsers();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final users = await _userService.searchUsers(query);
      setState(() {
        _users = users.where((user) => user['id'] != _currentUserId).toList();
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Search failed: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendConnectionRequest(String userId) async {
    if (_currentUserId == null) return;

    try {
      await _connectionService.sendConnectionRequest(_currentUserId!, userId);
      Fluttertoast.showToast(
        msg: "Connection request sent!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to send request: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Search Users',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username or name...',
                prefixIcon: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                filled: true,
                fillColor: AppTheme.lightTheme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchUsers(value);
                  }
                });
              },
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: AppTheme.lightTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Photo
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
              backgroundImage:
                  user['photo'] != null ? NetworkImage(user['photo']) : null,
              child: user['photo'] == null
                  ? Text(
                      (user['name'] as String).isNotEmpty
                          ? (user['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown User',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${user['username'] ?? 'unknown'}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (user['email'] != null) ...[
                    SizedBox(height: 4),
                    Text(
                      user['email'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userProfileScreen,
                      arguments: user['id'],
                    );
                  },
                  icon: CustomIconWidget(
                    iconName: 'visibility',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  tooltip: 'View Profile',
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sendConnectionRequest(user['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Connect',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
