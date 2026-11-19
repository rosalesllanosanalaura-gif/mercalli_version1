import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FeedProductCard — Tarjeta de producto estilo Feed Principal v2 (Mockup)
// ─────────────────────────────────────────────────────────────────────────────
//
//  Reproduce fielmente el diseño del mockup "Mercalli Feed Principal v2":
//  • Imagen del producto a pantalla completa dentro de la tarjeta
//  • Badge de condición en la esquina superior izquierda (Fijo, Usado, Nuevo…)
//  • Contador de fotos "1/4" en la esquina inferior derecha
//  • Título del producto en texto blanco con sombra
//  • Nombre del vendedor con punto verde de verificación
//  • Precio grande con sufijo "MXN"
//
//  CÓMO PERSONALIZAR COLORES Y TRANSPARENCIAS:
//  ─────────────────────────────────────────────
//  • Badge de condición       → _conditionColor()  (líneas ~90-100)
//  • Overlay del gradiente    → BoxDecoration gradient en _buildImage() (~line 115)
//  • Fondo de la tarjeta      → AppColors.bgCard  en app_colors.dart
//  • Color del precio         → AppColors.textPrimary o modifica directamente
//  • Punto verde del vendedor → AppColors.success en app_colors.dart
// ─────────────────────────────────────────────────────────────────────────────

class FeedProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const FeedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  // ── Colores de condición del badge ────────────────────────────────────────
  Color _conditionBgColor() {
    switch (product.condition) {
      case ProductCondition.newItem:
        return const Color(0xFF00C853); // verde
      case ProductCondition.likeNew:
        return const Color(0xFF00BFA5); // verde-azul
      case ProductCondition.fixed:
        return const Color(0xFF263147); // azul marino oscuro
      case ProductCondition.adjusted:
        return const Color(0xFF4A148C); // púrpura oscuro
      case ProductCondition.used:
      default:
        return const Color(0xFF1A2744); // azul muy oscuro
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          // ── Sombra sutil: modifica aquí para más/menos profundidad ─────────
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sección imagen ─────────────────────────────────────────────
            _buildImageSection(),
            // ── Sección info ───────────────────────────────────────────────
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  // ── Imagen con overlays (badge + contador de fotos) ────────────────────────
  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: AspectRatio(
        aspectRatio: 1.0, // cuadrado perfecto, igual que el mockup
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen del producto (placeholder si no hay URL)
            _ProductImage(imageUrl: product.imageUrl, category: product.category),

            // Gradiente inferior para legibilidad del texto (si hubiera)
            // ── Para ajustar la transparencia del gradiente: cambia los stops y opacity ──
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45), // ← ajusta aquí la opacidad del gradiente
                    ],
                  ),
                ),
              ),
            ),

            // ── Badge de condición (esquina superior izquierda) ────────────
            Positioned(
              top: 10,
              left: 10,
              child: _ConditionBadge(
                label: product.condition.label,
                bgColor: _conditionBgColor(),
              ),
            ),

            // ── Contador de fotos (esquina inferior derecha) ───────────────
            Positioned(
              bottom: 8,
              right: 8,
              child: _PhotoCountBadge(
                current: 1,
                total: product.photoCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info: título, vendedor, precio ────────────────────────────────────────
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del producto
          Text(
            product.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Vendedor con punto verde de verificación
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  // ── Color del punto de vendedor verificado: AppColors.success ──
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                product.sellerName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                // Formato de precio: $2,100
                '\$${_formatPrice(product.price)}',
                style: AppTextStyles.titleLarge.copyWith(
                  // ── Color del precio → AppColors.textPrimary ──────────
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'MXN',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    // "2100" → "2,100" / "650" → "650"
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final rest = (intPrice % 1000).toString().padLeft(3, '0');
      return '$thousands,$rest';
    }
    return intPrice.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widgets internos auxiliares
// ─────────────────────────────────────────────────────────────────────────────

/// Imagen del producto con placeholder elegante cuando no hay URL.
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  final String category;

  const _ProductImage({required this.imageUrl, required this.category});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(category: category),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _Placeholder(category: category);
        },
      );
    }
    return _Placeholder(category: category);
  }
}

/// Placeholder con icono de categoría cuando no hay imagen disponible.
class _Placeholder extends StatelessWidget {
  final String category;
  const _Placeholder({required this.category});

  IconData get _icon {
    switch (category.toLowerCase()) {
      case 'libros':          return Icons.menu_book_rounded;
      case 'electrónica':     return Icons.devices_rounded;
      case 'batas y uniformes': return Icons.dry_cleaning_rounded;
      case 'snacks':          return Icons.fastfood_rounded;
      default:                return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgField,
      child: Center(
        child: Icon(_icon, size: 48, color: AppColors.textHint),
      ),
    );
  }
}

/// Badge de condición (Fijo, Usado, Nuevo…) en la esquina superior izquierda.
class _ConditionBadge extends StatelessWidget {
  final String label;
  final Color bgColor;

  const _ConditionBadge({required this.label, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ── Para cambiar el color del badge: modifica bgColor en _conditionBgColor() ──
        color: bgColor.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Indicador de foto actual / total (ej. "1/4") en la esquina inferior derecha.
class _PhotoCountBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PhotoCountBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        // ── Transparencia del contador: ajusta el withOpacity ──
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$current/$total',
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
