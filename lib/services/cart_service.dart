
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(MenuItemModel menuItem, {int quantity = 1, String notes = ''}) {
    final existingIndex = _cartItems.indexWhere((item) => item.menuItem.id == menuItem.id);
    
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItemModel(
        menuItem: menuItem,
        quantity: quantity,
        notes: notes,
      ));
    }
  }

  void removeItem(int menuItemId) {
    _cartItems.removeWhere((item) => item.menuItem.id == menuItemId);
  }

  void updateQuantity(int menuItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    
    final index = _cartItems.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
    }
  }

  void clearCart() {
    _cartItems.clear();
  }

  bool isItemInCart(int menuItemId) {
    return _cartItems.any((item) => item.menuItem.id == menuItemId);
  }

  int getItemQuantity(int menuItemId) {
    final item = _cartItems.firstWhere(
      (item) => item.menuItem.id == menuItemId,
      orElse: () => CartItemModel(menuItem: MenuItemModel(
        id: 0, nameAr: '', nameEn: '', nameTr: '', 
        descriptionAr: '', descriptionEn: '', descriptionTr: '', 
        price: 0, imageUrl: '', categoryId: 0
      ), quantity: 0),
    );
    return item.quantity;
  }
}
