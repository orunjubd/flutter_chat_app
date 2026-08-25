import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chat_app/core/media/services/media_share_service.dart';
import 'package:chat_app/core/media/widgets/share_choice_sheet.dart';

class FullscreenImageViewer extends StatefulWidget {
  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  final String imageUrl;
  final Object? heroTag;

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final _shareService = const MediaShareService();
  bool _isBusy = false;

  Future<void> _handleShare() async {
    final choice = await showShareChoiceSheet(context);
    if (choice == null) return;

    if (choice == ShareChoice.link) {
      await SharePlus.instance.share(ShareParams(text: widget.imageUrl));
      return;
    }

    setState(() => _isBusy = true);
    try {
      final fileName = _shareService.fileNameFromUrl(
        widget.imageUrl,
        fallback: 'photo.jpg',
      );
      final file = await _shareService.downloadToTempFile(
        widget.imageUrl,
        fileName: fileName,
      );
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Photo'),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to share image: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isBusy = true);
    try {
      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo library access denied.')),
        );
        return;
      }

      final fileName = _shareService.fileNameFromUrl(
        widget.imageUrl,
        fallback: 'photo.jpg',
      );
      final file = await _shareService.downloadToTempFile(
        widget.imageUrl,
        fileName: fileName,
      );

      await Gal.putImage(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to gallery.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save image: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Save to gallery',
            onPressed: _isBusy ? null : _handleSave,
          ),
          IconButton(
            icon: _isBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: _isBusy ? null : _handleShare,
          ),
        ],
      ),
      body: SafeArea(
        child: PhotoView(
          imageProvider: NetworkImage(widget.imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          heroAttributes: widget.heroTag != null
              ? PhotoViewHeroAttributes(tag: widget.heroTag!)
              : null,
          loadingBuilder: (context, event) {
            final total = event?.expectedTotalBytes;
            final loaded = event?.cumulativeBytesLoaded;
            final progress = (total != null && total > 0 && loaded != null)
                ? loaded / total
                : null;
            return Center(
              child: CircularProgressIndicator(
                value: progress,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 64,
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to load image',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
