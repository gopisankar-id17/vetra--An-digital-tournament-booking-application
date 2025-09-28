import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class TournamentVideosPage extends StatefulWidget {
  const TournamentVideosPage({super.key});

  @override
  State<TournamentVideosPage> createState() => _TournamentVideosPageState();
}

class _TournamentVideosPageState extends State<TournamentVideosPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _tournamentVideos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTournamentVideos();
  }

  // --- 🔄 CORRECTED THIS METHOD ---
  Future<void> _loadTournamentVideos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ REMOVED the .where('status' ...) clause which caused the error.
      final snapshot = await _firestore
          .collection('tournament_videos')
          .orderBy('uploadedAt', descending: true)
          .get();

      final videos = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (mounted) {
        setState(() {
          _tournamentVideos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading videos: $e')),
        );
      }
    }
  }

  Future<void> _launchYouTubeVideo(String url) async {
    final Uri youtubeUri = Uri.parse(url);
    if (!await launchUrl(youtubeUri, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch YouTube')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredVideos {
    if (_searchQuery.isEmpty) {
      return _tournamentVideos;
    }
    return _tournamentVideos.where((video) {
      final tournamentName = video['tournamentName']?.toString().toLowerCase() ?? '';
      // Since videoTitle is not saved, we only search by tournament name
      return tournamentName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // --- 🆕 ADDED HELPER METHOD ---
  /// Extracts the YouTube video ID from a URL to generate a thumbnail.
  String? _getYoutubeVideoId(String url) {
    if (!url.contains("http") && !url.contains("https://")) {
      url = "https://$url";
    }
    try {
      final uri = Uri.parse(url);
      if (uri.host == 'youtu.be') {
        return uri.pathSegments.first;
      }
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
    } catch (e) {
      print("Error parsing URL: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by tournament name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Videos Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tournament Videos (${_filteredVideos.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadTournamentVideos,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Videos List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVideos.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadTournamentVideos,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredVideos.length,
                          itemBuilder: (context, index) {
                            final video = _filteredVideos[index];
                            return _buildVideoCard(video);
                          },
                        ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No tournament videos available' : 'No videos found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'Check back later for tournament highlights' : 'Try a different search term',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- 🔄 UPDATED THIS WIDGET ---
  Widget _buildVideoCard(Map<String, dynamic> video) {
    final tournamentName = video['tournamentName'] ?? 'Unknown Tournament';
    final videoUrl = video['videoUrl'] ?? '';
    final videoId = _getYoutubeVideoId(videoUrl);
    final thumbnailUrl = videoId != null ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : '';

    final uploadedAt = video['uploadedAt'] as Timestamp?;
    final uploadedDate = uploadedAt != null ? _formatDate(uploadedAt.toDate()) : 'Recently';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.purple.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _launchYouTubeVideo(videoUrl),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: thumbnailUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(thumbnailUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if(thumbnailUrl.isEmpty)
                      Icon(Icons.movie, size: 40, color: Colors.grey[400]),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_filled,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Video Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Highlight Video', // Generic title
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tournamentName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6f42c1),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Uploaded: $uploadedDate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}