import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      // For Android 13 (API 33) and above
      if (sdkInt >= 33) {
        final mediaLibraryStatus = await Permission.mediaLibrary.request();
        final photosStatus = await Permission.photos.request();
        return mediaLibraryStatus.isGranted || photosStatus.isGranted;
      }
      
      // For Android 11-12 (API 30-32)
      if (sdkInt >= 30) {
        final manageExternalStatus = await Permission.manageExternalStorage.request();
        if (manageExternalStatus.isGranted) {
          return true;
        }
        
        // Fallback to storage permission
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
      
      // For Android 10 and below
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }
    
    return true; // For non-Android platforms
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt >= 33) {
        return await Permission.mediaLibrary.isGranted || 
               await Permission.photos.isGranted;
      } else if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted || 
               await Permission.storage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    
    return true; // For non-Android platforms
  }
} 