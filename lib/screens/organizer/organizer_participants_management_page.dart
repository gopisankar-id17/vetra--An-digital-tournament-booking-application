import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/participant.dart';
import '../../utils/app_theme.dart';
import '../../services/participant_service.dart';
import '../../utils/test_data_helper.dart';

class OrganizerParticipantsManagementPage extends StatefulWidget {
  final Tournament tournament;

  const OrganizerParticipantsManagementPage({
    Key? key,
    required this.tournament,
  }) : super(key: key);

  @override
  State<OrganizerParticipantsManagementPage> createState() =>
      _OrganizerParticipantsManagementPageState();
}

class _OrganizerParticipantsManagementPageState
    extends State<OrganizerParticipantsManagementPage> {
  List<Participant> _participants = [];
  List<Participant> _filteredParticipants = [];
  final TextEditingController _searchController = TextEditingController();
  final ParticipantService _participantService = ParticipantService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
    _searchController.addListener(_filterParticipants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);

    try {
      print('Loading participants for tournament: ${widget.tournament.id}');
      final participants = await _participantService.getParticipants(
        widget.tournament.id,
      );
      print('Found ${participants.length} participants');

      setState(() {
        _participants = participants;
        _filteredParticipants = participants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading participants: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading participants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterParticipants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParticipants = _participants
          .where(
            (participant) =>
                participant.name.toLowerCase().contains(query) ||
                participant.email.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _showParticipantDetails(Participant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(participant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(participant.email)),
              ],
            ),
            const SizedBox(height: 8),
            if (participant.phone != null)
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(participant.phone!),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('User ID: ${participant.userId}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Registered: ${participant.registrationDate.day}/${participant.registrationDate.month}/${participant.registrationDate.year}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  participant.status == ParticipantStatus.approved
                      ? Icons.check_circle
                      : participant.status == ParticipantStatus.pending
                      ? Icons.pending
                      : Icons.cancel,
                  size: 16,
                  color: participant.status == ParticipantStatus.approved
                      ? Colors.green
                      : participant.status == ParticipantStatus.pending
                      ? Colors.orange
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('Status: ${participant.status.name.toUpperCase()}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeParticipant(participant);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeParticipant(Participant participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Participant'),
        content: Text(
          'Are you sure you want to remove ${participant.name} from this tournament?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _participantService.removeParticipant(
                  widget.tournament.id,
                  participant.id,
                );
                setState(() {
                  _participants.remove(participant);
                  _filteredParticipants.remove(participant);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${participant.name} removed from tournament',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error removing participant: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportParticipantsList() async {
    try {
      await _participantService.exportParticipantsList(widget.tournament.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participants list exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting participants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessageToAll() {
    showDialog(
      context: context,
      builder: (context) {
        final messageController = TextEditingController();
        return AlertDialog(
          title: const Text('Send Message to All Participants'),
          content: TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter your message here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    await _participantService.notifyAllParticipants(
                      widget.tournament.id,
                      'Tournament Update',
                      messageController.text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent to all participants!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error sending message: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _addTestParticipants() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding test participants...'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    try {
      // Add test participants
      await TestDataHelper.addTestParticipants(widget.tournament.id);

      // Check Firestore structure
      await TestDataHelper.checkFirestoreStructure(widget.tournament.id);

      // Reload participants
      await _loadParticipants();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test participants added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding test participants: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDarkColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.blue),
            onPressed: () async {
              print('=== DEBUG INFO ===');
              print('Tournament ID: ${widget.tournament.id}');
              print('Tournament Name: ${widget.tournament.name}');
              print(
                'Current participants list length: ${_participants.length}',
              );
              await TestDataHelper.checkFirestoreStructure(
                widget.tournament.id,
              );
            },
            tooltip: 'Debug Info',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: _addTestParticipants,
            tooltip: 'Add Test Data',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportParticipantsList,
            tooltip: 'Export List',
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: _sendMessageToAll,
            tooltip: 'Message All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tournament.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.tournament.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_participants.length}/${widget.tournament.maxParticipants}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                LinearProgressIndicator(
                  value:
                      _participants.length / widget.tournament.maxParticipants,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search participants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Participants List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredParticipants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _participants.isEmpty
                              ? 'No participants registered yet'
                              : 'No participants found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredParticipants.length,
                    itemBuilder: (context, index) {
                      final participant = _filteredParticipants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              participant.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            participant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(participant.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () =>
                                    _showParticipantDetails(participant),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _removeParticipant(participant),
                              ),
                            ],
                          ),
                          onTap: () => _showParticipantDetails(participant),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
