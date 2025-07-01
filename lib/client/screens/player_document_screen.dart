import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class PlayerDocumentScreen extends StatefulWidget {
  const PlayerDocumentScreen({required this.player_id, super.key});
  final String player_id;

  @override
  State<PlayerDocumentScreen> createState() => _PlayerDocumentScreenState();
}

class _PlayerDocumentScreenState extends State<PlayerDocumentScreen> {
  final MultiImagePickerController _controller = MultiImagePickerController(
    maxImages: 2,
    picker: (count, _) async => await pickImagesUsingImagePicker(count),
  );

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        centerTitle: true,
        iconTheme: IconThemeData(color: appColors.gray1100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: Text(
          "Documents",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MultiImagePickerView(
              controller: _controller,
              draggable: true,
              addMoreButton: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  size: 32,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
