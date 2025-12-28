import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/localizations.dart';

// Models
import '../models/extraction_history.dart';
import '../models/archive_file.dart';

// Widgets
import '../widgets/sidebar.dart';
import '../widgets/drop_zone.dart';
import '../widgets/file_details.dart';

// Views
import 'history_view.dart';
import 'settings_view.dart';
import 'compress_view.dart';

class MyHomePage extends ConsumerStatefulWidget {
  final ValueChanged<Locale?>? onLocaleChanged;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final Brightness currentBrightness;
  const MyHomePage({
    super.key,
    this.onLocaleChanged,
    this.onBrightnessChanged,
    this.currentBrightness = Brightness.dark,
  });

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  List<PlatformFile> _files = [];
  int _selected = -1;
  List<ArchiveFileModel> _archiveFiles = [];
  bool _isLoadingArchive = false;
  int _currentView = 0; // 0 = Home, 1 = History, 2 = Settings, 3 = Compress
  List<ExtractionHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('extraction_history') ?? [];
    setState(() {
      _history = historyJson
          .map((json) => ExtractionHistory.fromJson(json))
          .toList()
        ..sort((a, b) => b.extractedAt.compareTo(a.extractedAt));
    });
  }

  Future<void> _saveHistory(ExtractionHistory entry) async {
    final prefs = await SharedPreferences.getInstance();
    _history.insert(0, entry);
    _history.sort((a, b) => b.extractedAt.compareTo(a.extractedAt));
    // Manter apenas os últimos 50 registros
    if (_history.length > 50) {
      _history = _history.take(50).toList();
    }
    final historyJson = _history.map((e) => e.toJson()).toList();
    await prefs.setStringList('extraction_history', historyJson);
    setState(() {});
  }

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

  Future<void> _showInvalidFileDialog(BuildContext context, AppLocalizations loc) async {
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

  Future<void> _validateAndSetFiles(
    List<PlatformFile> files,
    BuildContext context,
    AppLocalizations loc,
  ) async {
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
      await _showInvalidFileDialog(context, loc);
      return;
    }

    if (mounted) {
      if (kDebugMode) debugPrint('All files valid, setting state');
      setState(() {
        _files = files;
        _selected = _files.isNotEmpty ? 0 : -1;
        _archiveFiles = [];
      });
      // Carregar conteúdo do arquivo selecionado
      if (_selected >= 0 && _files.isNotEmpty) {
        _loadArchiveContents(_files[_selected]);
      }
    }
  }

  Future<void> _loadArchiveContents(PlatformFile file) async {
    setState(() {
      _isLoadingArchive = true;
      _archiveFiles = [];
    });

    try {
      final archiveFile = File(file.path!);
      final bytes = await archiveFile.readAsBytes();
      final archive = _decodeArchive(bytes, file.name);
      
      if (archive == null) {
        if (mounted) {
          setState(() {
            _archiveFiles = [];
            _isLoadingArchive = false;
          });
        }
        return;
      }

      final files = archive.files.map((f) {
        return ArchiveFileModel(
          name: f.name,
          size: f.size,
          isDirectory: f.isFile == false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _archiveFiles = files;
          _isLoadingArchive = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading archive contents: $e');
      if (mounted) {
        setState(() {
          _archiveFiles = [];
          _isLoadingArchive = false;
        });
      }
    }
  }

  Archive? _decodeArchive(List<int> bytes, String fileName) {
    final name = fileName.toLowerCase();
    
    // TAR.GZ ou TGZ
    if (name.endsWith('.tar.gz') || name.endsWith('.tgz')) {
      try {
        final decompressed = GZipDecoder().decodeBytes(bytes);
        return TarDecoder().decodeBytes(decompressed);
      } catch (e) {
        if (kDebugMode) debugPrint('Error decoding TAR.GZ: $e');
        return null;
      }
    }
    
    // TAR.BZ2 ou TBZ2
    if (name.endsWith('.tar.bz2') || name.endsWith('.tbz2') || name.endsWith('.tbz')) {
      try {
        final decompressed = BZip2Decoder().decodeBytes(bytes);
        return TarDecoder().decodeBytes(decompressed);
      } catch (e) {
        if (kDebugMode) debugPrint('Error decoding TAR.BZ2: $e');
        return null;
      }
    }
    
    // TAR
    if (name.endsWith('.tar')) {
      try {
        return TarDecoder().decodeBytes(bytes);
      } catch (e) {
        if (kDebugMode) debugPrint('Error decoding TAR: $e');
        return null;
      }
    }
    
    // GZ (arquivo único comprimido)
    if (name.endsWith('.gz') && !name.endsWith('.tar.gz')) {
      // Para arquivos .gz simples, não podemos listar o conteúdo
      // mas podemos tentar extrair
      return null;
    }
    
    // BZ2 (arquivo único comprimido)
    if (name.endsWith('.bz2') && !name.endsWith('.tar.bz2')) {
      // Para arquivos .bz2 simples, não podemos listar o conteúdo
      return null;
    }
    
    // ZIP
    if (name.endsWith('.zip')) {
      try {
        return ZipDecoder().decodeBytes(bytes);
      } catch (e) {
        if (kDebugMode) debugPrint('Error decoding ZIP: $e');
        return null;
      }
    }
    
    return null;
  }

  Future<void> _pickFiles() async {
    try {
      if (kDebugMode) debugPrint('Opening file picker...');
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'],
      );
      if (result != null && mounted) {
        if (kDebugMode) debugPrint('Files selected: ${result.files.length}');
        final loc = AppLocalizations.of(context);
        await _validateAndSetFiles(result.files, context, loc);
      } else {
        if (kDebugMode) debugPrint('No files selected or widget not mounted');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error in _pickFiles: $e');
    }
  }

  Future<void> _handleFiles(List<PlatformFile> files) async {
    if (files.isNotEmpty && mounted) {
      final loc = AppLocalizations.of(context);
      await _validateAndSetFiles(files, context, loc);
    }
  }

  Future<void> _extractFile(PlatformFile file, BuildContext context) async {
    final loc = AppLocalizations.of(context);
    
    // Mostrar diálogo para selecionar destino
    final destination = await FilePicker.platform.getDirectoryPath(
      dialogTitle: loc.t('select_destination'),
    );

    if (destination == null) {
      // Usuário cancelou
      return;
    }

    // Variáveis para controlar o progresso
    double progress = 0.0;
    String currentFile = '';
    StateSetter? progressSetState;

    // Mostrar diálogo de progresso
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            progressSetState = setState;
            return CupertinoAlertDialog(
              title: Text(loc.t('extracting')),
              content: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentFile.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          currentFile,
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
                        value: progress,
                        backgroundColor: CupertinoColors.systemGrey4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1AA0A8),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
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
      if (kDebugMode) debugPrint('Extracting ${file.name} to $destination');

      // Ler o arquivo
      final archiveFile = File(file.path!);
      final bytes = await archiveFile.readAsBytes();

      // Decodificar o arquivo usando a função genérica
      final archive = _decodeArchive(bytes, file.name);
      final name = file.name.toLowerCase();
      
      // Tratar arquivos .gz e .bz2 simples (não TAR)
      if (archive == null && (name.endsWith('.gz') || name.endsWith('.bz2'))) {
        if (!name.endsWith('.tar.gz') && !name.endsWith('.tar.bz2')) {
          // Extrair arquivo .gz ou .bz2 simples
          List<int> decompressed;
          String outputFileName;
          
          try {
            if (name.endsWith('.gz')) {
              decompressed = GZipDecoder().decodeBytes(bytes);
              outputFileName = file.name.replaceAll(RegExp(r'\.gz$'), '');
            } else {
              decompressed = BZip2Decoder().decodeBytes(bytes);
              outputFileName = file.name.replaceAll(RegExp(r'\.bz2$'), '');
            }
            
            final outputFile = File('$destination/$outputFileName');
            await outputFile.create(recursive: true);
            await outputFile.writeAsBytes(decompressed);
            
            if (mounted) {
              Navigator.pop(context); // Fechar diálogo de progresso
              await showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text(loc.t('extraction_complete')),
                  content: Text(loc.t('files_extracted_successfully')),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(loc.t('ok')),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }
            
            // Salvar no histórico
            await _saveHistory(ExtractionHistory(
              fileName: file.name,
              destination: destination,
              extractedAt: DateTime.now(),
            ));
            
            return;
          } catch (e) {
            if (kDebugMode) debugPrint('Error extracting .gz/.bz2 file: $e');
            if (mounted) {
              Navigator.pop(context);
              await showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: Text(loc.t('extraction_failed')),
                  content: Text('${loc.t('error_extracting')}: $e'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(loc.t('ok')),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }
            return;
          }
        }
      }
      
      if (archive == null) {
        // Formato não suportado ou erro ao decodificar
        final extension = file.name.toLowerCase().split('.').last;
        if (mounted) {
          Navigator.pop(context); // Fechar diálogo de progresso
          await showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: Text(loc.t('extraction_failed')),
              content: Text('Format .$extension is not yet supported or the file is corrupted. Supported formats: ZIP, TAR, TAR.GZ, TAR.BZ2, GZ, BZ2.'),
              actions: [
                CupertinoDialogAction(
                  child: Text(loc.t('ok')),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }
      
      // Processar extração (funciona para ZIP e TAR)
      final totalFiles = archive.files.length;
      int processedFiles = 0;
      
      // Verificar se há arquivos que já existem
      final existingFiles = <String>[];
      for (final file in archive) {
        final filename = file.name;
        if (filename.isEmpty || !file.isFile) continue;
        
        final outputPath = '$destination/$filename';
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          existingFiles.add(filename);
        }
      }
      
      // Se há arquivos existentes, perguntar ao usuário
      bool overwrite = true;
      if (existingFiles.isNotEmpty && mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso
        
        final shouldOverwrite = await showCupertinoDialog<bool>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(loc.t('files_already_exist')),
            content: Text(loc.t('files_already_exist_message')),
            actions: [
              CupertinoDialogAction(
                child: Text(loc.t('cancel')),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text(loc.t('overwrite')),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        
        if (shouldOverwrite == null || !shouldOverwrite) {
          return; // Usuário cancelou ou escolheu não sobrescrever
        }
        
        overwrite = shouldOverwrite;
        
        // Reabrir diálogo de progresso
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (context, setState) {
                progressSetState = setState;
                return CupertinoAlertDialog(
                  title: Text(loc.t('extracting')),
                  content: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentFile.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              currentFile,
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
                            value: progress,
                            backgroundColor: CupertinoColors.systemGrey4,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1AA0A8),
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
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
      }
      
      for (final file in archive) {
        final filename = file.name;
        if (filename.isEmpty) continue;

        // Atualizar progresso
        processedFiles++;
        progress = processedFiles / totalFiles;
        currentFile = filename;
        
        // Atualizar o diálogo
        if (progressSetState != null) {
          progressSetState!(() {});
        }

        final outputPath = '$destination/$filename';
        
        if (file.isFile) {
          // É um arquivo - verificar se deve sobrescrever
          final outputFile = File(outputPath);
          if (await outputFile.exists() && !overwrite) {
            continue; // Pular arquivo existente
          }
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        } else {
          // É um diretório
          final dir = Directory(outputPath);
          await dir.create(recursive: true);
        }
      }

      if (mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso
        
        // Salvar no histórico
        await _saveHistory(ExtractionHistory(
          fileName: file.name,
          destination: destination,
          extractedAt: DateTime.now(),
        ));

        // Mostrar diálogo de sucesso
        await showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(loc.t('extraction_complete')),
            content: Text(loc.t('files_extracted_successfully')),
            actions: [
              CupertinoDialogAction(
                child: Text(loc.t('ok')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }

      if (kDebugMode) debugPrint('Extraction completed successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('Error extracting file: $e');
      
      if (mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso
        
        // Mostrar diálogo de erro
        await showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: Text(loc.t('extraction_failed')),
            content: Text('${loc.t('error_extracting')}: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text(loc.t('ok')),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final selectedFile =
        _selected >= 0 && _files.isNotEmpty ? _files[_selected] : null;
    final isDark = widget.currentBrightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F5);

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Row(
          children: [
            GlassSidebar(
              loc,
              widget.onLocaleChanged,
              currentView: _currentView,
              onViewChanged: (index) => setState(() => _currentView = index),
            ),
            Expanded(
              child: _currentView == 1
                  ? HistoryView(
                      loc,
                      history: _history,
                      currentBrightness: widget.currentBrightness,
                    )
                  : _currentView == 2
                      ? SettingsView(
                          loc,
                          widget.onLocaleChanged,
                          widget.onBrightnessChanged,
                          widget.currentBrightness,
                        )
                      : _currentView == 3
                          ? CompressView(
                              loc,
                              currentBrightness: widget.currentBrightness,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        DropZone(
                                          loc,
                                          onTap: _pickFiles,
                                          onFilesDropped: _handleFiles,
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(child: _FileList(loc)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  FileDetails(
                                    loc,
                                    selectedFile,
                                    _files.isNotEmpty,
                                    fileCount: _archiveFiles.where((f) => !f.isDirectory).length,
                                    onExtract: selectedFile != null
                                        ? () => _extractFile(selectedFile, context)
                                        : null,
                                    onClear: selectedFile != null
                                        ? () {
                                            setState(() {
                                              _selected = -1;
                                              _archiveFiles = [];
                                              _files = [];
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _FileList(AppLocalizations loc) {
    final isDark = widget.currentBrightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF0D1116) : const Color(0xFFFFFFFF);
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;
    
    if (_files.isEmpty) {
      return Center(child: Text(loc.t('empty_list'), style: TextStyle(color: textColor)));
    }

    // Se há arquivos dentro do arquivo selecionado, mostrar esses
    if (_selected >= 0 && _archiveFiles.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.archivebox,
                    color: const Color(0xFF1AA0A8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.t('files_in_archive'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF1AA0A8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingArchive
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : ListView.separated(
                      itemCount: _archiveFiles.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                      itemBuilder: (context, index) {
                        final f = _archiveFiles[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                f.isDirectory
                                    ? CupertinoIcons.folder
                                    : CupertinoIcons.doc,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(f.name, style: TextStyle(color: textColor))),
                              if (!f.isDirectory)
                                Text(
                                  f.size > 1024 * 1024
                                      ? '${(f.size / 1024 / 1024).toStringAsFixed(1)} MB'
                                      : '${(f.size / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(color: secondaryTextColor),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    // Caso contrário, mostrar lista de arquivos selecionados
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        itemCount: _files.length,
        separatorBuilder: (_, __) =>
            Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        itemBuilder: (context, index) {
          final f = _files[index];
          return GestureDetector(
            onTap: () {
              setState(() => _selected = index);
              _loadArchiveContents(f);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _selected == index
                    ? (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06))
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.doc,
                      color: CupertinoColors.systemGrey),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f.name, style: TextStyle(color: textColor))),
                  Text(
                    '${(f.size / 1024 / 1024).toStringAsFixed(1)} MB',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

