/// Shop item types
enum ShopItemType {
  theme,
  // Future: avatar, badge, etc.
}

/// Shop item model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price; // Price in coins
  final ShopItemType type;
  final String? themeId; // For theme items
  final String? icon; // Emoji or icon identifier
  bool isPurchased;
  bool isEquipped;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    this.themeId,
    this.icon,
    this.isPurchased = false,
    this.isEquipped = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'type': type.name,
        'themeId': themeId,
        'icon': icon,
        'isPurchased': isPurchased,
        'isEquipped': isEquipped,
      };

  /// Create from JSON
  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] as int,
        type: ShopItemType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ShopItemType.theme,
        ),
        themeId: json['themeId'] as String?,
        icon: json['icon'] as String?,
        isPurchased: json['isPurchased'] as bool? ?? false,
        isEquipped: json['isEquipped'] as bool? ?? false,
      );

  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    ShopItemType? type,
    String? themeId,
    String? icon,
    bool? isPurchased,
    bool? isEquipped,
  }) =>
      ShopItem(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        type: type ?? this.type,
        themeId: themeId ?? this.themeId,
        icon: icon ?? this.icon,
        isPurchased: isPurchased ?? this.isPurchased,
        isEquipped: isEquipped ?? this.isEquipped,
      );
}

