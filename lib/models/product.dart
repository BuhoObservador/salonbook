import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final Map<String, dynamic> specifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.stockQuantity,
    required this.isActive,
    required this.isFeatured,
    required this.specifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      stockQuantity: data['stockQuantity'] ?? 0,
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stockQuantity': stockQuantity,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'specifications': specifications,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    int? stockQuantity,
    bool? isActive,
    bool? isFeatured,
    Map<String, dynamic>? specifications,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final int sortItemsOrder;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.isActive,
    required this.sortItemsOrder,
    required this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      sortItemsOrder: data['sortItemsOrder'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'sortItemsOrder': sortItemsOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String? imageUrl;
  int quantity;
  final int maxStock;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    required this.quantity,
    required this.maxStock,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'maxStock': maxStock,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      productId: data['productId'],
      productName: data['productName'],
      price: data['price'].toDouble(),
      imageUrl: data['imageUrl'],
      quantity: data['quantity'],
      maxStock: data['maxStock'],
    );
  }
}

class ItemsOrder {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String status;
  final String paymentStatus;
  final String? paymentIntentId;
  final Map<String, dynamic> shippingAddress;
  final Map<String, dynamic> billingAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemsOrder({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.paymentIntentId,
    required this.shippingAddress,
    required this.billingAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemsOrder.fromMap(String id, Map<String, dynamic> data) {
    return ItemsOrder(
      id: id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      shipping: (data['shipping'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentIntentId: data['paymentIntentId'],
      shippingAddress: Map<String, dynamic>.from(data['shippingAddress'] ?? {}),
      billingAddress: Map<String, dynamic>.from(data['billingAddress'] ?? {}),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentIntentId': paymentIntentId,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'],
      productName: data['productName'],
      price: data['price'].toDouble(),
      quantity: data['quantity'],
      imageUrl: data['imageUrl'],
    );
  }
}