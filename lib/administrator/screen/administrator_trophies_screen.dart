import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:dio/dio.dart';

class AdministratorTrophiesScreen extends StatelessWidget {
  AdministratorTrophiesScreen({super.key});

  final MultiImagePickerController _controller = MultiImagePickerController(
    maxImages: 5,
    picker: (count, _) async => await pickImagesUsingImagePicker(count),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Trophies")),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Images selected but not uploaded"),
                  ),
                );
              },
              child: const Text("Confirm Selection (No Upload)"),
            ),
          ),
        ],
      ),
    );
  }
}
