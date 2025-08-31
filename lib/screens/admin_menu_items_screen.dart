import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/menu_service.dart';
import '../models/menu_item_model.dart';

class AdminMenuItemsScreen extends StatefulWidget {
  @override
  _AdminMenuItemsScreenState createState() => _AdminMenuItemsScreenState();
}

class _AdminMenuItemsScreenState extends State<AdminMenuItemsScreen> {
  final MenuService _menuService = MenuService();
  List<MenuItemModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // في الوقت الحالي: نجلب كل الأصناف عبر المرور على جميع الأقسام
    final cats = await _menuService.getCategories();
    final tmp = <MenuItemModel>[];
    for (final c in cats) {
      tmp.addAll(await _menuService.getMenuItemsByCategory(c.id));
    }
    setState(() { _items = tmp; _loading = false; });
  }

  void _showItemDialog({MenuItemModel? item}) {
    final nameAr = TextEditingController(text: item?.nameAr ?? '');
    final nameEn = TextEditingController(text: item?.nameEn ?? '');
    final nameTr = TextEditingController(text: item?.nameTr ?? '');
    final descAr = TextEditingController(text: item?.descriptionAr ?? '');
    final descEn = TextEditingController(text: item?.descriptionEn ?? '');
    final descTr = TextEditingController(text: item?.descriptionTr ?? '');
    final price = TextEditingController(text: item?.price.toString() ?? '');
    final imageUrl = TextEditingController(text: item?.imageUrl ?? '');
    bool isAvailable = item?.isAvailable ?? true;
    bool isSpecial = item?.isSpecial ?? false;

    // نكهات / خيارات فرعية بسيطة كسلسلة نصوص
    final subOptions = <String>[];

    showDialog(
      context: context,
      builder: (context) {
        final subCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: Text(item == null ? 'إضافة منتج' : 'تعديل منتج'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameAr, decoration: InputDecoration(labelText: 'الاسم (عربي)')),
                  TextField(controller: nameEn, decoration: InputDecoration(labelText: 'Name (English)')),
                  TextField(controller: nameTr, decoration: InputDecoration(labelText: 'Ad (Türkçe)')),
                  SizedBox(height: 8),
                  TextField(controller: descAr, decoration: InputDecoration(labelText: 'الوصف (عربي)')),
                  TextField(controller: descEn, decoration: InputDecoration(labelText: 'Description (English)')),
                  TextField(controller: descTr, decoration: InputDecoration(labelText: 'Açıklama (Türkçe)')),
                  SizedBox(height: 8),
                  TextField(controller: price, decoration: InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
                  TextField(controller: imageUrl, decoration: InputDecoration(labelText: 'رابط الصورة')),
                  SwitchListTile(value: isAvailable, onChanged: (v){ setLocal((){ isAvailable = v; }); }, title: Text('متاح للطلب؟')),
                  SwitchListTile(value: isSpecial, onChanged: (v){ setLocal((){ isSpecial = v; }); }, title: Text('طبق مميز؟')),
                  SizedBox(height: 8),
                  Text('النكهات / الخيارات الفرعية (مثال: للشاي – نعناع، زعتر...)', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: subCtrl, decoration: InputDecoration(hintText: 'أدخل اسم النكهة ثم +'))),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (subCtrl.text.trim().isEmpty) return;
                          setLocal((){ subOptions.add(subCtrl.text.trim()); subCtrl.clear(); });
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: [
                      for (int i = 0; i < subOptions.length; i++) Chip(
                        label: Text(subOptions[i]),
                        onDeleted: () { setLocal((){ subOptions.removeAt(i); }); },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (item == null) {
                    final newItem = MenuItemModel(
                      id: DateTime.now().millisecondsSinceEpoch,
                      nameAr: nameAr.text,
                      nameEn: nameEn.text,
                      nameTr: nameTr.text,
                      descriptionAr: descAr.text,
                      descriptionEn: descEn.text,
                      descriptionTr: descTr.text,
                      price: double.tryParse(price.text) ?? 0,
                      imageUrl: imageUrl.text,
                      categoryId: 1, // مبدئياً – يمكن جعله اختيارياً لاحقاً
                      isAvailable: isAvailable,
                      isSpecial: isSpecial,
                    );
                    setState(() { _items.add(newItem); });
                  } else {
                    final idx = _items.indexWhere((x) => x.id == item.id);
                    if (idx != -1) {
                      _items[idx] = MenuItemModel(
                        id: item.id,
                        nameAr: nameAr.text,
                        nameEn: nameEn.text,
                        nameTr: nameTr.text,
                        descriptionAr: descAr.text,
                        descriptionEn: descEn.text,
                        descriptionTr: descTr.text,
                        price: double.tryParse(price.text) ?? item.price,
                        imageUrl: imageUrl.text,
                        categoryId: item.categoryId,
                        isAvailable: isAvailable,
                        isSpecial: isSpecial,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'إدارة المنتجات'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        child: Icon(Icons.add),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = _items[i];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(it.imageUrl)),
                  title: Text(it.nameAr),
                  subtitle: Text('${it.price.toStringAsFixed(0)} TL · ${it.nameEn}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(it.isAvailable ? Icons.check_circle : Icons.block, color: it.isAvailable ? Colors.green : Colors.red),
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _showItemDialog(item: it)),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () { setState(() { _items.removeAt(i); }); },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}