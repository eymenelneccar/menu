// يمكنك ضبط هذه القيم بدون إعادة بناء الموقع
// عندما يكون الـ API والموقع على نفس موقع Netlify (نوصي به للاختبار)
// اترك API_BASE فارغاً وسيتم استخدام '/.netlify/functions'
window.API_BASE = window.API_BASE || '';

// إعدادات Cloudinary للرفع المباشر من المتصفح
// الرجاء إنشاء unsigned upload preset من لوحة Cloudinary ثم تعبئته هنا
// https://cloudinary.com/documentation/upload_presets
window.CLOUDINARY_CLOUD_NAME = window.CLOUDINARY_CLOUD_NAME || 'YOUR_CLOUD_NAME';
window.CLOUDINARY_UPLOAD_PRESET = window.CLOUDINARY_UPLOAD_PRESET || 'YOUR_UNSIGNED_PRESET';
// اختيارية: مجلد التخزين داخل Cloudinary
window.CLOUDINARY_FOLDER = window.CLOUDINARY_FOLDER || 'hero-images';