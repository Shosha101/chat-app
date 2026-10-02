import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//Themes
import '../themes/app_theme.dart';

class RoundedImageNetwork extends StatelessWidget {
  final String imagePath;
  final double size;
  // Drawn while the image loads, and instead of it when there is none
  final IconData placeholderIcon;

  const RoundedImageNetwork({
    super.key,
    required this.imagePath,
    required this.size,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: size,
        width: size,
        child: imagePath.startsWith('http')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return frame == null ? _placeholder() : child;
                },
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.primarySoft,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: size * 0.55,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final PlatformFile image;
  final double size;

  const RoundedImageFile({
    super.key,
    required this.image,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.file(
          File(image.path!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: AppColors.primarySoft,
              child: Icon(Icons.broken_image_outlined, color: AppColors.muted),
            );
          },
        ),
      ),
    );
  }
}

class RoundedImageNetworkWithStatusIndicator extends RoundedImageNetwork {
  final bool isActive;

  const RoundedImageNetworkWithStatusIndicator({
    super.key,
    required super.imagePath,
    required super.size,
    super.placeholderIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        super.build(context),
        Container(
          height: size * 0.28,
          width: size * 0.28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.online : AppColors.offline,
            shape: BoxShape.circle,
            // A ring in the page colour separates the dot from the photo
            border: Border.all(color: AppColors.background, width: 2),
          ),
        ),
      ],
    );
  }
}
