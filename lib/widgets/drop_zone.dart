import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/localizations.dart';

class DropZone extends StatefulWidget {
  final AppLocalizations loc;
  final VoidCallback onTap;
  final ValueChanged<List<PlatformFile>> onFilesDropped;

  const DropZone(
    this.loc, {
    required this.onTap,
    required this.onFilesDropped,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  bool _isCompressedFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    const compressedExtensions = [
      'zip',
      'rar',
      '7z',
      'tar',
      'gz',
      'bz2',
      'xz',
      'z',
      'cab',
      'iso',
      'dmg',
      'pkg',
      'deb',
      'rpm',
    ];
    return compressedExtensions.contains(extension);
  }

  Future<void> _showInvalidFileDialog() async {
    final loc = AppLocalizations.of(context);
    await showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(loc.t('invalid_file')),
        content: Text(loc.t('not_compressed')),
        actions: [
          CupertinoDialogAction(
            child: Text(loc.t('ok')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _validateAndSetFiles(List<PlatformFile> files) async {
    if (files.isEmpty) return;

    if (kDebugMode) {
      debugPrint('Validating ${files.length} files');
      for (var file in files) {
        debugPrint('File: ${file.name}, isCompressed: ${_isCompressedFile(file.name)}');
      }
    }

    // Verificar se todos os arquivos são comprimidos
    final invalidFiles = files.where((file) => !_isCompressedFile(file.name)).toList();

    if (invalidFiles.isNotEmpty) {
      if (kDebugMode) debugPrint('Invalid files found: ${invalidFiles.length}');
      await _showInvalidFileDialog();
      return;
    }

    if (kDebugMode) debugPrint('All files valid, calling onFilesDropped');
    widget.onFilesDropped(files);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() => _isDragging = false);
        final paths = detail.files.map((file) => file.path).toList();
        if (paths.isNotEmpty) {
          final files = paths.map((path) {
            try {
              final file = File(path);
              final stat = file.statSync();
              return PlatformFile(
                path: path,
                name: path.split(Platform.pathSeparator).last,
                size: stat.size,
              );
            } catch (e) {
              if (kDebugMode) debugPrint('Error reading file: $e');
              return null;
            }
          }).whereType<PlatformFile>().toList();
          
          await _validateAndSetFiles(files);
        }
      },
      onDragEntered: (detail) {
        setState(() => _isDragging = true);
      },
      onDragExited: (detail) {
        setState(() => _isDragging = false);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (kDebugMode) debugPrint('Drop zone tapped');
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: _isDragging
                  ? const LinearGradient(
                      colors: [Color(0xFF2B2140), Color(0xFF3B3150)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF1B1730), Color(0xFF2B2140)],
                    ),
              border: _isDragging
                  ? Border.all(
                      color: const Color(0xFF1AA0A8).withValues(alpha: 0.5),
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _isDragging
                      ? const Color(0xFF1AA0A8).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              ],
            ),
            child: Center(
              child: Container(
                width: 240,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDragging
                        ? const Color(0xFF1AA0A8)
                        : Colors.white24,
                    width: _isDragging ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isDragging
                          ? CupertinoIcons.arrow_down_circle_fill
                          : CupertinoIcons.folder,
                      size: 48,
                      color: _isDragging
                          ? const Color(0xFF1AA0A8)
                          : Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.loc.t('drop_files'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _isDragging ? 18 : 16,
                        color: _isDragging
                            ? const Color(0xFF1AA0A8)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.loc.t('or_browse'),
                      style: TextStyle(
                        color: _isDragging
                            ? const Color(0xFF1AA0A8).withValues(alpha: 0.8)
                            : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

