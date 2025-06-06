/// 产品信息模型
class ProductDetails {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? priceLocale;
  final String subscriptionPeriod; // 订阅周期，比如 "1 month", "1 year"

  ProductDetails({
     this.id,
     this.title,
     this.description,
     this.price,
     this.priceLocale,
    this.subscriptionPeriod = '',
  });
}
