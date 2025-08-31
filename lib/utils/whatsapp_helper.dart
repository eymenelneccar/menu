
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/cart_item_model.dart';

class WhatsAppHelper {
  // رقم الواتساب الخاص بالمطعم
  static const String restaurantWhatsApp = '+905551234567';

  static Future<void> sendOrder(Map<String, dynamic> orderData) async {
    final String name = orderData['name'];
    final String phone = orderData['phone'];
    final String address = orderData['address'];
    final List<CartItemModel> items = orderData['items'];
    final double total = orderData['total'];

    // تكوين نص الرسالة
    String message = '''
طلب جديد من The Kitchen 🍴

الاسم: $name
الرقم: $phone
العنوان: $address

الأصناف المطلوبة:
${items.map((item) => '- ${item.quantity} × ${item.menuItem.nameAr}').join('\n')}

الإجمالي: ${total.toStringAsFixed(0)} TL

شكراً لاختياركم The Kitchen! 🌟
''';

    // إنشاء رابط الواتساب
    final String whatsappUrl = 'https://wa.me/$restaurantWhatsApp?text=${Uri.encodeComponent(message)}';

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _launchWhatsApp(whatsappUrl);
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }

  static Future<void> _launchWhatsApp(String url) async {
    try {
      const platform = MethodChannel('whatsapp_launcher');
      await platform.invokeMethod('launchWhatsApp', {'url': url});
    } catch (e) {
      print('Could not launch WhatsApp: $e');
    }
  }
}
