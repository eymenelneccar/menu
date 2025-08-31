
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../utils/constants.dart';

class MenuService {
  // مصدر البيانات: API بدلاً من بيانات محاكية
  final String _base = AppConstants.apiBaseUrl;

  Future<List<CategoryModel>> getCategories() async {
    final uri = Uri.parse('$_base/categories');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories (${res.statusCode})');
  }

  Future<List<MenuItemModel>> getMenuItemsByCategory(int categoryId) async {
    // نحضر كل العناصر ثم نرشّح حسب الفئة لأن المسار الحالي لا يدعم الاستعلام
    final uri = Uri.parse('$_base/menu_items');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = jsonDecode(res.body);
      return data
          .map((e) => MenuItemModel.fromJson(e))
          .where((item) => item.categoryId == categoryId && item.isAvailable)
          .toList();
    }
    throw Exception('Failed to load menu items (${res.statusCode})');
  }

  Future<MenuItemModel?> getMenuItemById(int id) async {
    final uri = Uri.parse('$_base/menu_items');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = jsonDecode(res.body);
      try {
        return data.map((e) => MenuItemModel.fromJson(e)).firstWhere((i) => i.id == id);
      } catch (_) {
        return null;
      }
    }
    throw Exception('Failed to load menu items (${res.statusCode})');
  }

  Future<List<MenuItemModel>> getSpecialItems() async {
    final uri = Uri.parse('$_base/menu_items');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List data = jsonDecode(res.body);
      return data
          .map((e) => MenuItemModel.fromJson(e))
          .where((item) => item.isSpecial && item.isAvailable)
          .toList();
    }
    throw Exception('Failed to load menu items (${res.statusCode})');
  }
}
