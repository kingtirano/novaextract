import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/localizations.dart';

class FileDetails extends StatelessWidget {
  final AppLocalizations loc;
  final PlatformFile? file;
  final bool enabled;
  final VoidCallback? onExtract;
  final VoidCallback? onClear;
  final int fileCount;

  const FileDetails(
    this.loc,
    this.file,
    this.enabled, {
    this.onExtract,
    this.onClear,
    this.fileCount = 0,
  });

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

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0D1116) : const Color(0xFFFFFFFF);
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;
    
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardColor,
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.1),
              blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.t('file_details'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              )),
          const SizedBox(height: 16),
          DetailRow(loc.t('name'), file?.name ?? '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          DetailRow(loc.t('type'), file != null ? _ext(file!.name) : '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          DetailRow(
              loc.t('size'),
              file != null
                  ? '${(file!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                  : '-',
              textColor: textColor,
              secondaryTextColor: secondaryTextColor),
          DetailRow(loc.t('location'), file?.path ?? '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          DetailRow(
            loc.t('contains'),
            fileCount > 0
                ? '$fileCount ${loc.t('files_count')}'
                : file != null && _isCompressedFile(file!.name)
                    ? loc.t('loading')
                    : '-',
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          const Spacer(),
          if (onClear != null && file != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(14),
                    onPressed: onClear,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.clear_circled,
                          size: 18,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.t('clear'),
                          style: TextStyle(
                            color: isDark ? CupertinoColors.white : CupertinoColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: MouseRegion(
              cursor: enabled && onExtract != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: CupertinoButton.filled(
                color: const Color(0xFF1AA0A8),
                borderRadius: BorderRadius.circular(14),
                disabledColor: CupertinoColors.systemGrey,
                onPressed: enabled && onExtract != null ? onExtract : null,
                child: Text(
                  loc.t('extract'),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _ext(String name) =>
      name.contains('.') ? '.${name.split('.').last.toUpperCase()}' : '-';
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;
  final Color? secondaryTextColor;

  const DetailRow(
    this.label,
    this.value, {
    this.textColor,
    this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? CupertinoColors.white;
    final defaultSecondaryColor = secondaryTextColor ?? Colors.white54;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                color: defaultSecondaryColor,
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontWeight: FontWeight.w600,
            color: defaultTextColor,
          )),
        ],
      ),
    );
  }
}

