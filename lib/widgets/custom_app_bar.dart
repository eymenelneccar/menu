import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/settings_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;
  final int cartItemCount;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showCart = false,
    this.cartItemCount = 0,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final LanguageService _languageService = LanguageService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onChanged);
    _settingsService.addListener(_onChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onChanged);
    _settingsService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 2,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _settingsService.subtitle,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Language selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: PopupMenuButton<String>(
            onSelected: (String languageCode) {
              _languageService.changeLanguage(languageCode);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'ar', child: Text('العربية')),
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'tr', child: Text('Türkçe')),
            ],
            offset: const Offset(0, kToolbarHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getCurrentLanguageLabel(), style: const TextStyle(color: Colors.black87)),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
        // Cart removed per design; keep placeholder spacing if needed
        if (widget.showCart && false) SizedBox.shrink(),
      ],
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  String _getCurrentLanguageLabel() {
    switch (_languageService.currentLanguage) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }
}