/// Entidad de dominio: Producto del marketplace Mercalli.
/// 
/// Esta es la representación "pura" del negocio, sin dependencia de Flutter
/// ni de paquetes externos. Vive en la capa de dominio.
enum ProductCondition {
  newItem('Nuevo'),
  used('Usado'),
  likeNew('Como nuevo'),
  fixed('Fijo'),     // precio fijo, no negociable
  adjusted('Ajustada'); // precio ajustable/negociable

  const ProductCondition(this.label);
  final String label;
}

/// Modelo de Producto unificado para la capa de dominio y presentación.
/// En un proyecto más grande se separaría en ProductEntity (dominio) y
/// ProductModel (datos), pero para el scope actual se combina para evitar
/// fricción innecesaria.
class ProductModel {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final ProductCondition condition;
  final String faculty;
  final String deliveryPoint;
  final String category;
  final String sellerName;
  final int viewCount;
  final int photoCount;        // número de fotos del anuncio (ej. "1/4")
  final bool isFeatured;       // badge "Fijo" / "Destacado"

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
    this.photoCount = 1,
    this.isFeatured = false,
  });
}
