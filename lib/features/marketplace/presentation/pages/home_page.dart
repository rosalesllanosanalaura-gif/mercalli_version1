import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/campus_product_card.dart';
import '../widgets/search_bar_with_campus_filters.dart';

/// HomePage — Dashboard principal del marketplace universitario.
/// Ruta protegida: requiere AuthAuthenticated.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;
  bool _isGridView = true;

  // Datos mock para demostración de los widgets
  final List<ProductModel> _mockProducts = [
    ProductModel(
      id: '1',
      title: 'Cálculo Diferencial Larson 10ma Edición',
      price: 280,
      imageUrl: '',
      condition: ProductCondition.used,
      faculty: 'Ingeniería',
      deliveryPoint: 'Biblioteca Central',
      category: 'Libros',
      sellerName: 'Ana García',
      viewCount: 42,
    ),
    ProductModel(
      id: '2',
      title: 'Bata de Laboratorio Talla M — Sin uso',
      price: 150,
      imageUrl: '',
      condition: ProductCondition.newItem,
      faculty: 'Medicina',
      deliveryPoint: 'Edificio B',
      category: 'Batas y Uniformes',
      sellerName: 'Carlos López',
      viewCount: 18,
    ),
    ProductModel(
      id: '3',
      title: 'iPad 9na gen + Apple Pencil',
      price: 4500,
      imageUrl: '',
      condition: ProductCondition.used,
      faculty: 'Arquitectura',
      deliveryPoint: 'Cafetería Norte',
      category: 'Electrónica',
      sellerName: 'María Torres',
      viewCount: 95,
    ),
    ProductModel(
      id: '4',
      title: 'Derecho Romano Margadant — 1era edición',
      price: 120,
      imageUrl: '',
      condition: ProductCondition.used,
      faculty: 'Derecho',
      deliveryPoint: 'Entrada Principal',
      category: 'Libros',
      sellerName: 'Javier Morales',
      viewCount: 7,
    ),
    ProductModel(
      id: '5',
      title: 'Calculadora Casio Científica FX-991',
      price: 350,
      imageUrl: '',
      condition: ProductCondition.newItem,
      faculty: 'Ingeniería',
      deliveryPoint: 'Edificio A',
      category: 'Electrónica',
      sellerName: 'Sofía Ramírez',
      viewCount: 61,
    ),
    ProductModel(
      id: '6',
      title: 'Snacks y papitas campus — varios sabores',
      price: 25,
      imageUrl: '',
      condition: ProductCondition.newItem,
      faculty: 'Humanidades',
      deliveryPoint: 'Cafetería Sur',
      category: 'Snacks',
      sellerName: 'Pedro Vega',
      viewCount: 130,
    ),
  ];

  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_mockProducts);
  }

  void _onSearch(String query, SearchFilters filters) {
    setState(() {
      _filteredProducts = _mockProducts.where((p) {
        // Filtro de texto
        final matchesQuery = query.isEmpty ||
            p.title.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase());

        // Filtro de categoría
        final matchesCategory = filters.category == null ||
            filters.category == 'Todos' ||
            p.category == filters.category;

        // Filtro de facultad
        final matchesFaculty = filters.faculty == null ||
            filters.faculty == 'Todas' ||
            p.faculty == filters.faculty;

        // Filtro de condición
        final matchesCondition = filters.condition == null ||
            p.condition.label == filters.condition;

        // Filtro de precio
        final matchesPrice = p.price >= filters.priceRange.start &&
            p.price <= filters.priceRange.end;

        return matchesQuery && matchesCategory && matchesFaculty &&
            matchesCondition && matchesPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: _buildBody(context, user?.name ?? 'Usuario'),
          ),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _currentTab == 0
              ? FloatingActionButton.extended(
                  onPressed: () {/* TODO: Publicar producto */},
                  backgroundColor: AppColors.accentBlue,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Publicar'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, String userName) {
    return CustomScrollView(
      slivers: [
        // ── SliverAppBar ────────────────────────────────────
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Hola, ${userName.split(' ').first}! 👋',
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 18)),
                    Text('¿Qué buscas hoy?', style: AppTextStyles.bodySmall),
                  ],
                ),
                const Spacer(),
                // Avatar + logout
                GestureDetector(
                  onTap: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go(AppRoutes.welcome);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.accentBlue.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.person_outline_rounded,
                        color: AppColors.accentCyan, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── SearchBar + filtros ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SearchBarWithCampusFilters(onSearch: _onSearch),
          ),
        ),

        // ── Chips de categorías horizontales ─────────────────
        SliverToBoxAdapter(
          child: _CategoryChipsRow(),
        ),

        // ── Sección de productos ─────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  '${_filteredProducts.length} productos',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                ),
                const Spacer(),
                // Toggle grid/lista
                IconButton(
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                  icon: Icon(
                    _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Grid / Lista de productos ─────────────────────────
        _filteredProducts.isEmpty
            ? const SliverFillRemaining(child: _EmptyState())
            : _isGridView
                ? SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => CampusProductCard(
                          product: _filteredProducts[index],
                          isCompact: true,
                          onTap: () {/* TODO: Detalle del producto */},
                        ),
                        childCount: _filteredProducts.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => CampusProductCard(
                          product: _filteredProducts[index],
                          isCompact: false,
                          onTap: () {/* TODO: Detalle del producto */},
                        ),
                        childCount: _filteredProducts.length,
                      ),
                    ),
                  ),

        // Bottom padding para el FAB
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildBottomNav() {
    const items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Inicio'),
      BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search_rounded), label: 'Explorar'),
      BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded), activeIcon: Icon(Icons.chat_bubble_rounded), label: 'Mensajes'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
    ];

    return NavigationBar(
      backgroundColor: AppColors.bgCard,
      selectedIndex: _currentTab,
      indicatorColor: AppColors.accentBlue.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => setState(() => _currentTab = i),
      destinations: items
          .map((e) => NavigationDestination(
                icon: e.icon,
                selectedIcon: e.activeIcon,
                label: e.label!,
              ))
          .toList(),
    );
  }
}

/// Chips de categorías rápidas en scroll horizontal.
class _CategoryChipsRow extends StatefulWidget {
  @override
  State<_CategoryChipsRow> createState() => _CategoryChipsRowState();
}

class _CategoryChipsRowState extends State<_CategoryChipsRow> {
  String _selected = 'Todos';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = _selected == cat;
          return GestureDetector(
            onTap: () => setState(() => _selected = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentBlue : AppColors.bgField,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.white10),
              ),
              child: Text(
                cat,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Estado vacío cuando no hay resultados.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No se encontraron productos', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('Prueba con otros filtros o términos de búsqueda',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
