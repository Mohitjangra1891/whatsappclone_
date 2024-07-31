import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/media.dart';

class MediaProvider with ChangeNotifier {
  List<AssetEntity> _mediaList = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _lastPage = 0;

  bool _hasMore = true;
  AssetPathEntity? currentAlbum;
  List<AssetPathEntity> albums = [];
  List<Media> medias = [];
  // List<Media> recent_medias = [];

  List<AssetEntity> get mediaList => _mediaList;
  bool get isLoading => _isLoading;

  void update_albums(List<AssetPathEntity> album_list) {
    albums = album_list;
    notifyListeners();
  }

  void update_current_album(AssetPathEntity? currentAlbumaa) {
    currentAlbum = currentAlbumaa;
    notifyListeners();
  }

  void update_media(List<Media> media_list) {
    medias.addAll(media_list);
    notifyListeners();
  }

  void clear_mediass() {
    medias.clear();
    notifyListeners();
  }

  MediaProvider() {
    // fetchMedia();
  }
  // Future<void> fetchMedia() async {
  //   if (_isLoading || !_hasMore) return;
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   final result = await PhotoManager.requestPermissionExtend();
  //   if (result.isAuth) {
  //     final List<AssetPathEntity> albumss = await PhotoManager.getAssetPathList(
  //       type: RequestType.common,
  //     );
  //     currentAlbum = albumss.first;
  //     // Update the list of albums
  //     albums = albumss;
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //     log("alumess are  -----$albums");
  //
  //     notifyListeners();
  //
  //     if (albums.isNotEmpty) {
  //       final List<AssetEntity> media = await currentAlbum!.getAssetListPaged(
  //         page: _currentPage,
  //         size: 20,
  //       );
  //       _mediaList.addAll(media);
  //       log("mediaaaaaaaaa are  -----${_mediaList.toString()}");
  //       log("mediaaaaaaaaa are  -----$_mediaList");
  //       log("mediaaaaaaaaa are  -----$_mediaList");
  //       log("mediaaaaaaaaa are  -----$_mediaList");
  //
  //       _currentPage++;
  //       _hasMore = media.length == 20;
  //     }
  //   }
  //   _isLoading = false;
  //   notifyListeners();
  // }
}

class media_service {
  // Function to request and handle permissions for accessing videos and photos
  static Future<void> grantPermissions() async {
    try {
      // Check if permissions are already granted
      final bool videosGranted = await Permission.videos.isGranted;
      final bool photosGranted = await Permission.photos.isGranted;

      // If permissions are not granted, request them
      if (!photosGranted || !videosGranted) {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.videos,
          Permission.photos,
        ].request();

        // If permissions are permanently denied, open app settings
        if (statuses[Permission.videos] == PermissionStatus.permanentlyDenied ||
            statuses[Permission.photos] == PermissionStatus.permanentlyDenied) {
          // Open app settings to allow users to grant permissions
          await openAppSettings();
        }
      }
    } catch (e) {
      // Handle any exceptions that occur during permission handling
      debugPrint('Error granting permissions: $e');
    }
  }

// Function to fetch albums while ensuring necessary permissions are granted
  static Future<List<AssetPathEntity>> fetchAlbums() async {
    try {
      // Ensure permissions are granted before fetching albums
      await grantPermissions();
      // Customize your own filter options.
      final PMFilter filter = FilterOptionGroup(
        videoOption: const FilterOption(
            // sizeConstraint: SizeConstraint(ignoreSize: true),
            durationConstraint: DurationConstraint(max: Duration(minutes: 15))),
      );
      // Fetch the list of asset paths (albums)
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(hasAll: true, onlyAll: false, filterOption: filter);

      return albums;
    } catch (e) {
      // Handle any exceptions that occur during album fetching
      debugPrint('Error fetching albums: $e');
      // Return an empty list if an error occurs
      return [];
    }
  }

// Function to fetch media items from a specific album and page
  static Future<List<Media>> fetchMedias({
    required AssetPathEntity album, // The album from which to fetch media
    required int page, // The page number of media to fetch
  }) async {
    List<Media> medias = []; // List to hold fetched media items

    try {
      // Get a list of asset entities from the specified album and page
      final List<AssetEntity> entities = await album.getAssetListPaged(page: page, size: 50);

      // Loop through each asset entity and create corresponding Media objects
      for (AssetEntity entity in entities) {
        // Assign the asset entity to the Media object
        Media media = Media(
          assetEntity: entity,
          // Create a FadeInImage widget to display the media thumbnail
          widget: FadeInImage(
            // Placeholder image
            placeholder: MemoryImage(kTransparentImage),
            // Set the fit mode to cover
            fit: BoxFit.cover,
            // Use AssetEntityImageProvider to load the media thumbnail
            image: AssetEntityImageProvider(
              entity,
              // Thumbnail size
              thumbnailSize: const ThumbnailSize.square(500),
              // Load a non-original (thumbnail) image
              isOriginal: false,
            ),
          ),
        );
        // Add the created Media object to the list
        medias.add(media);
      }
    } catch (e) {
      // Handle any exceptions that occur during fetching
      debugPrint('Error fetching media: $e');
    }

    // Return the list of fetched media items
    return medias;
  }
}
