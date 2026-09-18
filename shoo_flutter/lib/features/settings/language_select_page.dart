import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/storage/preferences.dart';
import '../../l10n/app_localizations.dart';

/// 语言选择页——带搜索 + 字母分组 + 高亮当前语言
class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  String _query = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // 常用语言置顶
  static const _frequentCodes = ['system', 'zh', 'zh_TW', 'en', 'ja', 'ko'];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> get _filteredCodes {
    final codes = <String>['system'];
    codes.addAll(S.supportedLanguageCodes);
    if (_query.isEmpty) return codes;
    final q = _query.toLowerCase();
    return codes.where((code) {
      if (code == 'system') return S.of(context).followSystem.toLowerCase().contains(q);
      final name = S.nativeLanguageNames[code] ?? code;
      return name.toLowerCase().contains(q) || code.toLowerCase().contains(q);
    }).toList();
  }

  List<String> get _frequentCodesFiltered {
    if (_query.isNotEmpty) return [];
    return _frequentCodes.where((c) => _filteredCodes.contains(c)).toList();
  }

  List<String> get _remainingCodes {
    final freq = _frequentCodesFiltered.toSet();
    return _filteredCodes.where((c) => !freq.contains(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = prefs.language;
    final frequent = _frequentCodesFiltered;
    final remaining = _remainingCodes;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.language),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '🔍  Search languages',
                filled: true,
                fillColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (frequent.isNotEmpty) ...[
            const _SectionLabel(text: '⭐', isSymbol: true),
            _CardGroup(
              codes: frequent,
              currentCode: current,
              isDark: isDark,
              onTap: _selectLanguage,
            ),
            const SizedBox(height: 8),
          ],
          if (remaining.isNotEmpty) ...[
            if (frequent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Divider(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
              ),
            _CardGroup(
              codes: remaining,
              currentCode: current,
              isDark: isDark,
              onTap: _selectLanguage,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _selectLanguage(BuildContext context, String code) {
    prefs.language = code;
    final container = ProviderScope.containerOf(context);
    container.read(localeProvider.notifier).state = resolveLocale(code);
    context.pop();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isSymbol;
  const _SectionLabel({required this.text, this.isSymbol = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSymbol ? 14 : 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  final List<String> codes;
  final String currentCode;
  final bool isDark;
  final void Function(BuildContext, String) onTap;

  const _CardGroup({
    required this.codes,
    required this.currentCode,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: codes.asMap().entries.map((entry) {
          final idx = entry.key;
          final code = entry.value;
          final isSelected = code == currentCode;
          final isLast = idx == codes.length - 1;
          return _LanguageTile(
            code: code,
            isSelected: isSelected,
            isDark: isDark,
            showDivider: !isLast,
            onTap: () => onTap(context, code),
          );
        }).toList(),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final bool isSelected;
  final bool isDark;
  final bool showDivider;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.isSelected,
    required this.isDark,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isSystem = code == 'system';
    final displayName = isSystem ? s.followSystem : (S.nativeLanguageNames[code] ?? code);
    final codeLabel = isSystem ? '' : code;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                 else
                   const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.orange
                              : (isDark ? Colors.white : const Color(0xFF1F2937)),
                        ),
                      ),
                      if (codeLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          codeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
      ],
    );
  }
}
