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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Connection Requests',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
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
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
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
            Icon(
              Icons.send_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No sent requests',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
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
              backgroundColor: Colors.blue[100],
              backgroundImage: fromUser['photo'] != null
                  ? NetworkImage(fromUser['photo'])
                  : null,
              child: fromUser['photo'] == null
                  ? Text(
                      (fromUser['name'] as String).isNotEmpty
                          ? (fromUser['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.inter(
                        color: Colors.blue,
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
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${fromUser['username'] ?? 'unknown'}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Wants to connect with you',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
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
                    backgroundColor: Colors.green,
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
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _declineRequest(request['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
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
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Accepted';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusText = 'Declined';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
              backgroundColor: Colors.blue[100],
              backgroundImage: toUser['photo'] != null
                  ? NetworkImage(toUser['photo'])
                  : null,
              child: toUser['photo'] == null
                  ? Text(
                      (toUser['name'] as String).isNotEmpty
                          ? (toUser['name'] as String)[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.inter(
                        color: Colors.blue,
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
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '@${toUser['username'] ?? 'unknown'}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                style: GoogleFonts.inter(
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
