import 'package:flutter/material.dart';

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
      'clear': 'Clear',
      'compress': 'Compress',
      'compress_files': 'Compress Files',
      'select_files_to_compress': 'Select files to compress',
      'compression_complete': 'Compression Complete',
      'compression_failed': 'Compression Failed',
      'files_compressed_successfully': 'Files compressed successfully',
      'error_compressing': 'An error occurred while compressing the files',
      'select_output_location': 'Select Output Location',
      'compressing': 'Compressing...',
      'archive_name': 'Archive Name',
      'archive_type': 'Archive Type',
      'enter_archive_name': 'Enter archive name',
      'zip': 'ZIP',
      'tar': 'TAR',
      'tar_gz': 'TAR.GZ',
      'tar_bz2': 'TAR.BZ2',
      'drag_files_here': 'Drag files here or click to select',
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
      'clear': 'Limpar',
      'compress': 'Comprimir',
      'compress_files': 'Comprimir Arquivos',
      'select_files_to_compress': 'Selecione os arquivos para comprimir',
      'compression_complete': 'Compressão Concluída',
      'compression_failed': 'Falha na Compressão',
      'files_compressed_successfully': 'Arquivos comprimidos com sucesso',
      'error_compressing': 'Ocorreu um erro ao comprimir os arquivos',
      'select_output_location': 'Selecionar Local de Saída',
      'compressing': 'Comprimindo...',
      'archive_name': 'Nome do Arquivo',
      'archive_type': 'Tipo de Arquivo',
      'enter_archive_name': 'Digite o nome do arquivo',
      'zip': 'ZIP',
      'tar': 'TAR',
      'tar_gz': 'TAR.GZ',
      'tar_bz2': 'TAR.BZ2',
      'drag_files_here': 'Arraste os arquivos aqui ou clique para selecionar',
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
      AppLocalizations._values.containsKey(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_) => false;
}

