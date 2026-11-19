import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/feed_product_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FeedPage — "Feed Principal v2" (Landing Page del Marketplace Mercalli)
// ─────────────────────────────────────────────────────────────────────────────
//
//  Esta pantalla replica fielmente el mockup "Mercalli Feed Principal v2":
//
//  ESTRUCTURA VISUAL (de arriba hacia abajo):
//  1. AppBar con logo Mercalli centrado y avatar de usuario
//  2. SearchBar con icono de filtros
//  3. Sección "PUBLICACIONES RECIENTES" con contador de artículos
//  4. Grid de 2 columnas con FeedProductCard (imagen, badge, precio)
//  5. BottomNavigationBar: Explorar · + (FAB central) · Perfil
//
//  CÓMO PERSONALIZAR:
//  ──────────────────
//  • Fondo general           → AppColors.bgPrimary  (app_colors.dart)
//  • Color AppBar/header     → _kAppBarColor abajo  (línea ~45)
//  • Separación del grid     → crossAxisSpacing / mainAxisSpacing (~line 180)
//  • Aspect ratio de tarjeta → childAspectRatio (~line 183)
//  • BottomBar activo        → AppColors.accentCyan (app_colors.dart)
//  • FAB color               → _kFabColor abajo     (~line 46)
// ─────────────────────────────────────────────────────────────────────────────

// ── Constantes de color propias de FeedPage (fácil de localizar y cambiar) ───
const Color _kAppBarColor  = Color(0xFF0A0F1E); // ← cambia el color del AppBar aquí
const Color _kFabColor     = Color(0xFF2563EB); // ← cambia el color del FAB aquí
const Color _kSearchBg     = Color(0xFF111827); // ← fondo de la barra de búsqueda
const Color _kBottomNavBg  = Color(0xFF0D1526); // ← fondo del BottomNavBar

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Datos mock que simulan la respuesta del backend ───────────────────────
  // En producción estos vendrían de un MarketplaceBloc / Repository real.
  final List<ProductModel> _allProducts = const [
    ProductModel(
      id: '1',
      title: 'Cálculo Multivariable...',
      price: 650,
      imageUrl: '',
      condition: ProductCondition.fixed,
      faculty: 'Ingeniería',
      deliveryPoint: 'Biblioteca Central',
      category: 'Libros',
      sellerName: 'Mateo R.',
      photoCount: 4,
      isFeatured: true,
    ),
    ProductModel(
      id: '2',
      title: 'Sony WH-1000XM4 ANC',
      price: 2400,
      imageUrl: '',
      condition: ProductCondition.likeNew,
      faculty: 'Administración',
      deliveryPoint: 'Edificio C',
      category: 'Electrónica',
      sellerName: 'Sofía G.',
      photoCount: 3,
    ),
    ProductModel(
      id: '3',
      title: 'Nintendo Switch Lite',
      price: 2100,
      imageUrl: '',
      condition: ProductCondition.used,
      faculty: 'Comunicación',
      deliveryPoint: 'Cafetería Norte',
      category: 'Electrónica',
      sellerName: 'David P.',
      photoCount: 4,
    ),
    ProductModel(
      id: '4',
      title: 'Mochila Urbana para Laptop',
      price: 420,
      imageUrl: '',
      condition: ProductCondition.likeNew,
      faculty: 'Diseño',
      deliveryPoint: 'Edificio B',
      category: 'Accesorios',
      sellerName: 'Carlos M.',
      photoCount: 2,
    ),
    ProductModel(
      id: '5',
      title: 'Chamarra Denim Vintage',
      price: 490,
      imageUrl: '',
      condition: ProductCondition.used,
      faculty: 'Humanidades',
      deliveryPoint: 'Entrada Principal',
      category: 'Ropa',
      sellerName: 'Andrea L.',
      photoCount: 3,
    ),
    ProductModel(
      id: '6',
      title: 'Bicicleta Fixie Urbana R28',
      price: 1850,
      imageUrl: '',
      condition: ProductCondition.adjusted,
      faculty: 'Arquitectura',
      deliveryPoint: 'Estacionamiento Sur',
      category: 'Transporte',
      sellerName: 'Rodrigo T.',
      photoCount: 5,
    ),
  ];

  List<ProductModel> get _filtered {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts
        .where((p) =>
            p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.sellerName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is! AuthAuthenticated) {
          context.go(AppRoutes.welcome);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        // ── AppBar ───────────────────────────────────────────────────────────
        appBar: _buildAppBar(context),
        // ── Cuerpo: SearchBar + Grid ─────────────────────────────────────────
        body: _buildBody(),
        // ── BottomBar + FAB ──────────────────────────────────────────────────
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: _buildFab(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // ── AppBar con logo centrado ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kAppBarColor,
      elevation: 0,
      centerTitle: true,
      // Logo Mercalli a la izquierda
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/logo_mercalli.png',
          // ── Tamaño del logo en AppBar: ajusta width/height ──────────────
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      // Nombre de la app centrado
      title: Text(
        'MERCALLI',
        style: AppTextStyles.titleLarge.copyWith(
          letterSpacing: 3.0,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      // Avatar del usuario a la derecha
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {/* TODO: ir a perfil */},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // ── Color del avatar: cambia AppColors.accentBlue ──────────
                color: AppColors.accentBlue.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.accentCyan, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Body: SearchBar + sección de publicaciones + Grid ─────────────────────
  Widget _buildBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SearchBar ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: _SearchBar(
              controller: _searchCtrl,
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
        ),

        // ── Encabezado "PUBLICACIONES RECIENTES · N artículos" ────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PUBLICACIONES RECIENTES',
                  style: AppTextStyles.caption.copyWith(
                    // ── Color del encabezado de sección ──────────────────
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_filtered.length} artículos',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Grid de productos ──────────────────────────────────────────────
        _filtered.isEmpty
            ? const SliverFillRemaining(child: _EmptyFeedState())
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _filtered[index];
                      return FeedProductCard(
                        product: product,
                        onTap: () {
                          // TODO: navegar al detalle del producto
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ver: ${product.title}'),
                              backgroundColor: AppColors.bgCard,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _filtered.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    // ── Columnas del grid: 2 en móvil, 3 en tablet ────────
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    // ── Espacio horizontal entre tarjetas ─────────────────
                    crossAxisSpacing: 12,
                    // ── Espacio vertical entre tarjetas ───────────────────
                    mainAxisSpacing: 12,
                    // ── Proporción altura/ancho de cada tarjeta ───────────
                    // 0.70 → tarjeta más alta; 0.85 → más cuadrada
                    childAspectRatio: 0.70,
                  ),
                ),
              ),
      ],
    );
  }

  // ── BottomNavigationBar estilo mockup ─────────────────────────────────────
  Widget _buildBottomBar() {
    return BottomAppBar(
      // ── Color de fondo del BottomBar ──────────────────────────────────────
      color: _kBottomNavBg,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Explorar (activo)
            _BottomNavItem(
              icon: Icons.grid_view_rounded,
              label: 'Explorar',
              isActive: true,
              onTap: () {},
            ),
            // Espacio para el FAB
            const SizedBox(width: 72),
            // Perfil
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              isActive: false,
              onTap: () {/* TODO: ir a perfil */},
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB central azul "+" ──────────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: navegar a "Publicar producto"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicar nuevo artículo'),
            backgroundColor: Color(0xFF111827),
          ),
        );
      },
      // ── Color del FAB: cambia _kFabColor arriba ───────────────────────
      backgroundColor: _kFabColor,
      elevation: 6,
      child: const Icon(Icons.add, size: 28, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SearchBar — Barra de búsqueda fiel al mockup
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        // ── Fondo de la SearchBar: _kSearchBg o AppColors.bgField ─────────
        color: _kSearchBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded,
              color: AppColors.textHint, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar artículos de segunda mano...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Botón de filtros (icono sliders)
          GestureDetector(
            onTap: () {/* TODO: mostrar filtros avanzados */},
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                // ── Color del botón de filtros ───────────────────────────
                color: AppColors.bgField,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.textSecondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _BottomNavItem — Ítem del BottomAppBar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Color activo del BottomNav: AppColors.accentCyan ─────────────────
    final color = isActive ? AppColors.accentCyan : AppColors.textHint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _EmptyFeedState — Estado vacío cuando no hay resultados
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 60, color: AppColors.textHint),
          const SizedBox(height: 14),
          Text('Sin resultados', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Prueba buscando con otras palabras',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
