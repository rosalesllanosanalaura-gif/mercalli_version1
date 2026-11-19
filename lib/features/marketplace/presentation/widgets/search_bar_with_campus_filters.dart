import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/haptic_utils.dart';

/// [SearchBarWithCampusFilters] — Widget crítico #3
///
/// Barra de búsqueda moderna con filtros universitarios en BottomSheet:
/// - Campo de búsqueda con icono y botón de limpiar
/// - Botón de filtros con Badge contador de filtros activos
/// - BottomSheet con:
///   - Filtro de Categorías (chips seleccionables)
///   - Filtro de Facultad
///   - Filtro de Condición (Nuevo/Usado)
///   - Rango de precio con RangeSlider
///   - Botones Limpiar / Aplicar
class SearchBarWithCampusFilters extends StatefulWidget {
  final void Function(String query, SearchFilters filters)? onSearch;
  final String? hint;

  const SearchBarWithCampusFilters({
    super.key,
    this.onSearch,
    this.hint = 'Buscar libros, batas, electrónica...',
  });

  @override
  State<SearchBarWithCampusFilters> createState() =>
      _SearchBarWithCampusFiltersState();
}

/// Modelo de filtros de búsqueda del marketplace universitario.
class SearchFilters {
  final String? category;
  final String? faculty;
  final String? condition;    // 'Nuevo' | 'Usado' | null
  final RangeValues priceRange;

  const SearchFilters({
    this.category,
    this.faculty,
    this.condition,
    this.priceRange = const RangeValues(0, 5000),
  });

  bool get hasActiveFilters =>
      category != null || faculty != null || condition != null ||
      priceRange.start > 0 || priceRange.end < 5000;

  int get activeCount {
    int count = 0;
    if (category != null) count++;
    if (faculty != null) count++;
    if (condition != null) count++;
    if (priceRange.start > 0 || priceRange.end < 5000) count++;
    return count;
  }

  SearchFilters copyWith({
    Object? category = const _Sentinel(),
    Object? faculty  = const _Sentinel(),
    Object? condition = const _Sentinel(),
    RangeValues? priceRange,
  }) {
    return SearchFilters(
      category: category is _Sentinel ? this.category : category as String?,
      faculty: faculty is _Sentinel ? this.faculty : faculty as String?,
      condition: condition is _Sentinel ? this.condition : condition as String?,
      priceRange: priceRange ?? this.priceRange,
    );
  }

  static const SearchFilters empty = SearchFilters();
}

class _Sentinel { const _Sentinel(); }

// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarWithCampusFiltersState
    extends State<SearchBarWithCampusFilters> {
  final TextEditingController _searchCtrl = TextEditingController();
  SearchFilters _filters = SearchFilters.empty;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    widget.onSearch?.call(_query, _filters);
  }

  void _clearQuery() {
    _searchCtrl.clear();
    _onQueryChanged('');
  }

  Future<void> _openFilters() async {
    HapticUtils.light();
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersBottomSheet(currentFilters: _filters),
    );
    if (result != null) {
      setState(() => _filters = result);
      widget.onSearch?.call(_query, _filters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barra de búsqueda + botón filtros ─────────────
        Row(
          children: [
            Expanded(child: _buildSearchField()),
            const SizedBox(width: 10),
            _FilterButton(
              activeCount: _filters.activeCount,
              onTap: _openFilters,
            ),
          ],
        ),

        // ── Chips de filtros activos (pills dismissibles) ──
        if (_filters.hasActiveFilters) ...[
          const SizedBox(height: 10),
          _ActiveFilterChips(
            filters: _filters,
            onClear: () => setState(() => _filters = SearchFilters.empty),
            onRemove: (type) {
              setState(() {
                switch (type) {
                  case 'category':
                    _filters = _filters.copyWith(category: null);
                  case 'faculty':
                    _filters = _filters.copyWith(faculty: null);
                  case 'condition':
                    _filters = _filters.copyWith(condition: null);
                  case 'price':
                    _filters = _filters.copyWith(
                      priceRange: const RangeValues(0, 5000),
                    );
                }
              });
              widget.onSearch?.call(_query, _filters);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgField,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _query.isNotEmpty
              ? AppColors.accentCyan.withOpacity(0.4)
              : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onQueryChanged,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.accentCyan,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20),
                  onPressed: _clearQuery,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Botón de filtros con Badge ────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activeCount > 0
                  ? AppColors.accentBlue.withOpacity(0.15)
                  : AppColors.bgField,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activeCount > 0
                    ? AppColors.accentBlue.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: activeCount > 0 ? AppColors.accentCyan : AppColors.textSecondary,
              size: 22,
            ),
          ),
          if (activeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Pills de filtros activos ─────────────────────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  final SearchFilters filters;
  final VoidCallback onClear;
  final void Function(String type) onRemove;

  const _ActiveFilterChips({
    required this.filters,
    required this.onClear,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filters.category != null) {
      chips.add(_DismissChip(label: filters.category!, onDismiss: () => onRemove('category')));
    }
    if (filters.faculty != null) {
      chips.add(_DismissChip(label: filters.faculty!, onDismiss: () => onRemove('faculty')));
    }
    if (filters.condition != null) {
      chips.add(_DismissChip(label: filters.condition!, onDismiss: () => onRemove('condition')));
    }
    if (filters.priceRange.start > 0 || filters.priceRange.end < 5000) {
      chips.add(_DismissChip(
        label: '\$${filters.priceRange.start.toInt()} - \$${filters.priceRange.end.toInt()}',
        onDismiss: () => onRemove('price'),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Botón limpiar todo
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.clear_all_rounded,
                      size: 13, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text('Limpiar',
                      style: AppTextStyles.badge.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ...chips,
        ],
      ),
    );
  }
}

class _DismissChip extends StatelessWidget {
  final String label;
  final VoidCallback onDismiss;

  const _DismissChip({required this.label, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.badge.copyWith(color: AppColors.accentCyan)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                size: 12, color: AppColors.accentCyan),
          ),
        ],
      ),
    );
  }
}

// ── BottomSheet de Filtros ────────────────────────────────────────────────────

class _FiltersBottomSheet extends StatefulWidget {
  final SearchFilters currentFilters;
  const _FiltersBottomSheet({required this.currentFilters});

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late SearchFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Filtrar resultados', style: AppTextStyles.titleLarge),
                const Spacer(),
                if (_draft.hasActiveFilters)
                  TextButton(
                    onPressed: () => setState(() => _draft = SearchFilters.empty),
                    child: Text(
                      'Limpiar todo',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),

          // Contenido scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Categorías ─────────────────────────────
                  _FilterSection(
                    title: '📚 Categoría',
                    child: _ChipGroup(
                      options: AppConstants.categories,
                      selected: _draft.category,
                      onSelect: (val) => setState(() {
                        _draft = _draft.copyWith(
                          category: _draft.category == val ? null : val,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Facultad ───────────────────────────────
                  _FilterSection(
                    title: '🎓 Facultad',
                    child: _ChipGroup(
                      options: AppConstants.faculties,
                      selected: _draft.faculty,
                      onSelect: (val) => setState(() {
                        _draft = _draft.copyWith(
                          faculty: _draft.faculty == val ? null : val,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Condición ──────────────────────────────
                  _FilterSection(
                    title: '✨ Condición',
                    child: _ChipGroup(
                      options: const ['Nuevo', 'Usado'],
                      selected: _draft.condition,
                      onSelect: (val) => setState(() {
                        _draft = _draft.copyWith(
                          condition: _draft.condition == val ? null : val,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Rango de Precio ────────────────────────
                  _FilterSection(
                    title: '💰 Rango de precio',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: _draft.priceRange,
                          min: 0,
                          max: 5000,
                          divisions: 50,
                          activeColor: AppColors.accentBlue,
                          inactiveColor: AppColors.bgField,
                          labels: RangeLabels(
                            '\$${_draft.priceRange.start.toInt()}',
                            '\$${_draft.priceRange.end.toInt()}',
                          ),
                          onChanged: (range) =>
                              setState(() => _draft = _draft.copyWith(priceRange: range)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${_draft.priceRange.start.toInt()}',
                                style: AppTextStyles.caption),
                            Text('\$${_draft.priceRange.end.toInt()}',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Botones ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticUtils.medium();
                      Navigator.pop(context, _draft);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Componentes del BottomSheet ───────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () {
            HapticUtils.light();
            onSelect(option);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentBlue.withOpacity(0.2)
                  : AppColors.bgField,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.accentCyan : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
