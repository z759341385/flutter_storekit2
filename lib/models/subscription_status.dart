/// 订阅状态模型
class SubscriptionStatus {
  final String? productId;
  final bool? isActive;
  final DateTime? expirationDate;
  final bool? willAutoRenew;

  SubscriptionStatus({
     this.productId,
     this.isActive,
    this.expirationDate,
     this.willAutoRenew,
  });
}
