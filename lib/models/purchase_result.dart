/// 交易结果模型
class PurchaseResult {
  final bool? success;
  final String? error;
  final String? transactionId;
  final String? productId;

  PurchaseResult({
     this.success,
    this.error,
    this.transactionId,
     this.productId,
  });
}
