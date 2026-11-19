import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Modelo de producto del marketplace universitario.
class ProductModel {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final ProductCondition condition;  // Nuevo / Usado
  final String faculty;
  final String deliveryPoint;
  final String category;
  final String sellerName;
  final int viewCount;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.condition,
    required this.faculty,
    required this.deliveryPoint,
    required this.category,
    required this.sellerName,
    this.viewCount = 0,
  });
}

enum ProductCondition {
  newItem('Nuevo',  AppColors.badgeNew),
  used('Usado', AppColors.badgeUsed);

  final String label;
  final Color color;
  const ProductCondition(this.label, this.color);
}

// ─────────────────────────────────────────────────────────────────────────────

/// [CampusProductCard] — Widget crítico #2
///
/// Tarjeta de producto responsiva para el marketplace universitario:
/// - Badge "Nuevo / Usado" con color semántico
/// - Badge de Facultad de origen
/// - Punto de entrega en campus
/// - Imagen de producto con shimmer placeholder
/// - Precio destacado + nombre del vendedor
/// - Adaptativo: compacto en grid o expandido en lista
class CampusProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool isCompact; // true = vista de grid, false = vista de lista

  const CampusProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    return isCompact ? _buildGridCard(context) : _buildListCard(context);
  }

  // ── Vista de Grid (compacta) ─────────────────────────────
  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ──────────────────────────────────────
            _ProductImage(
              imageUrl: product.imageUrl,
              condition: product.condition,
            ),

            // ── Info ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    product.title,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Precio
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.accentCyan,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _CampusBadge(
                        label: product.faculty,
                        color: AppColors.badgeFaculty,
                        icon: Icons.school_rounded,
                      ),
                      _CampusBadge(
                        label: product.deliveryPoint,
                        color: AppColors.badgeDelivery,
                        icon: Icons.location_on_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Vista de Lista (expandida) ───────────────────────────
  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCard),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen cuadrada
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppConstants.borderRadiusCard),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: _ProductImage(
                  imageUrl: product.imageUrl,
                  condition: product.condition,
                  showBadge: false,
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _ConditionBadge(condition: product.condition),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(product.faculty, style: AppTextStyles.caption),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.deliveryPoint,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(product.sellerName, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets de la tarjeta ─────────────────────────────────────────────────

/// Imagen del producto con Badge de condición superpuesto.
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final ProductCondition condition;
  final bool showBadge;

  const _ProductImage({
    required this.imageUrl,
    required this.condition,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImageFallback(
                      category: 'Producto',
                    ),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _ImageShimmer(),
                  )
                : _ImageFallback(category: 'Producto'),
          ),
        ),
        // Badge condición (Nuevo/Usado)
        if (showBadge)
          Positioned(
            top: 8,
            left: 8,
            child: _ConditionBadge(condition: condition),
          ),
      ],
    );
  }
}

/// Badge de Condición (Nuevo / Usado).
class _ConditionBadge extends StatelessWidget {
  final ProductCondition condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: condition.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: condition.color.withOpacity(0.5)),
      ),
      child: Text(
        condition.label,
        style: AppTextStyles.badge.copyWith(color: condition.color),
      ),
    );
  }
}

/// Badge para Facultad / Punto de Entrega.
class _CampusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CampusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: color, fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Placeholder animado (shimmer) mientras carga la imagen.
class _ImageShimmer extends StatefulWidget {
  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.6).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        color: AppColors.bgField.withOpacity(_anim.value),
      ),
    );
  }
}

/// Fallback cuando no hay imagen: ícono genérico.
class _ImageFallback extends StatelessWidget {
  final String category;
  const _ImageFallback({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgField,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 32, color: AppColors.textHint),
      ),
    );
  }
}
