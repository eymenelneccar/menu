
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/language_service.dart';

class CategoriesGrid extends StatefulWidget {
  final List<CategoryModel> categories;

  const CategoriesGrid({Key? key, required this.categories}) : super(key: key);

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  final LanguageService _languageService = LanguageService();
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          int crossAxisCount = 2;
          double childAspectRatio = 0.9;
          if (maxW >= 1200) {
            crossAxisCount = 4;
            childAspectRatio = 1.0;
          } else if (maxW >= 900) {
            crossAxisCount = 3;
            childAspectRatio = 0.95;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final hovered = _hoveredIndex == index;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/category',
                      arguments: category,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    transform: Matrix4.identity()..scale(hovered ? 1.03 : 1.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: hovered ? 10 : 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Ink.image(
                            image: NetworkImage(category.imageUrl),
                            fit: BoxFit.cover,
                            child: const SizedBox.expand(),
                          ),
                          // Gradient overlay (stronger on hover)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(hovered ? 0.15 : 0.05),
                                  Colors.black.withOpacity(hovered ? 0.65 : 0.45),
                                ],
                              ),
                            ),
                          ),
                          // Status badge (active/inactive)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: category.isActive ? Colors.green.withOpacity(0.9) : Colors.grey.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category.isActive ? 'متاح' : 'غير مفعل',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          // Category name
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: 1.0,
                              child: Text(
                                category.getName(_languageService.currentLanguage),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
