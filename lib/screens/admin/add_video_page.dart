import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVideoPage extends StatefulWidget {
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _completedTournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompletedTournaments();
  }

  Future<void> _fetchCompletedTournaments() async {
    try {
      final now = DateTime.now();
      
      // Get all tournaments and filter by end date
      final snapshot = await _firestore
          .collection('tournaments')
          .orderBy('endDate', descending: true) // Show recent first
          .get();

      // Filter completed tournaments (endDate < current date)
      final tournaments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add the document ID to the map
        return data;
      }).where((tournament) {
        final endDate = (tournament['endDate'] as Timestamp).toDate();
        return endDate.isBefore(now); // Tournament is completed if endDate is in past
      }).toList();

      if (mounted) {
        setState(() {
          _completedTournaments = tournaments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tournaments: $e')),
        );
      }
    }
  }

  void _showAddVideoDialog(Map<String, dynamic> tournament) {
    final formKey = GlobalKey<FormState>();
    final videoUrlController = TextEditingController();
    final videoTitleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Video for "${tournament['name']}"'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: videoTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Video Title *',
                      hintText: 'Enter video title',
                      icon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube Video URL *',
                      hintText: 'https://youtube.com/watch?v=...',
                      icon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a URL';
                      }
                      if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                        return 'Please enter a valid YouTube URL';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildYouTubeHelpText(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _saveVideoLink(
                    tournament, 
                    videoUrlController.text.trim(),
                    videoTitleController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Video'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYouTubeHelpText() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YouTube URL Examples:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '• https://youtube.com/watch?v=VIDEO_ID',
            style: TextStyle(fontSize: 10),
          ),
          Text(
            '• https://youtu.be/VIDEO_ID', 
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVideoLink(
    Map<String, dynamic> tournament, 
    String videoUrl, 
    String videoTitle,
  ) async {
    try {
      // Extract video ID from URL
      final videoId = _extractVideoId(videoUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL format');
      }

      final videoData = {
        'tournamentId': tournament['id'],
        'tournamentName': tournament['name'],
        'videoTitle': videoTitle,
        'videoUrl': videoUrl,
        'videoId': videoId,
        'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      await _firestore.collection('tournament_videos').add(videoData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video link saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _extractVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedTournaments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed tournaments found',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Completed tournaments will appear here',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCompletedTournaments,
                  child: Column(
                    children: [
                      // Header info
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.blueGrey[50],
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blueGrey[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add YouTube videos for completed tournaments',
                                style: TextStyle(
                                  color: Colors.blueGrey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tournaments list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _completedTournaments.length,
                          itemBuilder: (context, index) {
                            final tournament = _completedTournaments[index];
                            final endDate = (tournament['endDate'] as Timestamp).toDate();
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              elevation: 2,
                              child: ListTile(
                                leading: tournament['imageUrl'] != null && 
                                         tournament['imageUrl'].toString().isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          tournament['imageUrl'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.emoji_events, color: Colors.orange),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.emoji_events, color: Colors.orange),
                                      ),
                                title: Text(
                                  tournament['name'] ?? 'Unnamed Tournament',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Completed on ${_formatDate(endDate)}'),
                                    if (tournament['location'] != null)
                                      Text(
                                        tournament['location'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[700],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Add Video', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                onTap: () => _showAddVideoDialog(tournament),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}