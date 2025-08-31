import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../services/language_service.dart';
import 'admin_categories_screen.dart';
import 'admin_menu_items_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'لوحة التحكم - إدارة المطعم',
        showCart: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً في لوحة التحكم',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يمكنك إدارة كافة أقسام ومنتجات المطعم من هنا',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            
            // Admin menu cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
                children: [
                  _buildAdminCard(
                    title: 'إدارة الأقسام',
                    subtitle: 'إضافة، تعديل وحذف الأقسام',
                    icon: Icons.category,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminCard(
                    title: 'إدارة المنتجات',
                    subtitle: 'إضافة، تعديل وحذف المنتجات والنكهات',
                    icon: Icons.restaurant_menu,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminMenuItemsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminCard(
                    title: 'إدارة الصور',
                    subtitle: 'رفع وتعديل صور المنتجات والأقسام',
                    icon: Icons.photo_library,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Implement image management
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('قريباً: إدارة الصور')),
                      );
                    },
                  ),
                  _buildAdminCard(
                    title: 'إعدادات المطعم',
                    subtitle: 'تعديل معلومات المطعم والإعدادات العامة',
                    icon: Icons.settings,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Implement restaurant settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('قريباً: إعدادات المطعم')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Quick stats
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('إجمالي الأقسام', '9', Icons.category),
                  _buildStatItem('إجمالي المنتجات', '24', Icons.restaurant),
                  _buildStatItem('المنتجات النشطة', '22', Icons.check_circle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}