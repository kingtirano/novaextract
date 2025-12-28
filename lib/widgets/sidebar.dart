import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/localizations.dart';
import 'ad_banner.dart';

class GlassSidebar extends StatelessWidget {
  final AppLocalizations loc;
  final ValueChanged<Locale?>? onLocaleChanged;
  final int currentView;
  final ValueChanged<int> onViewChanged;

  const GlassSidebar(
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
                  child: SidebarItem(
                    icon: CupertinoIcons.house,
                    label: loc.t('home'),
                    selected: currentView == 0,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onViewChanged(1),
                  child: SidebarItem(
                    icon: CupertinoIcons.time,
                    label: loc.t('history'),
                    selected: currentView == 1,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onViewChanged(3),
                  child: SidebarItem(
                    icon: CupertinoIcons.archivebox,
                    label: loc.t('compress'),
                    selected: currentView == 3,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => onViewChanged(2),
                  child: SidebarItem(
                    icon: CupertinoIcons.settings,
                    label: loc.t('settings'),
                    selected: currentView == 2,
                  ),
                ),
                
                const Spacer(),
                const AdBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
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

