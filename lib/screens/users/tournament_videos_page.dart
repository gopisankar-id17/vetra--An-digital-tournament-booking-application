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

  // Helper function to extract video ID from various YouTube URL formats
  String? _getYoutubeVideoId(String url) {
    if (!url.contains("http")) return null;
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(1) != null) ? match.group(1) : null;
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Videos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tournament_videos')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No videos have been uploaded yet.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final videos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoData = videos[index].data() as Map<String, dynamic>;
              final videoId = _getYoutubeVideoId(videoData['videoUrl'] ?? '');
              final thumbnailUrl = videoId != null
                  ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius
                child: InkWell(
                  onTap: () {
                    if (videoData['videoUrl'] != null) {
                      _launchURL(videoData['videoUrl']);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (thumbnailUrl != null)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.videocam_off, size: 50, color: Colors.grey),
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 60),
                            ),
                          ],
                        )
                      else // Fallback if thumbnail can't be generated
                        Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.videocam, size: 50, color: Colors.grey),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          videoData['tournamentName'] ?? 'Tournament Video',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}