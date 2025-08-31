
import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;
  final String notes;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
    this.notes = '',
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'notes': notes,
      'total_price': totalPrice,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menuItem: MenuItemModel.fromJson(json['menu_item']),
      quantity: json['quantity'],
      notes: json['notes'] ?? '',
    );
  }
}
