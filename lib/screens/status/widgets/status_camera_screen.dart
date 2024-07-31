import 'dart:io';

import 'package:camera/camera.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:whatsappclone/controller/services/media_service.dart';

import '../../../main.dart';
import '../../../model/media.dart';
import '../../../utils/CGColors.dart';
import '../status_image_preview.dart';

class status_CameraScreen extends StatelessWidget {
  status_CameraScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CameraHome_status();
  }
}

class CameraHome_status extends StatefulWidget {
  CameraHome_status({
    super.key,
  });

  @override
  _CameraHomeState createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome_status> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late CameraController controller;
  bool isShowGallery = true;

  // late Future<List<String>>? _images;
  late PanelController _panelController;
  late String videoPath;
  Future<void>? _initializeControllerFuture;
  bool isFlashOn = false;
  bool isRecording = false;

  // ScrollController for handling scrolling behavior
  final ScrollController _scrollController = ScrollController();

  // AssetPathEntity? _currentAlbum;
  // List<AssetPathEntity> _albums = [];
  final List<Media> recent_medias = [];
  int _lastPage = 0;
  int _currentPage = 0;

  // Permissions
  bool isPermissionsGranted = false;
  List<Permission> permissionsNeeded = [
    Permission.storage,
    Permission.accessMediaLocation,
    Permission.camera,
    Permission.microphone,
    // Permission.manageExternalStorage,
  ];

  @override
  void initState() {
    super.initState();

    log("init  state");

    _panelController = new PanelController();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: true,
    )..prepareForVideoRecording();

    _initializeControllerFuture = controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            log("-----CameraAccessDenied");
            // Handle access errors here.
            break;
          default:
            log("----other camera  errors here");

            // Handle other errors here.
            break;
        }
      }
    });
    initScreen();

    // Load albums when the screen initializes
    _loadAlbums();
    // Add listener to scroll controller for loading more media items
    _scrollController.addListener(_loadMoreMedias);
  }

  // Method to load albums asynchronously
  void _loadAlbums() async {
    // Fetch albums from service
    List<AssetPathEntity> albums = await media_service.fetchAlbums();
    context.read<MediaProvider>().clear_mediass();

    if (albums.isNotEmpty) {
      context.read<MediaProvider>().update_current_album(albums.first);
      context.read<MediaProvider>().update_albums(albums);
      log("alumess are  -----$albums");
      log("alumess are  -----$albums");

      // setState(() {
      //   // Set the first album as the current album
      //   _currentAlbum = albums.first;
      //   // Update the list of albums
      //   _albums = albums;
      //
      // });
      // Load media items for the current album
      _loadMedias();
    }
  }

  // Method to load media items asynchronously
  void _loadMedias() async {
    // Store the current page as the last page
    _lastPage = _currentPage;
    if (context.read<MediaProvider>().currentAlbum != null) {
      // Fetch media items for the current album
      List<Media> medias =
          await media_service.fetchMedias(album: context.read<MediaProvider>().currentAlbum!, page: _currentPage);
      log("medissssssaaaaaaaaaaa are  -----$medias");
      context.read<MediaProvider>().update_media(medias);
      if (context.read<MediaProvider>().currentAlbum == context.read<MediaProvider>().albums.first) {
        List<Media> medias =
            await media_service.fetchMedias(album: context.read<MediaProvider>().currentAlbum!, page: _currentPage);
        setState(() {
          recent_medias.clear();

          // Add fetched media items to the list
          recent_medias.addAll(medias);
        });
      }
    }
  }

  // Method to load more media items when scrolling
  void _loadMoreMedias() {
    if (_scrollController.position.pixels / _scrollController.position.maxScrollExtent > 0.15) {
      // Check if scrolled beyond 33% of the scroll extent
      if (_currentPage != _lastPage) {
        // Load more media items
        _loadMedias();
      }
    }
  }

  void initScreen() async {
    if (await allPermissionsGranted()) {
      setState(() {
        isPermissionsGranted = true;
      });
      startCamera();
    } else {
      requestPermission();
    }
  }

  Future<void> startCamera() async {
    log("start camera");

    // _initCamera(_cameraIndex);
    // _getGalleryImages();
  }

  Future<void> refreshGallery() async {
    log("refreshing gallery-------  screen");
    _loadAlbums();
    // _getGalleryImages();
  }

  @override
  void dispose() {
    _disposeCamera();
    // Remove listener to avoid memory leaks
    _scrollController.removeListener(_loadMoreMedias);
    // Dispose scroll controller
    _scrollController.dispose();
    recent_medias.clear();
    // context.read<MediaProvider>().clear_mediass();
    super.dispose();
  }

  _disposeCamera() async {
    if (controller != null) {
      await controller.dispose();
    }
  }

  Widget _cameraPreviewWidget() {
    if (!controller.value.isInitialized) {
      return const Center(
        child: Text(
          '',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            // _minHeight = 0;
            isShowGallery = !isShowGallery;
          });
        },
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(builder: (context, constraints) {
                const double aspectRatio = 9 / 16;
                return ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                        width: constraints.maxWidth,
                        height: constraints.maxWidth / aspectRatio - 130,
                        child: CameraPreview(controller),
                      ),
                    ),
                  ),
                );
              });
            } else {
              return Container();
            }
          },
        ),
      );
    }
  }

  double _opacity = 0.0;
  final double _minHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        if (_panelController.isPanelOpen) {
          _panelController.close();
          return Future.value(false); // Do not switch tab yet
          // Prevent immediate
        } else {
          Navigator.pop(context);
          // return Future.value(true); // switch tab
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              SlidingUpPanel(
                controller: _panelController,
                maxHeight: MediaQuery.of(context).size.height,
                minHeight: _minHeight,
                panel: Opacity(
                  opacity: _opacity,
                  child: Scaffold(
                    appBar: AppBar(
                      elevation: 0.0,
                      backgroundColor: textFieldBackground,
                      leading: IconButton(
                        color: secondaryColor,
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          _panelController.close();
                        },
                      ),
                      title: DropdownButton<AssetPathEntity>(
                        // alignment: AlignmentDirectional.bottomEnd,
                        borderRadius: BorderRadius.circular(16.0),
                        value: mediaProvider.currentAlbum,
                        items: mediaProvider.albums
                            .map(
                              (e) => DropdownMenuItem<AssetPathEntity>(
                                value: e,
                                // Display album name in dropdown
                                child: Text(e.name.isEmpty ? "0" : e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (AssetPathEntity? value) {
                          setState(() {
                            // Reset current page to load from the beginning
                            _currentPage = 0;
                            // Reset last page
                            _lastPage = 0;
                          });
                          // Set the selected album as the current album

                          mediaProvider.update_current_album(value);
                          // Clear existing media items

                          mediaProvider.clear_mediass();
                          // Load media items for the selected album
                          _loadMedias();
                          // Scroll to the top
                          _scrollController.jumpTo(0.0);
                        },
                      ),
                    ),
                    body: MediasGridView(
                      // Pass the list of media items to the grid view
                      medias: mediaProvider.medias,
                      // Pass the list of selected media items to the grid view
                      // selectedMedias: _selectedMedias,
                      // Pass the method to select or deselect a media item
                      // selectMedia: _selectMedia,
                      // Pass the scroll controller to the grid view
                      scrollController: _scrollController,
                    ),
                  ),
                ),
                // panel: Container(),
                color: Color.fromARGB(0, 0, 0, 0),
                collapsed: isShowGallery ? _buildCollapsedPanel() : Container(),
                body: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller != null && controller.value.isRecordingVideo ? Colors.red : Colors.black,
                      width: 2.0,
                    ),
                    color: Colors.black,
                  ),
                  child: _cameraPreviewWidget(),
                ),
                onPanelSlide: (double pos) {
                  setState(() {
                    _opacity = pos;
                  });
                },
              ),
              Positioned(
                bottom: 8.0,
                child: Opacity(
                    opacity: 1 - _opacity,
                    child: Column(
                      children: <Widget>[
                        _buildCameraControls(),
                        Container(
                            child: const Text(
                          'Hold for video, tap for photo',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ))
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedPanel() {
    return Container(
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.keyboard_arrow_up,
            color: Colors.white,
          ),
          _buildGalleryItems(),
        ],
      ),
    );
  }

  Future<List<Media>> convertMediaListToFuture(List<Media> mediaList) {
    List<AssetEntity> assetList = [];
    mediaList.forEach((media) {
      assetList.add(media.assetEntity);
    });
    // mediaList.map((media) => media.assetEntity.tolist());
    return Future.value(mediaList);
  }

  Widget _buildGalleryItems() {
    // final mediaProvider = Provider.of<MediaProvider>(context);
    // late final Future<Uint8List?> assetFuture = loadAssetThumbnail();

    return Container(
      height: 88.0,
      child: FutureBuilder<List<Media>>(
          future: convertMediaListToFuture(recent_medias),
          builder: (BuildContext context, AsyncSnapshot<List<Media>> snapshot) {
            if (!isPermissionsGranted) {
              return const Center(
                child: Text(
                  'Permission not granted',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Container();
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Container();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.data!.length <= 0) return Container();
                // List<String> displayedData = snapshot.data!.sublist(0, 10);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemCount: snapshot.data!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    //print(snapshot.data[i]);
                    // return GalleryItemThumbnail(
                    //   heroId: 'item-$i',
                    //   margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    //   height: 89,
                    //   resource: snapshot.data![i],
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => EditImageScreen(
                    //           id: 'item-$i',
                    //           resource: snapshot.data![i],
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                    // final thumb = snapshot.data![i].thumbnailData;
                    return InkWell(
                      onTap: () async {
                        final file = await snapshot.data![i].assetEntity.file;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatusImageConfirmPage(
                              file: file!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 120,
                        width: 100,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        child: MediaItem(
                          media: snapshot.data![i],
                          ind: i,
                        ),
                      ),
                    );
                  },
                );
            }
            // return SizedBox();
          }),
    );
  }

  Future<bool> allPermissionsGranted() async {
    bool resVideo = await Permission.camera.isGranted;
    bool resAudio = await Permission.microphone.isGranted;
    bool aesAudio = await Permission.accessMediaLocation.isGranted;
    bool mesAudio = await Permission.manageExternalStorage.isGranted;
    return resVideo && resAudio && aesAudio;
  }

  void requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await permissionsNeeded.request();
    if (statuses.values.every((status) => status == PermissionStatus.granted)) {
      // Either the permission was already granted before or the user just granted it.
      setState(() {
        isPermissionsGranted = true;
      });
      startCamera();
    } else {
      snackBar(context, title: 'Permission not granted', duration: const Duration(seconds: 3));
    }
  }

  void toggleFlash() async {
    if (controller != null) {
      isFlashOn = !isFlashOn;
      setState(() {});
      await controller?.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    }
  }

  void _toggleCamera() async {
    if (controller != null) {
      await controller?.dispose(); // Dispose of the current controller

      final newIndex = (cameras.indexOf(controller!.description) + 1) % cameras.length;
      final newCamera = cameras[newIndex];

      controller = CameraController(
        newCamera,
        ResolutionPreset.max,
      );

      _initializeControllerFuture = controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              log("-----CameraAccessDenied");
              // Handle access errors here.
              break;
            default:
              log("----other camera  errors here");

              // Handle other errors here.
              break;
          }
        }
      });

      setState(() {});
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<File> saveImage(XFile image) async {
    // final downlaodPath = await ExternalPath.getExternalStoragePublicDirectory(
    //     ExternalPath.DIRECTORY_DOWNLOADS);

    final String dirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
    // final directory = await getExternalStorageDirectory().;
    final customDirectory = Directory('${dirPath}/whatsapp_CLone');
    if (!await customDirectory.exists()) {
      await customDirectory.create(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final file = File('${customDirectory.path}/$fileName');
    try {
      await file.writeAsBytes(await image.readAsBytes());
      // MediaScanner.loadMedia(path: file.path);
    } catch (_) {}
    return file;
  }

  Future<String?> _takePicture() async {
    if (!controller.value.isInitialized) {
      snackBar(context, title: 'Error: camera is not initialized', duration: const Duration(seconds: 1));
    }

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await _initializeControllerFuture;

      XFile? image = await controller.takePicture();
      final filePath = await saveImage(image);

      // Forcing media scan by invoking a platform-specific method
      const platform = MethodChannel('com.example.whatsappclone/media_scan');
      try {
        await platform.invokeMethod('scanFile', {'path': filePath.path});
        log("succesfully  invoked media scanner: ''.");
      } on PlatformException catch (e) {
        log("Failed to invoke media scanner: '${e.message}'.");
      }

      return filePath.path;
    } on CameraException catch (e) {
      snackBar(context, title: 'Error: ${e.description}', duration: const Duration(seconds: 1));
      return "";
    }
  }

  Future<void> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      snackBar(context, title: 'Error: camera is not initialized', duration: const Duration(seconds: 1));

      return null;
    }
    if (controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await _initializeControllerFuture;

      // videoPath = filePath;
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      snackBar(context, title: 'Error: ${e.description}', duration: const Duration(seconds: 1));

      return null;
    }
    // return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await _initializeControllerFuture;

      final video = await controller.stopVideoRecording();

      final String dirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
      // final directory = await getExternalStorageDirectory().;
      final customDirectory = Directory('${dirPath}/whatsapp_CLone');
      if (!await customDirectory.exists()) {
        await customDirectory.create(recursive: true);
      }
      // final String videoName =
      //     video.name.contains('.mp4') ? video.name : '${video.name}.mp4';

      // final imagePath = '${customDirectory.path}/${videoName}';

      ///use this to also save image
      // await video.saveTo(imagePath);
      //  // String filePath = await _saveImageToGallery(video);
      //   videoPath = imagePath;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';

      final file = File('${customDirectory.path}/$fileName');
      try {
        await file.writeAsBytes(await video.readAsBytes());
        // MediaScanner.loadMedia(path: file.path);
      } catch (_) {}

      videoPath = file.path;
      // Forcing media scan by invoking a platform-specific method
      const platform = MethodChannel('com.example.whatsappclone/media_scan');
      try {
        await platform.invokeMethod('scanFile', {'path': file.path});
        log("succesfully  invoked media scanner: ''.");
      } on PlatformException catch (e) {
        log("Failed to invoke media scanner: '${e.message}'.");
      }
    } on CameraException catch (e) {
      snackBar(context, title: 'Error: ${e.description}', duration: const Duration(seconds: 1));
      return null;
    }

    // await _startVideoPlayer();
  }

  void onTakePictureButtonPressed() {
    _takePicture().then((String? filePath) {
      if (mounted) {
        setState(() {});
        if (filePath != null) {
          if ((filePath.isNotEmpty)) {
            snackBar(context, title: 'Picture saved to $filePath', duration: const Duration(seconds: 3));

            refreshGallery();
          }
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      refreshGallery();

      snackBar(context, title: 'Video recorded to $videoPath', duration: const Duration(seconds: 2));
    });
  }

  Widget _buildCameraControls() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_off : Icons.flash_on,
            ),
            color: Colors.white,
            onPressed: isPermissionsGranted
                ? () {
                    toggleFlash();
                  }
                : null,
          ),
          GestureDetector(
              onTap: isPermissionsGranted
                  ? () {
                      if (controller == null || !controller.value.isInitialized || controller.value.isRecordingVideo)
                        return;
                      onTakePictureButtonPressed();
                    }
                  : null,
              onLongPress: isPermissionsGranted
                  ? () {
                      if (controller == null || !controller.value.isInitialized || controller.value.isRecordingVideo)
                        return;
                      onVideoRecordButtonPressed();
                    }
                  : null,
              onLongPressUp: isPermissionsGranted
                  ? () {
                      if (controller == null || !controller.value.isInitialized || !controller.value.isRecordingVideo)
                        return;
                      onStopButtonPressed();
                    }
                  : null,
              child: const Icon(
                Icons.panorama_fish_eye,
                size: 70.0,
                color: Colors.white,
              )),
          IconButton(
            icon: Icon(Icons.switch_camera),
            color: Colors.white,
            highlightColor: Colors.green,
            splashColor: Colors.red,
            onPressed: isPermissionsGranted
                ? () {
                    _toggleCamera();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// Widget to display a grid of media items
class MediasGridView extends StatelessWidget {
  // List of all media items
  final List<Media> medias;

  // List of selected media items
  // final List<Media> selectedMedias;
  // Callback function to select a media item
  // final Function(Media) selectMedia;
  // Controller for scrolling
  final ScrollController scrollController;

  const MediasGridView({
    // Unique identifier for the widget
    super.key,
    // List of all media items
    required this.medias,
    // List of selected media items
    // required this.selectedMedias,
    // Callback function to select a media item
    // required this.selectMedia,
    // Controller for scrolling
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: 180),
        // Assign the provided scroll controller
        controller: scrollController,
        // Apply bouncing scroll physics
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        // Set the number of items in the grid
        itemCount: medias.length,
        // 3 columns in the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          // Spacing between rows
          mainAxisSpacing: 3,
          // Spacing between columns
          crossAxisSpacing: 3,
        ),
        // Build each media item using the MediaItem widget
        itemBuilder: (context, index) => MediaItem(
          ind: index,
          // Pass the current media item
          media: medias[index],
          // Check if the media item is selected
          // isSelected: selectedMedias.any((element) =>
          //     element.assetEntity.id == medias[index].assetEntity.id),
          // Pass the selectMedia callback function
          // selectMedia: selectMedia,
        ),
      ),
    );
  }
}

// Widget to display a media item with optional selection overlay
class MediaItem extends StatelessWidget {
  // The media to display
  final Media media;
  final int ind;
  // Indicates whether the media is selected
  // final bool isSelected;
  // Callback function when the media is tapped
  // final Function selectMedia;

  // Unique identifier for the widget, passes the key to the super constructor
  const MediaItem({
    required this.media,
    required this.ind,
    // required this.isSelected,
    // required this.selectMedia,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Callback function when the media is tapped
      onTap: () async {
        log("presseddddddddd ${media.assetEntity}");
        final file = await media.assetEntity.file;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatusImageConfirmPage(
              file: file!,
            ),
          ),
        );
        // selectMedia(media);
      },
      child: Stack(
        children: [
          // Display the media widget with optional padding
          _buildMediaWidget(),

          Positioned.fill(
            child: Container(
              // Semi-transparent black overlay
              color: Colors.black.withOpacity(0.15),
              child: media.assetEntity.type == AssetType.video
                  ? const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          // Checkmark icon
                          Icons.play_arrow_rounded,
                          // White color for the icon
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          // Display the selected overlay if the media is selected
          // if (isSelected) _buildIsSelectedOverlay(),
        ],
      ),
    );
  }

  // Build the media widget with optional padding
  Widget _buildMediaWidget() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(0.0),
        // Display the media widget
        child: Hero(tag: 'itemPanel-$ind', child: media.widget),
      ),
    );
  }

  // Build the selected overlay
  Widget _buildIsSelectedOverlay() {
    return Positioned.fill(
      child: Container(
        // Semi-transparent black overlay
        color: Colors.black.withOpacity(0.1),
        child: const Center(
          child: Icon(
            // Checkmark icon
            Icons.check_circle_rounded,
            // White color for the icon
            color: Colors.white,
            // Size of the icon
            size: 30,
          ),
        ),
      ),
    );
  }
}
