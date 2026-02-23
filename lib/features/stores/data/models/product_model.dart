import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final bool isVeg;
  final List<String> tags;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    this.isVeg = true,
    this.tags = const [],
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      storeId: data['storeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      isAvailable: data['isAvailable'] ?? true,
      isVeg: data['isVeg'] ?? true,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'isVeg': isVeg,
      'tags': tags,
      'createdAt': createdAt,
    };
  }
}
