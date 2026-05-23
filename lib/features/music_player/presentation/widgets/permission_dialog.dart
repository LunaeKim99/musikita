import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialog {
  static Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      Permission permission;
      if (androidInfo.version.sdkInt >= 33) {
        permission = Permission.audio;
      } else if (androidInfo.version.sdkInt == 30 || androidInfo.version.sdkInt == 31 || androidInfo.version.sdkInt == 32) {
        permission = Permission.manageExternalStorage;
      } else {
        permission = Permission.storage;
      }

      final status = await permission.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          final shouldOpen = await _showSettingsRedirectDialog(context);
          if (shouldOpen) {
            await openAppSettings();
          }
        }
        return false;
      }
      
      if (context.mounted) {
        final shouldRequest = await _showPermissionExplanationDialog(context);
        if (shouldRequest) {
          final newStatus = await permission.request();
          if (newStatus.isGranted) {
            return true;
          } else if (newStatus.isPermanentlyDenied) {
            if (context.mounted) {
              final shouldOpen = await _showSettingsRedirectDialog(context);
              if (shouldOpen) {
                await openAppSettings();
              }
            }
          }
        }
      }
      return false;
    }
    
    return true;
  }

  static Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Izin Storage Diperlukan'),
            content: const Text(
              'Musikita membutuhkan akses ke storage untuk memindai dan memutar file musik yang tersimpan di perangkat Anda.\n\n'
              'Tap "Izinkan" untuk memberikan akses.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Izinkan'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> _showSettingsRedirectDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Izin Ditolak'),
            content: const Text(
              'Izin storage ditolak permanen.\n\n'
              'Anda dapat mengaktifkan izin melalui Settings:\n'
              'Settings → Apps → Musikita → Permissions',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buka Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
