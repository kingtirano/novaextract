import 'dart:io';
import 'dart:ui';
import 'package:archive/archive.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/* =========================
   APP ROOT (Cupertino)
========================= */

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  Brightness _brightness = Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('theme_mode') ?? 'dark';
    final localeCode = prefs.getString('locale') ?? 'en';
    
    setState(() {
      _brightness = themeMode == 'light' ? Brightness.light : Brightness.dark;
      _locale = Locale(localeCode);
    });
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    if (locale != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('locale', locale.languageCode);
      });
    }
  }

  void _setBrightness(Brightness brightness) {
    setState(() => _brightness = brightness);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('theme_mode', brightness == Brightness.light ? 'light' : 'dark');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _brightness == Brightness.dark;
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaExtract',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('pt')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        brightness: _brightness,
        scaffoldBackgroundColor: isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F5),
        primaryColor: const Color(0xFF1AA0A8),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 14,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
      ),
      home: MyHomePage(
        onLocaleChanged: _setLocale,
        onBrightnessChanged: _setBrightness,
        currentBrightness: _brightness,
      ),
    );
  }
}

/* =========================
   LOCALIZATION
========================= */

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _values = {
    'en': {
      'home': 'Home',
      'history': 'History',
      'settings': 'Settings',
      'drop_files': 'Drop files here',
      'or_browse': 'or browse',
      'file_details': 'File Details',
      'name': 'Name',
      'type': 'Type',
      'size': 'Size',
      'location': 'Location',
      'contains': 'Contains',
      'extract': 'Extract',
      'empty_list': 'No files selected',
      'select_language': 'Select language',
      'english': 'English',
      'portuguese': 'Português',
      'invalid_file': 'Invalid File',
      'not_compressed': 'This file is not a compressed archive. Please select a ZIP, RAR, 7Z, TAR, or GZ file.',
      'ok': 'OK',
      'select_destination': 'Select Destination',
      'select_folder': 'Select folder where files will be extracted',
      'extracting': 'Extracting...',
      'extraction_complete': 'Extraction Complete',
      'extraction_failed': 'Extraction Failed',
      'files_extracted_successfully': 'Files extracted successfully',
      'error_extracting': 'An error occurred while extracting the files',
      'cancel': 'Cancel',
      'files_in_archive': 'Files in Archive',
      'loading': 'Loading...',
      'files_count': 'files',
      'files_already_exist': 'Files Already Exist',
      'files_already_exist_message': 'Some files already exist in the destination folder. Do you want to overwrite them?',
      'overwrite': 'Overwrite',
      'skip': 'Skip',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'save': 'Save',
      'no_history': 'No extraction history',
      'extracted_at': 'Extracted at',
      'destination': 'Destination',
      'open_folder': 'Open Folder',
      'file_name': 'File Name',
    },
    'pt': {
      'home': 'Início',
      'history': 'Histórico',
      'settings': 'Configurações',
      'drop_files': 'Arraste os arquivos aqui',
      'or_browse': 'ou procurar',
      'file_details': 'Detalhes do Arquivo',
      'name': 'Nome',
      'type': 'Tipo',
      'size': 'Tamanho',
      'location': 'Localização',
      'contains': 'Contém',
      'extract': 'Extrair',
      'empty_list': 'Nenhum arquivo selecionado',
      'select_language': 'Selecionar idioma',
      'english': 'English',
      'portuguese': 'Português',
      'invalid_file': 'Arquivo Inválido',
      'not_compressed': 'Este arquivo não é um arquivo comprimido. Por favor, selecione um arquivo ZIP, RAR, 7Z, TAR ou GZ.',
      'ok': 'OK',
      'select_destination': 'Selecionar Destino',
      'select_folder': 'Selecione a pasta onde os arquivos serão extraídos',
      'extracting': 'Extraindo...',
      'extraction_complete': 'Extração Concluída',
      'extraction_failed': 'Falha na Extração',
      'files_extracted_successfully': 'Arquivos extraídos com sucesso',
      'error_extracting': 'Ocorreu um erro ao extrair os arquivos',
      'cancel': 'Cancelar',
      'files_in_archive': 'Arquivos no Arquivo',
      'loading': 'Carregando...',
      'files_count': 'arquivos',
      'files_already_exist': 'Arquivos Já Existem',
      'files_already_exist_message': 'Alguns arquivos já existem na pasta de destino. Deseja sobrescrevê-los?',
      'overwrite': 'Sobrescrever',
      'skip': 'Ignorar',
      'theme': 'Tema',
      'light': 'Claro',
      'dark': 'Escuro',
      'save': 'Salvar',
      'no_history': 'Nenhum histórico de extração',
      'extracted_at': 'Extraído em',
      'destination': 'Destino',
      'open_folder': 'Abrir Pasta',
      'file_name': 'Nome do Arquivo',
    }
  };

  String t(String key) =>
      _values[locale.languageCode]?[key] ??
      _values['en']![key] ??
      key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'pt'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}

/* =========================
   HOME PAGE
========================= */

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

/* =========================
   EXTRACTION HISTORY MODEL
========================= */

class _ExtractionHistory {
  final String fileName;
  final String destination;
  final DateTime extractedAt;

  _ExtractionHistory({
    required this.fileName,
    required this.destination,
    required this.extractedAt,
  });

  String toJson() {
    return '$fileName|$destination|${extractedAt.toIso8601String()}';
  }

  factory _ExtractionHistory.fromJson(String json) {
    final parts = json.split('|');
    return _ExtractionHistory(
      fileName: parts[0],
      destination: parts[1],
      extractedAt: DateTime.parse(parts[2]),
    );
  }
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  List<PlatformFile> _files = [];
  int _selected = -1;
  List<_ArchiveFile> _archiveFiles = [];
  bool _isLoadingArchive = false;
  int _currentView = 0; // 0 = Home, 1 = History, 2 = Settings
  List<_ExtractionHistory> _history = [];

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
          .map((json) => _ExtractionHistory.fromJson(json))
          .toList()
        ..sort((a, b) => b.extractedAt.compareTo(a.extractedAt));
    });
  }

  Future<void> _saveHistory(_ExtractionHistory entry) async {
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
      final extension = file.name.toLowerCase().split('.').last;
      
      if (extension == 'zip') {
        final archiveFile = File(file.path!);
        final bytes = await archiveFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        final files = archive.files.map((f) {
          return _ArchiveFile(
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
      } else {
        if (mounted) {
          setState(() {
            _archiveFiles = [];
            _isLoadingArchive = false;
          });
        }
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

      // Extrair baseado na extensão
      final extension = file.name.toLowerCase().split('.').last;
      
      if (extension == 'zip') {
        // Extrair ZIP
        final archive = ZipDecoder().decodeBytes(bytes);
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
      } else {
        // Para outros formatos, mostrar mensagem de não suportado
        if (mounted) {
          Navigator.pop(context); // Fechar diálogo de progresso
          await showCupertinoDialog(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: Text(loc.t('extraction_failed')),
              content: Text('Format .$extension is not yet supported. Only ZIP files are currently supported.'),
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

      if (mounted) {
        Navigator.pop(context); // Fechar diálogo de progresso
        
        // Salvar no histórico
        await _saveHistory(_ExtractionHistory(
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
            _GlassSidebar(
              loc,
              widget.onLocaleChanged,
              currentView: _currentView,
              onViewChanged: (index) => setState(() => _currentView = index),
            ),
          Expanded(
            child: _currentView == 1
                ? _HistoryView(
                    loc,
                    history: _history,
                    currentBrightness: widget.currentBrightness,
                  )
                : _currentView == 2
                    ? _SettingsView(
                        loc,
                        widget.onLocaleChanged,
                        widget.onBrightnessChanged,
                        widget.currentBrightness,
                      )
                    : Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                                _DropZone(
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
                          _FileDetails(
                            loc,
                            selectedFile,
                            _files.isNotEmpty,
                            fileCount: _archiveFiles.where((f) => !f.isDirectory).length,
                            onExtract: selectedFile != null
                                ? () => _extractFile(selectedFile, context)
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

/* =========================
   SIDEBAR
========================= */

class _GlassSidebar extends StatelessWidget {
  final AppLocalizations loc;
  final ValueChanged<Locale?>? onLocaleChanged;
  final int currentView;
  final ValueChanged<int> onViewChanged;

  const _GlassSidebar(
    this.loc,
    this.onLocaleChanged, {
    required this.currentView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final sidebarColor = isDark ? const Color(0xFF0D1116) : const Color(0xFFFFFFFF);
    
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sidebarColor.withValues(alpha: 0.85),
                  sidebarColor.withValues(alpha: 0.65),
                ],
              ),
            ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.folder_fill,
                      color: Color(0xFF1AA0A8)),
                  const SizedBox(width: 10),
                  Text(
                    'NovaExtract',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => onViewChanged(0),
                  child: _SidebarItem(
                icon: CupertinoIcons.house,
                label: loc.t('home'),
                    selected: currentView == 0,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onViewChanged(1),
                  child: _SidebarItem(
                icon: CupertinoIcons.time,
                label: loc.t('history'),
                    selected: currentView == 1,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onViewChanged(2),
                  child: _SidebarItem(
                icon: CupertinoIcons.settings,
                label: loc.t('settings'),
                    selected: currentView == 2,
                  ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected || _isHovered;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.selected
              ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08))
              : _isHovered
                  ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                  : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: isActive
                  ? const Color(0xFF1AA0A8)
                  : CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : CupertinoColors.systemGrey,
                fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   DROP ZONE
========================= */

class _DropZone extends StatefulWidget {
  final AppLocalizations loc;
  final VoidCallback onTap;
  final ValueChanged<List<PlatformFile>> onFilesDropped;

  const _DropZone(
    this.loc, {
    required this.onTap,
    required this.onFilesDropped,
  });

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
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

/* =========================
   FILE DETAILS
========================= */

class _FileDetails extends StatelessWidget {
  final AppLocalizations loc;
  final PlatformFile? file;
  final bool enabled;
  final VoidCallback? onExtract;
  final int fileCount;

  const _FileDetails(
    this.loc,
    this.file,
    this.enabled, {
    this.onExtract,
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
          _DetailRow(loc.t('name'), file?.name ?? '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          _DetailRow(loc.t('type'), file != null ? _ext(file!.name) : '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          _DetailRow(
              loc.t('size'),
              file != null
                  ? '${(file!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                  : '-',
              textColor: textColor,
              secondaryTextColor: secondaryTextColor),
          _DetailRow(loc.t('location'), file?.path ?? '-', textColor: textColor, secondaryTextColor: secondaryTextColor),
          _DetailRow(
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

class _ArchiveFile {
  final String name;
  final int size;
  final bool isDirectory;

  _ArchiveFile({
    required this.name,
    required this.size,
    required this.isDirectory,
  });
}

/* =========================
   HISTORY VIEW
========================= */

class _HistoryView extends StatelessWidget {
  final AppLocalizations loc;
  final List<_ExtractionHistory> history;
  final Brightness currentBrightness;

  const _HistoryView(
    this.loc, {
    required this.history,
    required this.currentBrightness,
  });

  Future<void> _openFolder(String path) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error opening folder: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '${difference.inSeconds} ${difference.inSeconds == 1 ? 'second' : 'seconds'} ago';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = currentBrightness == Brightness.dark;
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
                loc.t('history'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          loc.t('no_history'),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = history[index];
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.archivebox_fill,
                                      color: Color(0xFF1AA0A8),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.fileName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 14,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${loc.t('extracted_at')}: ${_formatDate(entry.extractedAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.folder,
                                      size: 14,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${loc.t('destination')}: ${entry.destination}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: secondaryTextColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: CupertinoButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      color: const Color(0xFF1AA0A8),
                                      borderRadius: BorderRadius.circular(8),
                                      onPressed: () => _openFolder(entry.destination),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons.arrow_right_circle,
                                            size: 16,
                                            color: CupertinoColors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            loc.t('open_folder'),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;
  final Color? secondaryTextColor;

  const _DetailRow(
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

/* =========================
   SETTINGS VIEW
========================= */

class _SettingsView extends StatefulWidget {
  final AppLocalizations loc;
  final ValueChanged<Locale?>? onLocaleChanged;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final Brightness currentBrightness;

  const _SettingsView(
    this.loc,
    this.onLocaleChanged,
    this.onBrightnessChanged,
    this.currentBrightness,
  );

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late Brightness _selectedTheme;
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentBrightness;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale ??= Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selectedTheme == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF0D1116) : const Color(0xFFFFFFFF);
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.loc.t('settings'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              // Theme Section
              Text(
                widget.loc.t('theme'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = Brightness.light;
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            CupertinoRadio<Brightness>(
                              value: Brightness.light,
                              groupValue: _selectedTheme,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTheme = value;
                                  });
                                }
                              },
                              activeColor: const Color(0xFF1AA0A8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.loc.t('light'),
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = Brightness.dark;
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            CupertinoRadio<Brightness>(
                              value: Brightness.dark,
                              groupValue: _selectedTheme,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTheme = value;
                                  });
                                }
                              },
                              activeColor: const Color(0xFF1AA0A8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.loc.t('dark'),
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Language Section
              Text(
                widget.loc.t('select_language'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
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
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  onPressed: () async {
                    final choice = await showCupertinoModalPopup<Locale>(
                      context: context,
                      builder: (_) => CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                            child: Text(widget.loc.t('english')),
                            onPressed: () => Navigator.pop(context, const Locale('en')),
                          ),
                          CupertinoActionSheetAction(
                            child: Text(widget.loc.t('portuguese')),
                            onPressed: () => Navigator.pop(context, const Locale('pt')),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: Text(widget.loc.t('cancel')),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    );
                    if (choice != null) {
                      setState(() => _selectedLocale = choice);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedLocale?.languageCode == 'pt'
                            ? widget.loc.t('portuguese')
                            : widget.loc.t('english'),
                        style: TextStyle(color: textColor),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: Color(0xFF1AA0A8),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Save Button
              Align(
                alignment: Alignment.bottomRight,
                child: CupertinoButton.filled(
                  color: const Color(0xFF1AA0A8),
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  onPressed: () {
                    widget.onBrightnessChanged?.call(_selectedTheme);
                    widget.onLocaleChanged?.call(_selectedLocale);
                    // Show success message
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: Text(widget.loc.t('settings')),
                        content: const Text('Settings saved successfully'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text(widget.loc.t('ok')),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    widget.loc.t('save'),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



