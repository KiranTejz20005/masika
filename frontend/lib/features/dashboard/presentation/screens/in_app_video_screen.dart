import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

const _maroon = Color(0xFF8D2D3B);
const _textGray = Color(0xFF4B4B4B);

/// Full-screen in-app YouTube player. Plays the video inside the app
/// without redirecting to the YouTube app or browser.
class InAppVideoScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String description;

  const InAppVideoScreen({
    super.key,
    required this.videoId,
    this.title = '',
    this.description = '',
  });

  @override
  State<InAppVideoScreen> createState() => _InAppVideoScreenState();
}

class _InAppVideoScreenState extends State<InAppVideoScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        progressIndicatorColor: const Color(0xFF8D2D3B),
        progressColors: const ProgressBarColors(
          playedColor: Color(0xFF8D2D3B),
          handleColor: Color(0xFF8D2D3B),
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: _textGray),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                color: _textGray,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                player,
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: _textGray,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.description,
                            style: TextStyle(
                              color: _textGray.withValues(alpha: 0.85),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
