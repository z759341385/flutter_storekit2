/*
 * @Author: zhc
 * @Date: 2025-01-09 10:53:40
 * @LastEditTime: 2025-01-09 10:54:08
 * @Description: 
 * @LastEditors: zhc
 */
class StoreProduct {
  final String? productId;
  final String? title;
  final String? description;
  final String? price;
  final String? priceString;
  final String? currencyCode;

  StoreProduct({
     this.productId,
     this.title,
     this.description,
     this.price,
     this.priceString,
     this.currencyCode,
  });

  factory StoreProduct.fromMap(Map<String, dynamic> map) {
    return StoreProduct(
      productId: map['productId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: map['price'] as String,
      priceString: map['priceString'] as String,
      currencyCode: map['currencyCode'] as String,
    );
  }

  Map<String, String?> toMap() {
    return {
      'productId': productId,
      'title': title,
      'description': description,
      'price': price,
      'priceString': priceString,
      'currencyCode': currencyCode,
    };
  }
}
