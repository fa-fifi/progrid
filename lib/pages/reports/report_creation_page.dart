import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progrid/models/providers/reports_provider.dart';
import 'package:progrid/models/providers/towers_provider.dart';
import 'package:progrid/models/providers/user_provider.dart';
import 'package:progrid/models/report.dart';
import 'package:provider/provider.dart';

class ReportCreationPage extends StatefulWidget {
  final String towerId; // id of selected tower

  const ReportCreationPage({super.key, required this.towerId});

  @override
  State<ReportCreationPage> createState() => _ReportCreationPageState();
}

class _ReportCreationPageState extends State<ReportCreationPage> {
  final _notesController = TextEditingController();
  final int _maxNotesLength = 500;
  final int _maxImages = 3; // maximum number of images

  // images
  final List<File> _images = [];
  final _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("You can only upload up to $_maxImages pictures.")),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      try {
        // Request location permission
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status.isPermanentlyDenied
                    ? 'Location permission is permanently denied. Please enable it in settings.'
                    : 'Location permission is required to add location data.'),
                action: status.isPermanentlyDenied
                    ? SnackBarAction(
                        label: 'Settings',
                        onPressed: () => openAppSettings(),
                      )
                    : null,
              ),
            );
          }
          return;
        }

        // get current date/time
        final now = DateTime.now();
        final formattedDateTime =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        // get current device location
        final position = await Geolocator.getCurrentPosition();
        final latitude = position.latitude.toStringAsFixed(6);
        final longitude = position.longitude.toStringAsFixed(6);

        // add watermark
        final watermarkText =
            '$formattedDateTime\nLat: $latitude, Lon: $longitude';
        final bytes = await ImageWatermark.addTextWatermark(
          imgBytes: await pickedFile.readAsBytes(),
          dstX: 20,
          dstY: 120,
          watermarkText: watermarkText,
        );

        // save image with watermark
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/${pickedFile.name}')
            .writeAsBytes(bytes);

        setState(() {
          _images.add(file);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding watermark: $e")),
          );
        }
      }
    }
  }

  // upload to firebase storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      final String fileName =
          DateTime.now().microsecondsSinceEpoch.toString(); // unique filename
      final Reference storageRef =
          FirebaseStorage.instance.ref('towers/${widget.towerId}/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Image upload failed: $e';
    }
  }

  Future<void> _createReport() async {
    if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final towersProvider = Provider.of<TowersProvider>(context, listen: false);
    final reportsProvider =
        Provider.of<ReportsProvider>(context, listen: false);

    // upload images to Firebase and get URLs
    final List<String> imageUrls = [];
    for (final File image in _images) {
      final String imageUrl = await _uploadImage(image);
      imageUrls.add(imageUrl);
    }

    // create new report instance
    final report = Report(
      dateTime: Timestamp.now(),
      authorId: userProvider.userId,
      notes: _notesController.text,
      images: imageUrls,
    );

    // TODO: fix
    try {
      // add report to report provider and associated list
      await reportsProvider.addReport(widget.towerId, report);

      // update associated tower status to 'in progress'
      await towersProvider.updateTowerStatus(widget.towerId, 'in-progress');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Report Created Successfully!"),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating report: $e")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.towerId, // replace with instancing?
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          children: [
            Column(
              children: [
                // pictures upload section
                Expanded(
                  child: Container(
                    height: 150,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    child: Stack(
                      children: [
                        // picture gallery
                        ListView.builder(
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: 400,
                                      ),
                                      child: Image.file(
                                        _images[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.7),
                                        ),
                                        padding: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // grid implementation
                        // GridView.builder(
                        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        //   itemCount: _images.length,
                        //   itemBuilder: (context, index) {
                        //     return ClipRRect(
                        //       borderRadius: BorderRadius.circular(10),
                        //       child: Image.file(
                        //         _images[index],
                        //         fit: BoxFit.cover,
                        //       ),
                        //     );
                        //   },
                        // ),

                        // button controls
                        Positioned(
                          bottom: 10,
                          right: 0,
                          child: Row(
                            children: [
                              FloatingActionButton(
                                heroTag: 'camera',
                                onPressed: () => _pickImage(ImageSource.camera),
                                child: Icon(Icons.camera_alt),
                                mini: true,
                              ),
                              SizedBox(width: 2),
                              FloatingActionButton(
                                heroTag: 'gallery',
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                child: Icon(Icons.photo),
                                mini: true,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // notes text field
                SizedBox(
                  height: 200, // control text box height here
                  child: TextField(
                    controller: _notesController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    maxLength: _maxNotesLength,
                    buildCounter: (context,
                        {required currentLength,
                        maxLength,
                        required isFocused}) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$currentLength/$maxLength',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Notes',
                      alignLabelWithHint: true,
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _createReport(),
                  child: Text("Create Report"),
                ),
                const SizedBox(height: 20),
              ],
            ),

            // loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
