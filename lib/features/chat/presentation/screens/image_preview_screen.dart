import 'dart:io';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/models/media_type.dart';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key, required this.imageFile});

  final File imageFile;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.pop(
      context,
      MediaDraft(
        file: widget.imageFile,
        type: MediaType.image,
        caption: _captionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------
            // FIXED PREVIEW REGION
            // ----------------------------------------------------------
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.file(
                          widget.imageFile,
                          fit: BoxFit.contain,

                          // Keep the image constrained to the preview
                          // region instead of allowing its intrinsic
                          // dimensions to affect the Column layout.
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,

                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ----------------------------------------------------------
            // CAPTION
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: 'Add a caption...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),

            // ----------------------------------------------------------
            // NEXT
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: _continue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
