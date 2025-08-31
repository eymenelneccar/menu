
class CategoryModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String imageUrl;
  final bool isActive;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.imageUrl,
    this.isActive = true,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameTr: json['name_tr'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_tr': nameTr,
      'image_url': imageUrl,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  String getName(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr;
      case 'en':
        return nameEn;
      case 'tr':
        return nameTr;
      default:
        return nameEn;
    }
  }
}
