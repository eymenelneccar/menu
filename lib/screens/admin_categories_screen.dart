import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/menu_service.dart';
import '../models/category_model.dart';

class AdminCategoriesScreen extends StatefulWidget {
  @override
  _AdminCategoriesScreenState createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final MenuService _menuService = MenuService();
  List<CategoryModel> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _menuService.getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  void _showCategoryDialog({CategoryModel? category}) {
    final nameAr = TextEditingController(text: category?.nameAr ?? '');
    final nameEn = TextEditingController(text: category?.nameEn ?? '');
    final nameTr = TextEditingController(text: category?.nameTr ?? '');
    final imageUrl = TextEditingController(text: category?.imageUrl ?? '');
    final sortOrder = TextEditingController(text: (category?.sortOrder ?? 0).toString());
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'إضافة قسم' : 'تعديل قسم'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameAr, decoration: InputDecoration(labelText: 'الاسم (عربي)')),
              TextField(controller: nameEn, decoration: InputDecoration(labelText: 'Name (English)')),
              TextField(controller: nameTr, decoration: InputDecoration(labelText: 'Ad (Türkçe)')),
              TextField(controller: imageUrl, decoration: InputDecoration(labelText: 'رابط الصورة')),
              TextField(controller: sortOrder, decoration: InputDecoration(labelText: 'ترتيب العرض'), keyboardType: TextInputType.number),
              SwitchListTile(
                value: isActive,
                onChanged: (v) => setState(() { isActive = v; }),
                title: Text('نشط؟'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              // هنا مجرد تعديل على الذاكرة المحلية
              if (category == null) {
                final newCat = CategoryModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  nameAr: nameAr.text,
                  nameEn: nameEn.text,
                  nameTr: nameTr.text,
                  imageUrl: imageUrl.text,
                  sortOrder: int.tryParse(sortOrder.text) ?? 0,
                  isActive: isActive,
                );
                setState(() { _categories.add(newCat); });
              } else {
                final idx = _categories.indexWhere((c) => c.id == category.id);
                if (idx != -1) {
                  _categories[idx] = CategoryModel(
                    id: category.id,
                    nameAr: nameAr.text,
                    nameEn: nameEn.text,
                    nameTr: nameTr.text,
                    imageUrl: imageUrl.text,
                    sortOrder: int.tryParse(sortOrder.text) ?? category.sortOrder,
                    isActive: isActive,
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'إدارة الأقسام'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: Icon(Icons.add),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = _categories[i];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(c.imageUrl)),
                  title: Text(c.nameAr),
                  subtitle: Text('${c.nameEn} · ترتيب: ${c.sortOrder}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.isActive ? Icons.visibility : Icons.visibility_off, color: Colors.grey[700]),
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _showCategoryDialog(category: c)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() { _categories.removeAt(i); });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}