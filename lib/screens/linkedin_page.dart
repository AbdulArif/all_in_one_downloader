import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/facebook_download_service.dart' show DownloadException;
import '../services/linkedin_download_service.dart';

class LinkedInPage extends StatefulWidget {
  const LinkedInPage({super.key});

  @override
  State<LinkedInPage> createState() => _LinkedInPageState();
}

class _LinkedInPageState extends State<LinkedInPage> {
  final _linkController = TextEditingController();
  final _downloadService = LinkedInDownloadService();
  bool _downloading = false;
  double _progress = 0;

  bool _isLinkedInUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return false;
    final host = uri.host.toLowerCase();
    return host == 'linkedin.com' || host.endsWith('.linkedin.com');
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
    if (!_isLinkedInUrl(url)) {
      _showMessage('Enter a valid LinkedIn video post URL.');
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
            colors: [Color(0xFF102A46), Color(0xFF080C1D), Color(0xFF091828)],
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
                        const _LinkedInBadge(),
                        const SizedBox(height: 30),
                        Text(
                          'Download from\nLinkedIn',
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
                          'Paste a public LinkedIn video post link below.',
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
                            key: const Key('linkedin-download-button'),
                            onPressed: _downloading ? null : _downloadVideo,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF0A66C2),
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
          'LinkedIn Downloader',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _LinkedInBadge extends StatelessWidget {
  const _LinkedInBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1685D1), Color(0xFF06447F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A66C2).withValues(alpha: 0.36),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Text(
        'in',
        style: TextStyle(
          color: Colors.white,
          fontSize: 39,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -2,
        ),
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
      key: const Key('linkedin-link-field'),
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'https://linkedin.com/posts/...',
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
        focusedBorder: _border(const Color(0xFF1685D1), width: 1.5),
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
          const Icon(Icons.verified_user_outlined, color: Color(0xFF62B5EB)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Supports public LinkedIn video posts and share links.',
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
