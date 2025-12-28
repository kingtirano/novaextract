import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/localizations.dart';

class SettingsView extends StatefulWidget {
  final AppLocalizations loc;
  final ValueChanged<Locale?>? onLocaleChanged;
  final ValueChanged<Brightness>? onBrightnessChanged;
  final Brightness currentBrightness;

  const SettingsView(
    this.loc,
    this.onLocaleChanged,
    this.onBrightnessChanged,
    this.currentBrightness,
  );

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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

