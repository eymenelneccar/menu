
class AppConstants {
  // ألوان التطبيق
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  
  // عنوان واجهة البرمجة (الباك إند)
  // عند تشغيل الباك إند محلياً يعمل على 3001 الآن
  static const String apiBaseUrl = 'http://localhost:3000';
  
  // أحجام الخط
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;
  static const double extraLargeFontSize = 24.0;
  
  // المسافات
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  // أبعاد الشاشة
  static const double minScreenWidth = 320.0;
  static const double maxScreenWidth = 1200.0;
  
  // مدة الرسوم المتحركة
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  
  // رسائل الخطأ
  static const String networkErrorMessage = 'خطأ في الاتصال بالشبكة';
  static const String generalErrorMessage = 'حدث خطأ غير متوقع';
  static const String loadingMessage = 'جارٍ التحميل...';
  static const String noDataMessage = 'لا توجد بيانات للعرض';
  
  // مفاتيح التخزين المحلي
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'app_language';
}
