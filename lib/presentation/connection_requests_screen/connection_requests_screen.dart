import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/connection_service.dart';
import '../../services/auth_service.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _connectionService = ConnectionService();
  final _authService = AuthService();

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  bool _isLoadingPending = false;
  bool _isLoadingSent = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = _authService.userId;
    _loadPendingRequests();
    _loadSentRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    if (_currentUserId == null) return;

    setState(() => _isLoadingPending = true);
    try {
      final requests =
          await _connectionService.getPendingRequests(_currentUserId!);
      setState(() {
        _pendingRequests = requests;
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to load pending requests: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoadingPending = false);
    }
  }

  Future<void> _loadSentRequests() async {
    if (_currentUserId == null) return;

    setState(() => _isLoadingSent = true);
    try {
      final requests =
          await _connectionService.getSentRequests(_currentUserId!);
      setState(() {
        _sentRequests = requests;
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to load sent requests: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoadingSent = false);
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await _connectionService.acceptConnectionRequest(requestId);
      Fluttertoast.showToast(
        msg: "Connection request accepted!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _loadPendingRequests();
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to accept request: ${error.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _declineRequest(String requestId) async {
    try {
      await _connectionService.declineConnectionRequest(requestId);
      Fluttertoast.showToast(
        msg: "Connection request declined",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      _loadPendingRequests();
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to decline request: ${error.toString()}",
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
          'Connection Requests',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          tabs: [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingRequestsTab(),
          _buildSentRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    if (_isLoadingPending) {
      return Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'inbox_outlined',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        final fromUser = request['from_user'];
        return _buildPendingRequestCard(request, fromUser);
      },
    );
  }

  Widget _buildSentRequestsTab() {
    if (_isLoadingSent) {
      return Center(child: CircularProgressIndicator());
    }

    if (_sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'send_outlined',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No sent requests',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final request = _sentRequests[index];
        final toUser = request['to_user'];
        return _buildSentRequestCard(request, toUser);
      },
    );
  }

  Widget _buildPendingRequestCard(
      Map<String, dynamic> request, Map<String, dynamic> fromUser) {
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
              backgroundImage: fromUser['photo'] != null
                  ? NetworkImage(fromUser['photo'])
                  : null,
              child: fromUser['photo'] == null
                  ? Text(
                      (fromUser['name'] as String).isNotEmpty
                          ? (fromUser['name'] as String)[0].toUpperCase()
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
                    fromUser['name'] ?? 'Unknown User',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${fromUser['username'] ?? 'unknown'}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Wants to connect with you',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _acceptRequest(request['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    'Accept',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _declineRequest(request['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightTheme.colorScheme.error,
                    side: BorderSide(color: AppTheme.lightTheme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.error,
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

  Widget _buildSentRequestCard(
      Map<String, dynamic> request, Map<String, dynamic> toUser) {
    final status = request['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = AppTheme.warningLight;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = AppTheme.lightTheme.colorScheme.tertiary;
        statusText = 'Accepted';
        break;
      case 'declined':
        statusColor = AppTheme.lightTheme.colorScheme.error;
        statusText = 'Declined';
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusText = 'Unknown';
    }

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
              backgroundImage: toUser['photo'] != null
                  ? NetworkImage(toUser['photo'])
                  : null,
              child: toUser['photo'] == null
                  ? Text(
                      (toUser['name'] as String).isNotEmpty
                          ? (toUser['name'] as String)[0].toUpperCase()
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
                    toUser['name'] ?? 'Unknown User',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${toUser['username'] ?? 'unknown'}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
