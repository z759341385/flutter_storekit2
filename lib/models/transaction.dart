/*
 * @Author: your name
 * @Date: 2025-01-09 11:08:53
 * @LastEditTime: 2025-03-07 09:18:42
 * @LastEditors: Please set LastEditors
 * @Description: 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 * @FilePath: /flutter_storekit2/lib/models/transaction.dart
 */
class StoreTransaction {
  final String? productId;
  final String? transactionId;
  final String? originalTransactionId;
  final String? transactionState;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final String? status;
  final bool? isUpgraded;

  StoreTransaction({
     this.productId,
     this.transactionId,
     this.originalTransactionId,
     this.transactionState,
     this.purchaseDate,
    this.expirationDate,
     this.status,
     this.isUpgraded,
  });

  factory StoreTransaction.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr.replaceAll(' ', 'T'));
      } catch (e) {
        print('Error parsing date: $dateStr');
        return null;
      }
    }

    return StoreTransaction(
      productId: map['productId']?.toString(),
      transactionId: map['transactionId']?.toString(),
      originalTransactionId: map['originalTransactionId']?.toString(),
      transactionState: map['transactionState']?.toString(),
      purchaseDate: parseDate(map['purchaseDate']?.toString()),
      expirationDate: parseDate(map['expirationDate']?.toString()),
      status: map['status']?.toString(),
      isUpgraded: map['isUpgraded'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
      'transactionState': transactionState,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'status': status,
      'isUpgraded': isUpgraded,
    };
  }
}
