
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';
import '../services/language_service.dart';
import '../services/cart_service.dart';
import 'dart:math' as math;

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  final MenuService _menuService = MenuService();
  final LanguageService _languageService = LanguageService();
  final CartService _cartService = CartService();
  
  List<MenuItemModel> menuItems = [];
  bool isLoading = true;
  late CategoryModel category;
  late final AnimationController _shimmerController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    category = ModalRoute.of(context)!.settings.arguments as CategoryModel;
    _loadMenuItems();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildShimmer(double height) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;
    final t = _shimmerController.value;
    final double a = (t - 0.3).clamp(0.0, 1.0).toDouble();
    final double b = t.clamp(0.0, 1.0).toDouble();
    final double c = (t + 0.3).clamp(0.0, 1.0).toDouble();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [base, highlight, base],
          stops: [a, b, c],
        ),
      ),
    );
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await _menuService.getMenuItemsByCategory(category.id);
      setState(() {
        menuItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: category.getName(_languageService.currentLanguage),
        showCart: false,
        cartItemCount: _cartService.itemCount,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : menuItems.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد عناصر في هذا القسم',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    final isInCart = _cartService.isItemInCart(item.id);
                    final quantity = _cartService.getItemQuantity(item.id);
                    final width = MediaQuery.of(context).size.width;
                    final double cardHeight = width < 480 ? 200 : 260;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: cardHeight,
                        child: Stack(
                          children: [
                            // Background image with fade-in
                            Positioned.fill(
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame, wasSyncLoaded) {
                                  if (wasSyncLoaded) return child;
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return _buildShimmer(cardHeight);
                                },
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.grey[500],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Subtle dark gradient at bottom for readability
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.55),
                                    ],
                                    stops: const [0.45, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Bottom bar with name, price and CTA
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.getName(_languageService.currentLanguage),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.price.toStringAsFixed(0)} TL',
                                          style: TextStyle(
                                            color: Colors.green.shade300,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                isInCart
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          border: Border.all(color: Colors.orange),
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  _cartService.updateQuantity(item.id, quantity - 1);
                                                } else {
                                                  _cartService.removeItem(item.id);
                                                }
                                                setState(() {});
                                              },
                                              icon: const Icon(Icons.remove, color: Colors.orange),
                                              constraints: const BoxConstraints(minWidth: 30),
                                            ),
                                            Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _cartService.updateQuantity(item.id, quantity + 1);
                                                setState(() {});
                                              },
                                              icon: const Icon(Icons.add, color: Colors.orange),
                                              constraints: const BoxConstraints(minWidth: 30),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          _cartService.addItem(item);
                                          setState(() {});
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم إضافة العنصر إلى السلة'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(22),
                                          ),
                                        ),
                                        child: Text(_languageService.translate('add_to_cart')),
                                      ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
              heroTag: 'cartFabCategory',
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