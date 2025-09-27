import '../models/tournament_request.dart';

class TournamentRequestService {
  static final TournamentRequestService _instance =
      TournamentRequestService._internal();
  factory TournamentRequestService() => _instance;
  TournamentRequestService._internal();

  // In a real app, this would connect to Firebase/backend
  List<TournamentRequest> _requests = TournamentRequest.getSampleRequests();

  // Get all tournament requests
  Future<List<TournamentRequest>> getAllRequests() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_requests);
  }

  // Get requests by status
  Future<List<TournamentRequest>> getRequestsByStatus(
    RequestStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests.where((request) => request.status == status).toList();
  }

  // Approve a tournament request
  Future<void> approveRequest(String requestId, {String? adminRemarks}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: RequestStatus.approved,
        reviewedAt: DateTime.now(),
        adminRemarks: adminRemarks ?? 'Request approved',
      );
    }
  }

  // Reject a tournament request
  Future<void> rejectRequest(String requestId, {String? adminRemarks}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: RequestStatus.rejected,
        reviewedAt: DateTime.now(),
        adminRemarks: adminRemarks ?? 'Request rejected',
      );
    }
  }

  // Get request by ID
  Future<TournamentRequest?> getRequestById(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _requests.firstWhere((req) => req.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Get pending requests count
  Future<int> getPendingRequestsCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _requests.where((req) => req.status == RequestStatus.pending).length;
  }
}
