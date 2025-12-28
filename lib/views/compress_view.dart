import 'dart:io';
import 'package:archive/archive.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/localizations.dart';

class CompressView extends StatefulWidget {
  final AppLocalizations loc;
  final Brightness currentBrightness;

  const CompressView(
    this.loc, {
    required this.currentBrightness,
  });

  @override
  State<CompressView> createState() => _CompressViewState();
}

class _CompressViewState extends State<CompressView> {
  List<PlatformFile> _selectedFiles = [];
  bool _isCompressing = false;
  double _compressionProgress = 0.0;
  String _currentFile = '';
  bool _isDragging = false;
  String _archiveType = 'zip'; // zip, tar, tar.gz, tar.bz2
  final TextEditingController _archiveNameController = TextEditingController();
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _archiveNameController.text = 'archive_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _archiveNameController.dispose();
    super.dispose();
  }

  void _handleDrop(List<String?> paths) {
    setState(() {
      _isDragging = false;
    });

    final validPaths = paths.whereType<String>().toList();
    final files = validPaths.map((path) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          return PlatformFile(
            path: path,
            name: path.split(Platform.pathSeparator).last,
            size: file.lengthSync(),
          );
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error processing dropped file $path: $e');
      }
      return null;
    }).whereType<PlatformFile>().toList();

    if (files.isNotEmpty && mounted) {
      setState(() {
        _selectedFiles.addAll(files);
      });
    }
  }

  Future<void> _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null && mounted) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error selecting files: $e');
    }
  }

  Future<void> _selectOutputLocation() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: widget.loc.t('select_output_location'),
    );
    if (path != null && mounted) {
      setState(() {
        _outputPath = path;
      });
    }
  }

  Future<void> _compressFiles() async {
    if (_selectedFiles.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(widget.loc.t('compression_failed')),
          content: Text('Please select at least one file to compress.'),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.loc.t('ok')),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (_archiveNameController.text.trim().isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(widget.loc.t('compression_failed')),
          content: Text('Please enter an archive name.'),
          actions: [
            CupertinoDialogAction(
              child: Text(widget.loc.t('ok')),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    if (_outputPath == null) {
      await _selectOutputLocation();
      if (_outputPath == null) {
        return; // Usuário cancelou
      }
    }

    final outputPath = _outputPath!;

    // Mostrar diálogo de progresso
    StateSetter? progressSetState;
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            progressSetState = setState;
            return CupertinoAlertDialog(
              title: Text(widget.loc.t('compressing')),
              content: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentFile.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _currentFile,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _compressionProgress,
                        backgroundColor: CupertinoColors.systemGrey4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1AA0A8),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_compressionProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    try {
      setState(() {
        _isCompressing = true;
        _compressionProgress = 0.0;
      });

      // Criar arquivo de acordo com o tipo selecionado
      final archive = Archive();
      final totalFiles = _selectedFiles.length;
      int processedFiles = 0;

      for (final file in _selectedFiles) {
        if (file.path == null) continue;

        try {
          final fileData = File(file.path!);
          if (await fileData.exists()) {
            final bytes = await fileData.readAsBytes();
            final archiveFile = ArchiveFile(
              file.name,
              bytes.length,
              bytes,
            );
            archive.addFile(archiveFile);

            processedFiles++;
            _compressionProgress = processedFiles / totalFiles;
            _currentFile = file.name;

            if (progressSetState != null) {
              progressSetState!(() {});
            }
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error adding file ${file.name}: $e');
        }
      }

      // Codificar o arquivo de acordo com o tipo
      List<int> archiveData;
      String fileExtension;
      String fileName = _archiveNameController.text.trim();

      switch (_archiveType) {
        case 'zip':
          final zipEncoder = ZipEncoder();
          final zipData = zipEncoder.encode(archive);
          if (zipData == null) {
            throw Exception('Failed to encode ZIP file');
          }
          archiveData = zipData;
          fileExtension = 'zip';
          break;
        case 'tar':
          final tarEncoder = TarEncoder();
          archiveData = tarEncoder.encode(archive);
          fileExtension = 'tar';
          break;
        case 'tar.gz':
          final tarEncoder = TarEncoder();
          final tarData = tarEncoder.encode(archive);
          final gzipEncoder = GZipEncoder();
          final gzipData = gzipEncoder.encode(tarData);
          if (gzipData == null) {
            throw Exception('Failed to encode GZIP file');
          }
          archiveData = gzipData;
          fileExtension = 'tar.gz';
          break;
        case 'tar.bz2':
          final tarEncoder = TarEncoder();
          final tarData = tarEncoder.encode(archive);
          final bzip2Encoder = BZip2Encoder();
          final bzip2Data = bzip2Encoder.encode(tarData);
          if (bzip2Data == null) {
            throw Exception('Failed to encode BZIP2 file');
          }
          archiveData = bzip2Data;
          fileExtension = 'tar.bz2';
          break;
        default:
          throw Exception('Unsupported archive type');
      }

      // Garantir que o nome do arquivo tenha a extensão correta
      if (!fileName.endsWith('.$fileExtension')) {
        fileName = '$fileName.$fileExtension';
      }

      // Salvar o arquivo
      final outputFile = File('$outputPath/$fileName');
      await outputFile.writeAsBytes(archiveData);

      if (mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso

        await showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(widget.loc.t('compression_complete')),
            content: Text('${widget.loc.t('files_compressed_successfully')}\n\n$fileName'),
            actions: [
              CupertinoDialogAction(
                child: Text(widget.loc.t('ok')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );

        // Limpar arquivos selecionados
        setState(() {
          _selectedFiles = [];
          _isCompressing = false;
          _compressionProgress = 0.0;
          _currentFile = '';
          _outputPath = null;
          _archiveNameController.text = 'archive_${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error compressing files: $e');

      if (mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso

        await showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(widget.loc.t('compression_failed')),
            content: Text('${widget.loc.t('error_compressing')}: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text(widget.loc.t('ok')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );

        setState(() {
          _isCompressing = false;
          _compressionProgress = 0.0;
          _currentFile = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentBrightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF0D1116) : const Color(0xFFFFFFFF);
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.loc.t('compress_files'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              // Área de seleção de arquivos com drag and drop
              DropTarget(
                onDragDone: (detail) {
                  _handleDrop(detail.files.map((f) => f.path).whereType<String?>().toList());
                },
                onDragEntered: (detail) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onDragExited: (detail) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                child: GestureDetector(
                  onTap: _isCompressing ? null : _selectFiles,
                  child: MouseRegion(
                    cursor: _isCompressing
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? (isDark
                                ? const Color(0xFF1AA0A8).withValues(alpha: 0.1)
                                : const Color(0xFF1AA0A8).withValues(alpha: 0.05))
                            : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isDragging
                              ? const Color(0xFF1AA0A8)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1)),
                          width: _isDragging ? 3 : 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isDragging
                                ? CupertinoIcons.arrow_down_circle_fill
                                : CupertinoIcons.folder_badge_plus,
                            size: 64,
                            color: _isDragging
                                ? const Color(0xFF1AA0A8)
                                : (_isCompressing
                                    ? secondaryTextColor
                                    : const Color(0xFF1AA0A8)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isDragging
                                ? 'Drop files here'
                                : widget.loc.t('drag_files_here'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isDragging
                                  ? const Color(0xFF1AA0A8)
                                  : (_isCompressing ? secondaryTextColor : textColor),
                            ),
                          ),
                          if (_selectedFiles.isNotEmpty && !_isDragging) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'file' : 'files'} selected',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Configurações de compressão
              Row(
                children: [
                  // Nome do arquivo
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CupertinoTextField(
                          controller: _archiveNameController,
                          placeholder: widget.loc.t('enter_archive_name'),
                          style: TextStyle(color: textColor),
                          decoration: const BoxDecoration(),
                          enabled: !_isCompressing,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tipo de arquivo
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isCompressing
                            ? null
                            : () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoActionSheet(
                                    title: Text(widget.loc.t('archive_type')),
                                    actions: [
                                      CupertinoActionSheetAction(
                                        child: Text(widget.loc.t('zip')),
                                        onPressed: () {
                                          setState(() {
                                            _archiveType = 'zip';
                                          });
                                          Navigator.pop(context);
                                        },
                                        isDefaultAction: _archiveType == 'zip',
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(widget.loc.t('tar')),
                                        onPressed: () {
                                          setState(() {
                                            _archiveType = 'tar';
                                          });
                                          Navigator.pop(context);
                                        },
                                        isDefaultAction: _archiveType == 'tar',
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(widget.loc.t('tar_gz')),
                                        onPressed: () {
                                          setState(() {
                                            _archiveType = 'tar.gz';
                                          });
                                          Navigator.pop(context);
                                        },
                                        isDefaultAction: _archiveType == 'tar.gz',
                                      ),
                                      CupertinoActionSheetAction(
                                        child: Text(widget.loc.t('tar_bz2')),
                                        onPressed: () {
                                          setState(() {
                                            _archiveType = 'tar.bz2';
                                          });
                                          Navigator.pop(context);
                                        },
                                        isDefaultAction: _archiveType == 'tar.bz2',
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      child: Text(widget.loc.t('cancel')),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                );
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _archiveType.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 16,
                              color: textColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Localização de saída
              GestureDetector(
                onTap: _isCompressing ? null : _selectOutputLocation,
                child: MouseRegion(
                  cursor: _isCompressing
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.folder,
                          color: _outputPath == null
                              ? secondaryTextColor
                              : const Color(0xFF1AA0A8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _outputPath ?? widget.loc.t('select_output_location'),
                            style: TextStyle(
                              color: _outputPath == null
                                  ? secondaryTextColor
                                  : textColor,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_outputPath != null)
                          Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: const Color(0xFF1AA0A8),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 24),
                // Lista de arquivos selecionados
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final file = _selectedFiles[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.doc,
                                size: 20,
                                color: Color(0xFF1AA0A8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                file.size > 1024 * 1024
                                    ? '${(file.size / 1024 / 1024).toStringAsFixed(1)} MB'
                                    : '${(file.size / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão de comprimir
                SizedBox(
                  width: double.infinity,
                  child: MouseRegion(
                    cursor: _isCompressing
                        ? SystemMouseCursors.basic
                        : SystemMouseCursors.click,
                    child: CupertinoButton.filled(
                      color: const Color(0xFF1AA0A8),
                      borderRadius: BorderRadius.circular(14),
                      disabledColor: CupertinoColors.systemGrey,
                      onPressed: _isCompressing ? null : _compressFiles,
                      child: _isCompressing
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                          : Text(
                              widget.loc.t('compress'),
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

