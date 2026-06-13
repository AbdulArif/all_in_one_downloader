import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/facebook_download_service.dart' show DownloadException;
import '../services/youtube_download_service.dart';

class YouTubePage extends StatefulWidget {
  const YouTubePage({super.key});

  @override
  State<YouTubePage> createState() => _YouTubePageState();
}

class _YouTubePageState extends State<YouTubePage> {
  final _linkController = TextEditingController();
  final _downloadService = YouTubeDownloadService();
  bool _downloading = false;
  double _progress = 0;

  bool _isYouTubeUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return false;
    final host = uri.host.toLowerCase();
    return host == 'youtube.com' ||
        host.endsWith('.youtube.com') ||
        host == 'youtu.be';
  }

  Future<void> _pasteLink() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty || !mounted) return;
    _linkController.text = text;
    _linkController.selection = TextSelection.collapsed(offset: text.length);
  }

  Future<void> _downloadVideo() async {
    final url = _linkController.text.trim();
    if (!_isYouTubeUrl(url)) {
      _showMessage('Enter a valid YouTube video or Shorts URL.');
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _downloading = true;
      _progress = 0;
    });
    try {
      final path = await _downloadService.download(
        url,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (mounted) _showMessage('Video saved to $path');
    } on DownloadException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B1118), Color(0xFF080C1D), Color(0xFF180D17)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 48 : 22,
                  vertical: 18,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(onBack: () => Navigator.of(context).pop()),
                        SizedBox(height: wide ? 70 : 48),
                        const _YouTubeBadge(),
                        const SizedBox(height: 30),
                        Text(
                          'Download from\nYouTube',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: wide ? 48 : 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Paste a public YouTube video or Shorts link below.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _LinkInput(
                          controller: _linkController,
                          onPaste: _pasteLink,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton.icon(
                            key: const Key('youtube-download-button'),
                            onPressed: _downloading ? null : _downloadVideo,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            icon: _downloading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                              _downloading
                                  ? _progress > 0
                                        ? 'Downloading ${(_progress * 100).round()}%'
                                        : 'Preparing video...'
                                  : 'Download',
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _SupportCard(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        const SizedBox(width: 12),
        const Text(
          'YouTube Downloader',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _YouTubeBadge extends StatelessWidget {
  const _YouTubeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF3B30), Color(0xFFB50000)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0000).withValues(alpha: 0.34),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 52,
      ),
    );
  }
}

class _LinkInput extends StatelessWidget {
  const _LinkInput({required this.controller, required this.onPaste});
  final TextEditingController controller;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('youtube-link-field'),
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'https://youtube.com/watch?v=...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.32)),
        prefixIcon: const Icon(Icons.link_rounded),
        suffixIcon: IconButton(
          onPressed: onPaste,
          tooltip: 'Paste link',
          icon: const Icon(Icons.content_paste_rounded),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: _border(Colors.white.withValues(alpha: 0.10)),
        enabledBorder: _border(Colors.white.withValues(alpha: 0.10)),
        focusedBorder: _border(const Color(0xFFFF3B30), width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Color(0xFFFF6B6B)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Supports public videos, Shorts and share links.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.66),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
