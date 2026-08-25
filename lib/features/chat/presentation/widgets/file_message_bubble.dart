import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/media/providers/file_download_provider.dart';
import 'package:chat_app/features/chat/data/models/message.dart';

class FileMessageBubble extends ConsumerStatefulWidget {
  const FileMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final LegacyMessage message;
  final bool isMe;

  @override
  ConsumerState<FileMessageBubble> createState() => _FileMessageBubbleState();
}

class _FileMessageBubbleState extends ConsumerState<FileMessageBubble> {
  bool _isDownloading = false;

  Future<void> _downloadAndOpen() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      debugPrint('⬇️ Starting file download...');
      debugPrint('📄 File: ${widget.message.fileName}');
      debugPrint('🔗 URL: ${widget.message.fileUrl}');

      final file = await ref
          .read(fileDownloadServiceProvider)
          .downloadFile(
            url: widget.message.fileUrl!,
            fileName: widget.message.fileName ?? 'downloaded_file',
          );

      debugPrint('✅ File downloaded successfully.');
      debugPrint('   📂 Local path: ${file.path}');
      debugPrint('   📦 Bytes: ${await file.length()}');

      if (!mounted) return;

      final result = await OpenFilex.open(
        file.path,
        type: widget.message.mimeType ?? 'application/octet-stream',
      );

      debugPrint(
        '📱 Android open result: '
        'type=${result.type}, '
        'message=${result.message}',
      );

      if (!mounted) return;

      if (result.type == ResultType.done) {
        return;
      }

      if (result.type == ResultType.noAppToOpen) {
        await _showNoAppDialog(file);
        return;
      }

      _showMessage('Unable to open this file.');
    } catch (e, stackTrace) {
      debugPrint('❌ File download/open failed: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      _showMessage('Unable to download file.');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  String _resolveFileName(LegacyMessage message) {
    final caption = message.caption?.trim();

    if (caption != null && caption.isNotEmpty) {
      return caption;
    }

    final text = message.text.trim();

    if (text.isNotEmpty) {
      return text;
    }

    final mimeType = message.mimeType ?? 'application/octet-stream';

    return _fallbackFileName(mimeType);
  }

  String _fallbackFileName(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'application/pdf':
        return 'downloaded_file.pdf';

      case 'application/vnd.rar':
        return 'downloaded_file.rar';

      case 'application/zip':
      case 'application/x-zip-compressed':
        return 'downloaded_file.zip';

      case 'application/msword':
        return 'downloaded_file.doc';

      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'downloaded_file.docx';

      case 'application/vnd.ms-excel':
        return 'downloaded_file.xls';

      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'downloaded_file.xlsx';

      default:
        return 'downloaded_file';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showNoAppDialog(File file) async {
    if (!mounted) return;

    final shouldShare = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No compatible app found'),
          content: Text(
            'The file was downloaded successfully, '
            'but no installed app can open '
            '${widget.message.fileName ?? 'this file'}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.share),
              label: const Text('Share File'),
            ),
          ],
        );
      },
    );

    if (shouldShare != true || !mounted) return;

    try {
      debugPrint('📤 [ShareEngine] Sharing file: ${file.path}');

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: widget.message.fileName ?? 'Chat attachment',
        ),
      );

      debugPrint('✅ [ShareEngine] File share completed: ${result.status}');
    } catch (e, stackTrace) {
      debugPrint('❌ File sharing failed: $e');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Unable to share this file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    final fileName = _resolveFileName(message);

    final mimeType = message.mimeType ?? 'application/octet-stream';

    final primaryColor = context.primaryColor;
    final secondaryColor = context.textSecondaryColor;

    return InkWell(
      onTap: _isDownloading ? null : _downloadAndOpen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 230, maxWidth: 290),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.isMe
              ? primaryColor.withValues(alpha: .12)
              : context.isDarkMode
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .04),
          border: Border.all(
            color: widget.isMe
                ? primaryColor.withValues(alpha: .2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _fileIcon(mimeType),
              size: 36,
              color: widget.isMe ? primaryColor : secondaryColor,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Text(
                        _fileTypeLabel(mimeType),
                        style: context.captionText?.copyWith(
                          color: secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (message.mediaBytes != null) ...[
                        Text(
                          '  •  ',
                          style: context.captionText?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                        Text(
                          _formatBytes(message.mediaBytes!),
                          style: context.captionText?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            _isDownloading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: widget.isMe ? primaryColor : secondaryColor,
                    ),
                  )
                : Icon(
                    Icons.download_for_offline_outlined,
                    size: 22,
                    color: widget.isMe ? primaryColor : secondaryColor,
                  ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(String mimeType) {
    final lower = mimeType.toLowerCase();

    if (lower == 'application/pdf') {
      return Icons.picture_as_pdf;
    }

    if (lower.contains('word') ||
        lower.contains('document') ||
        lower.contains('msword')) {
      return Icons.description;
    }

    if (lower.contains('zip') ||
        lower.contains('rar') ||
        lower.contains('compressed')) {
      return Icons.folder_zip;
    }

    if (lower.contains('excel') || lower.contains('spreadsheet')) {
      return Icons.table_chart;
    }

    if (lower.contains('audio')) {
      return Icons.audio_file;
    }

    if (lower.contains('video')) {
      return Icons.video_file;
    }

    if (lower.contains('android')) {
      return Icons.android;
    }

    return Icons.insert_drive_file;
  }

  String _fileTypeLabel(String mimeType) {
    final lower = mimeType.toLowerCase();

    if (lower == 'application/pdf') return 'PDF';

    if (lower.contains('word') ||
        lower.contains('document') ||
        lower.contains('msword')) {
      return 'Doc';
    }

    if (lower.contains('zip')) return 'ZIP';

    if (lower.contains('rar')) return 'RAR';

    if (lower.contains('excel') || lower.contains('spreadsheet')) {
      return 'Sheet';
    }

    if (lower.contains('audio')) return 'Audio';

    if (lower.contains('video')) return 'Video';

    if (lower.contains('android')) return 'APK';

    return 'File';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
