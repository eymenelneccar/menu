
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
// Removed navigation drawer import as requested
import '../widgets/hero_section.dart';
import '../widgets/categories_grid.dart';
import '../models/category_model.dart';
import '../services/menu_service.dart';
import '../services/language_service.dart';
import '../services/cart_service.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuService _menuService = MenuService();
  final LanguageService _languageService = LanguageService();
  final CartService _cartService = CartService();
  final SettingsService _settingsService = SettingsService();
  
  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _languageService.addListener(_onChanged);
    _settingsService.addListener(_onChanged);
    if (!_settingsService.hasLoaded) {
      _settingsService.load();
    }
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

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await _menuService.getCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _settingsService.appTitle,
        showCart: false,
        cartItemCount: _cartService.itemCount,
      ),
      // Removed side navigation drawer as requested
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  HeroSection(),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: _languageService.isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        _settingsService.menuTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  CategoriesGrid(categories: categories),
                  SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'cartFabHome',
              backgroundColor: Colors.orange,
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
            ),
          ),
          if (_cartService.itemCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 16),
                child: Text(
                  '${_cartService.itemCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
