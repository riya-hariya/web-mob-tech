class ProductResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
 int? stock;
  List<String>? tags;
  String? brand;
  String? sku;
  int? weight;
  Dimensions? dimensions;
  String? warrantyInformation;
  String? shippingInformation;
  String? availabilityStatus;
  List<Reviews>? reviews;
  String? returnPolicy;
  int? minimumOrderQuantity;
  Meta? meta;
  List<String>? images;
   
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
      this.tags,
    
      this.sku,
      this.weight,
      this.dimensions,
      this.warrantyInformation,
      this.shippingInformation,
      this.availabilityStatus,
      this.reviews,
      this.returnPolicy,
      this.minimumOrderQuantity,
      this.meta,
    this.images,
    this.brand,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    price: (json['price'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
    stock: json['stock'],
    brand: json['brand'],
    images: json['images'] != null ? List<String>.from(json['images']) : [],
    thumbnail: json['thumbnail'],
    tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    sku: json['sku'],
    weight: json['weight'],
    dimensions: json['dimensions'] != null
        ? Dimensions.fromJson(json['dimensions'])
        : null,
    warrantyInformation: json['warrantyInformation'],
    shippingInformation: json['shippingInformation'],
    availabilityStatus: json['availabilityStatus'],
    // Use .map() to handle the list conversion cleanly
    reviews: json['reviews'] != null
        ? (json['reviews'] as List).map((v) => Reviews.fromJson(v)).toList()
        : null,
    returnPolicy: json['returnPolicy'],
    minimumOrderQuantity: json['minimumOrderQuantity'],
    meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
  );
}
  Map<String, dynamic> toJson() => {
  'id': id,
  'title': title,
  'description': description,
  'category': category,
  'price': price,
  'rating': rating,
  'stock': stock,
  'images': images,
  'brand': brand,
  'thumbnail': thumbnail,
  'tags': tags,
  'sku': sku,
  'weight': weight,
  
  // Correct Collection If syntax:
  if (dimensions != null) 'dimensions': dimensions!.toJson(),
  
  'warrantyInformation': warrantyInformation,
  'shippingInformation': shippingInformation,
  'availabilityStatus': availabilityStatus,
  
  if (reviews != null) 'reviews': reviews!.map((v) => v.toJson()).toList(),
  
  'returnPolicy': returnPolicy,
  'minimumOrderQuantity': minimumOrderQuantity, // Fixed '=' to ':'
  
  if (meta != null) 'meta': meta!.toJson(),
};
}

class Dimensions {
  double? width;
  double? height;
  double? depth;

  Dimensions({this.width, this.height, this.depth});

   factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'depth': depth,
    };
  }
}

class Reviews {
  int? rating;
  String? comment;
  String? date;
  String? reviewerName;
  String? reviewerEmail;

  Reviews(
      {this.rating,
      this.comment,
      this.date,
      this.reviewerName,
      this.reviewerEmail});

  Reviews.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    comment = json['comment'];
    date = json['date'];
    reviewerName = json['reviewerName'];
    reviewerEmail = json['reviewerEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['reviewerName'] = this.reviewerName;
    data['reviewerEmail'] = this.reviewerEmail;
    return data;
  }
}

class Meta {
  String? createdAt;
  String? updatedAt;
  String? barcode;
  String? qrCode;

  Meta({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  Meta.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    barcode = json['barcode'];
    qrCode = json['qrCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['barcode'] = this.barcode;
    data['qrCode'] = this.qrCode;
    return data;
  }
}