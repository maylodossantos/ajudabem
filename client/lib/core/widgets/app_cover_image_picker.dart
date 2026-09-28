import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../stores/image_upload_store.dart';
import 'app_image_picker.dart';

class AppCoverImagePicker extends StatelessWidget {
  const AppCoverImagePicker({required this.store, super.key});

  final ImageUploadStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final imageUrl = store.imageUrl;
        final hasImage = imageUrl != null && imageUrl.isNotEmpty;
        final isUploading = store.isUploading;

        return GestureDetector(
          onTap: isUploading
              ? null
              : () => pickAndUploadGalleryImage(context, store),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : hasImage
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adicionar capa',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
