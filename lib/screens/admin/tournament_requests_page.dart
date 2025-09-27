import 'package:flutter/material.dart';
import '../../models/tournament_request.dart';
import '../../services/tournament_request_service.dart';
import '../../utils/app_theme.dart';

class TournamentRequestsPage extends StatefulWidget {
  const TournamentRequestsPage({Key? key}) : super(key: key);

  @override
  State<TournamentRequestsPage> createState() => _TournamentRequestsPageState();
}

class _TournamentRequestsPageState extends State<TournamentRequestsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TournamentRequestService _requestService = TournamentRequestService();

  List<TournamentRequest> _pendingRequests = [];
  List<TournamentRequest> _approvedRequests = [];
  List<TournamentRequest> _rejectedRequests = [];

  bool _isLoading = true;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final pending = await _requestService.getRequestsByStatus(
        RequestStatus.pending,
      );
      final approved = await _requestService.getRequestsByStatus(
        RequestStatus.approved,
      );
      final rejected = await _requestService.getRequestsByStatus(
        RequestStatus.rejected,
      );

      setState(() {
        _pendingRequests = pending;
        _approvedRequests = approved;
        _rejectedRequests = rejected;
        _pendingCount = pending.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load requests: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadRequests,
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tournament Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (_pendingCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(_pendingRequests, RequestStatus.pending),
                _buildRequestsList(_approvedRequests, RequestStatus.approved),
                _buildRequestsList(_rejectedRequests, RequestStatus.rejected),
              ],
            ),
    );
  }

  Widget _buildRequestsList(
    List<TournamentRequest> requests,
    RequestStatus status,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getEmptyStateIcon(status), size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(status),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(status),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(requests[index]);
        },
      ),
    );
  }

  IconData _getEmptyStateIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.inbox_outlined;
      case RequestStatus.approved:
        return Icons.check_circle_outline;
      case RequestStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _getEmptyStateTitle(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'No Pending Requests';
      case RequestStatus.approved:
        return 'No Approved Requests';
      case RequestStatus.rejected:
        return 'No Rejected Requests';
    }
  }

  String _getEmptyStateSubtitle(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'All tournament requests have been reviewed';
      case RequestStatus.approved:
        return 'No tournaments have been approved yet';
      case RequestStatus.rejected:
        return 'No tournaments have been rejected yet';
    }
  }

  Widget _buildRequestCard(TournamentRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tournament name and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: request.statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.tournamentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.textMediumColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'by ${request.organizerName}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMediumColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: request.statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(request.statusIcon, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        request.statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament details grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.sports,
                        request.sportType,
                        'Sport',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.location_on,
                        request.location,
                        'Location',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.calendar_today,
                        _formatDateTime(request.dateTime),
                        'Date & Time',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.people,
                        '${request.maxParticipants} players',
                        'Capacity',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (request.entryFee != null)
                  _buildDetailItem(
                    Icons.attach_money,
                    '₹${request.entryFee!.toInt()}',
                    'Entry Fee',
                  ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.shortDescription,
                  style: const TextStyle(
                    color: AppTheme.textMediumColor,
                    height: 1.4,
                  ),
                ),

                // Show admin remarks for reviewed requests
                if (request.status != RequestStatus.pending &&
                    request.adminRemarks != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Remarks',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.adminRemarks!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMediumColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons for pending requests
                if (request.status == RequestStatus.pending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRejectDialog(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.red[200]!),
                            ),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text(
                            'Reject',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text(
                            'Approve',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Submission time
                const SizedBox(height: 16),
                Text(
                  'Submitted ${_formatRelativeTime(request.submittedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMediumColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDarkColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (difference == 0) {
      return 'Today at $timeStr';
    } else if (difference == 1) {
      return 'Tomorrow at $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $timeStr';
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showApprovalDialog(TournamentRequest request) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Tournament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to approve "${request.tournamentName}"?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Admin Remarks (Optional)',
                hintText: 'Add any comments or instructions...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _approveRequest(request, remarksController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(TournamentRequest request) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Tournament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject "${request.tournamentName}"?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'Please provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (remarksController.text.trim().isNotEmpty) {
                _rejectRequest(request, remarksController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(
    TournamentRequest request,
    String remarks,
  ) async {
    Navigator.pop(context);

    try {
      await _requestService.approveRequest(
        request.id,
        adminRemarks: remarks.isNotEmpty ? remarks : 'Request approved',
      );

      _showSuccessSnackBar(
        'Tournament "${request.tournamentName}" approved successfully!',
      );
      await _loadRequests();

      // Switch to approved tab
      _tabController.animateTo(1);
    } catch (e) {
      _showErrorSnackBar('Failed to approve tournament: $e');
    }
  }

  Future<void> _rejectRequest(TournamentRequest request, String remarks) async {
    Navigator.pop(context);

    try {
      await _requestService.rejectRequest(request.id, adminRemarks: remarks);

      _showSuccessSnackBar('Tournament "${request.tournamentName}" rejected.');
      await _loadRequests();

      // Switch to rejected tab
      _tabController.animateTo(2);
    } catch (e) {
      _showErrorSnackBar('Failed to reject tournament: $e');
    }
  }
}
