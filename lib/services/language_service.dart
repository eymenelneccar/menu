
import 'package:flutter/foundation.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  bool get isRTL => _currentLanguage == 'ar';

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'the_kitchen': 'The Kitchen',
      'restaurants_london': 'Restaurants - London',
      'view_menu': 'View Menu',
      'order_now': 'Order Now',
      'snacks': 'Snacks',
      'burgers': 'Kitchen Burgers',
      'pizza': 'Pizza',
      'grills': 'Grills',
      'seafood': 'Seafood',
      'breakfast': 'Breakfast',
      'salads': 'Salads',
      'desserts': 'Desserts',
      'frozen_drinks': 'Frozen Drinks',
      'add_to_cart': 'Add to Cart',
      'cart': 'Cart',
      'checkout': 'Checkout',
      'total': 'Total',
      'send_order': 'Send Order',
      'name': 'Name',
      'phone': 'Phone',
      'address': 'Address',
      'order_details': 'Order Details',
    },
    'ar': {
      'the_kitchen': 'The Kitchen',
      'restaurants_london': 'مطاعم - لندن',
      'view_menu': 'عرض المنيو',
      'order_now': 'اطلب الآن',
      'snacks': 'مقبلات',
      'burgers': 'برجرات المطعم',
      'pizza': 'بيتزا',
      'grills': 'مشويات',
      'seafood': 'مأكولات بحرية',
      'breakfast': 'فطور',
      'salads': 'سلطات',
      'desserts': 'حلويات',
      'frozen_drinks': 'مشروبات مثلجة',
      'add_to_cart': 'أضف للسلة',
      'cart': 'السلة',
      'checkout': 'إتمام الطلب',
      'total': 'الإجمالي',
      'send_order': 'إرسال الطلب',
      'name': 'الاسم',
      'phone': 'رقم الهاتف',
      'address': 'العنوان',
      'order_details': 'تفاصيل الطلب',
    },
    'tr': {
      'the_kitchen': 'The Kitchen',
      'restaurants_london': 'Restoranlar - Londra',
      'view_menu': 'Menüyü Görüntüle',
      'order_now': 'Şimdi Sipariş Ver',
      'snacks': 'Atıştırmalık',
      'burgers': 'Kitchen Burgerler',
      'pizza': 'Pizzalar',
      'grills': 'Izgaralar',
      'seafood': 'Deniz Ürünleri',
      'breakfast': 'Kahvaltılar',
      'salads': 'Salatalar',
      'desserts': 'Tatlılar',
      'frozen_drinks': 'Buzlu & Frozen',
      'add_to_cart': 'Sepete Ekle',
      'cart': 'Sepet',
      'checkout': 'Ödeme',
      'total': 'Toplam',
      'send_order': 'Sipariş Gönder',
      'name': 'İsim',
      'phone': 'Telefon',
      'address': 'Adres',
      'order_details': 'Sipariş Detayları',
    },
  };

  void changeLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }
}
