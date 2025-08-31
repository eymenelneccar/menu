
class MenuItemModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameTr;
  final String descriptionAr;
  final String descriptionEn;
  final String descriptionTr;
  final double price;
  final String imageUrl;
  final int categoryId;
  final bool isAvailable;
  final bool isSpecial;

  MenuItemModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameTr,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.descriptionTr,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    this.isAvailable = true,
    this.isSpecial = false,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameTr: json['name_tr'],
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionTr: json['description_tr'] ?? '',
      price: _toDouble(json['price']),
      imageUrl: json['image_url'] ?? '',
      categoryId: json['category_id'],
      isAvailable: json['is_available'] ?? true,
      isSpecial: json['is_special'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_tr': nameTr,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'description_tr': descriptionTr,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'is_available': isAvailable,
      'is_special': isSpecial,
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

  String getDescription(String locale) {
    switch (locale) {
      case 'ar':
        return descriptionAr;
      case 'en':
        return descriptionEn;
      case 'tr':
        return descriptionTr;
      default:
        return descriptionEn;
    }
  }
}
