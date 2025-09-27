import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVideoPage extends StatefulWidget {
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _videoUrlController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> _completedTournaments = [];
  String? _selectedTournamentId;
  bool _isLoading = false;
  bool _isFetchingTournaments = true;

  @override
  void initState() {
    super.initState();
    _fetchCompletedTournaments();
  }

  @override
  void dispose() {
    _videoUrlController.dispose();
    super.dispose();
  }

  /// Fetches tournaments from Firestore where the status is 'completed'.
  Future<void> _fetchCompletedTournaments() async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .where('status', isEqualTo: 'completed')
          .get();

      final tournaments = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unnamed Tournament',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _completedTournaments = tournaments;
          _isFetchingTournaments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFetchingTournaments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching tournaments: $e')),
        );
      }
    }
  }

  /// Validates the form and saves the video link to Firestore.
  Future<void> _saveVideoLink() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Find the name of the selected tournament
      final selectedTournament = _completedTournaments.firstWhere(
        (t) => t['id'] == _selectedTournamentId,
      );

      // Data to be saved in the new collection
      final videoData = {
        'tournamentId': _selectedTournamentId,
        'tournamentName': selectedTournament['name'],
        'videoUrl': _videoUrlController.text.trim(),
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      // Add to the 'tournament_videos' collection
      await _firestore.collection('tournament_videos').add(videoData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video link saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset the form
        _formKey.currentState!.reset();
        setState(() {
          _selectedTournamentId = null;
          _videoUrlController.clear();
        });
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tournament Video'),
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Upload Video Link',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Dropdown to select a completed tournament
                if (_isFetchingTournaments)
                  const Center(child: CircularProgressIndicator())
                else if (_completedTournaments.isEmpty)
                  const Center(
                    child: Text(
                      'No completed tournaments found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedTournamentId,
                    hint: const Text('Select Completed Tournament'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.emoji_events),
                    ),
                    items: _completedTournaments.map((tournament) {
                      return DropdownMenuItem<String>(
                        value: tournament['id'],
                        child: Text(tournament['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTournamentId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a tournament';
                      }
                      return null;
                    },
                  ),
                
                const SizedBox(height: 20),

                // TextField for the YouTube URL
                TextFormField(
                  controller: _videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'YouTube Video URL',
                    hintText: 'https://www.youtube.com/watch?v=...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a video URL';
                    }
                    // Basic validation for a YouTube link
                    if (!value.contains('youtube.com') && !value.contains('youtu.be')) {
                      return 'Please enter a valid YouTube URL';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Save Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveVideoLink,
                  icon: _isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Video Link'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6f42c1), // A nice purple color
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}