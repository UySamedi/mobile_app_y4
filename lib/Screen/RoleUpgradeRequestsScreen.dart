import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RoleUpgradeRequestsScreen extends StatefulWidget {
  const RoleUpgradeRequestsScreen({super.key});

  @override
  State<RoleUpgradeRequestsScreen> createState() =>
      _RoleUpgradeRequestsScreenState();
}

class _RoleUpgradeRequestsScreenState
    extends State<RoleUpgradeRequestsScreen> {
  final AuthController auth = Get.find();
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await auth.getMyRoleUpgradeRequests();

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _requests = result['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load requests';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      // Parse the UTC date
      final utcDate = DateTime.parse(dateString);
      
      // Convert to Cambodia timezone (UTC+7)
      final cambodiaDate = utcDate.add(const Duration(hours: 7));
      
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final month = months[cambodiaDate.month - 1];
      final day = cambodiaDate.day.toString().padLeft(2, '0');
      final year = cambodiaDate.year;
      final hour = cambodiaDate.hour.toString().padLeft(2, '0');
      final minute = cambodiaDate.minute.toString().padLeft(2, '0');
      return '$month $day, $year • $hour:$minute (ICT)';
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Role Upgrade Requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRequests,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchRequests,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No requests found',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You haven\'t submitted any role upgrade requests yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          final status = request['status']?.toString() ?? 'unknown';
                          final requestedRole =
                              request['requestedRole']?.toString() ?? 'N/A';
                          final reason = request['reason']?.toString() ?? '';
                          final adminComment =
                              request['adminComment']?.toString();
                          final requestedAt = request['requestedAt']?.toString();
                          final reviewedAt = request['reviewedAt']?.toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status and Requested Role
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: _getStatusColor(status),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _getStatusIcon(status),
                                                    size: 16,
                                                    color:
                                                        _getStatusColor(status),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    status.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          _getStatusColor(status),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          requestedRole.replaceAll('_', ' '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Requested Role Label
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Requested Role:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        requestedRole.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Reason
                                  const Text(
                                    'Reason:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Text(
                                      reason,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  // Admin Comment (if exists)
                                  if (adminComment != null &&
                                      adminComment.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Admin Comment:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: status.toLowerCase() ==
                                                'approved'
                                            ? Colors.green.withOpacity(0.1)
                                            : status.toLowerCase() == 'rejected'
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: status.toLowerCase() ==
                                                  'approved'
                                              ? Colors.green
                                              : status.toLowerCase() ==
                                                      'rejected'
                                                  ? Colors.red
                                                  : Colors.grey[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        adminComment,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: status.toLowerCase() ==
                                                  'approved'
                                              ? Colors.green[900]
                                              : status.toLowerCase() ==
                                                      'rejected'
                                                  ? Colors.red[900]
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  // Dates
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Requested:',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDate(requestedAt),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (reviewedAt != null)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reviewed:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDate(reviewedAt),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

