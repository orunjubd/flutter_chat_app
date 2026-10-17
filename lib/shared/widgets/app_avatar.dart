import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable avatar widget for displaying a user's profile photo.
///
/// Features:
/// - Displays the user's image when a valid URL is available.
/// - Falls back to the user's initial when the URL is empty or invalid.
/// - Shows the fallback when the image fails to load.
/// - Supports custom radius and background color.
///
/// Usage:
/// AppAvatar(
///   username: 'Solaiman',
///   imageUrl: user.imageUrl,
///   radius: 24,
/// )
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.username,
    this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The name used to generate the fallback initial.
  final String username;

  /// The profile image URL. Null or empty URLs use the fallback initial.
  final String? imageUrl;

  /// The avatar's radius in logical pixels.
  final double radius;

  /// Optional background color for the fallback avatar.
  final Color? backgroundColor;

  /// Optional color for the fallback initial.
  final Color? foregroundColor;

  String get _initial {
    final name = username.trim();
    return name.isEmpty ? '?' : name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl?.trim();

    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        _initial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: foregroundColor ?? theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.85,
        ),
      ),
    );

    // Avoid loading an empty URL, which can cause NetworkImage errors.
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? theme.colorScheme.surface,
          backgroundImage: imageProvider,
        );
      },
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor:
            backgroundColor ??
            theme.colorScheme.primary.withValues(alpha: 0.08),
        child: SizedBox(
          width: radius * 0.7,
          height: radius * 0.7,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => fallback,
    );
  }
}
