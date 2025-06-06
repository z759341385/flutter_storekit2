/*
 * @Author: zhc
 * @Date: 2025-01-08 18:10:25
 * @LastEditTime: 2025-06-06 22:10:37
 * @Description: 
 * @LastEditors: Please set LastEditors
 */
import 'package:flutter/services.dart';
import 'package:flutter_storekit2/models/transaction.dart';

import 'flutter_storekit2_platform_interface.dart';
export 'flutter_storekit2_platform_interface.dart' show ProductDetails;

class FlutterStorekit2 {
  static const MethodChannel _channel = MethodChannel('flutter_storekit2');

  Future<List> getProducts(List<String> productIds) {
    return FlutterStorekit2Platform.instance.getProducts(productIds);
  }

  Future<StoreTransaction?> getLatestTransaction(String productId) async {
    try {
      final result = await _channel.invokeMethod('getLatestTransaction', {
        'productId': productId,
      });

      if (result == null) return null;

      return StoreTransaction.fromMap(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      print('Error getting latest transaction: $e');
      return null;
    }
  }

  Future<StoreTransaction?> checkActiveSubscription() async {
    try {
      final result = await _channel.invokeMethod('checkActiveSubscription');

      if (result == null) return null;

      return StoreTransaction.fromMap(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      print('Error checking active subscription: $e');
      return null;
    }
  }

  Future<StoreTransaction?> purchase(String productId) async {
    try {
      final result = await _channel.invokeMethod('purchase', {
        'productId': productId,
      });

      if (result == null) return null;

      return StoreTransaction.fromMap(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      print('Error purchasing product: $e');
      rethrow; // 重新抛出异常，让调用者处理具体错误
    }
  }

  /// 检查消耗商品是否曾经购买过
  /// [productId] 商品ID
  /// 返回最后一次购买的交易信息，如果从未购买过返回 null
  Future<StoreTransaction?> checkConsumablePurchaseHistory(String productId) async {
    try {
      final result = await _channel.invokeMethod('checkConsumablePurchaseHistory', {
        'productId': productId,
      });

      if (result == null) return null;

      print('Received result: $result'); // 添加调试日志
      
      // 修改类型转换方式
      return StoreTransaction.fromMap(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      print('Error checking consumable purchase history: $e');
      return null;
    }
  }

  Future<List<Map<String, String>>> getAllSubscriptionTransactions() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getAllSubscriptionTransactions');
      
      if (result == null) return [];
      
      return result.map((item) {
        final Map<String, String> stringMap = {};
        (item as Map).forEach((key, value) {
          stringMap[key.toString()] = value.toString();
        });
        return stringMap;
      }).toList();
      
    } catch (e) {
      print('Error getting all subscription transactions: $e');
      return [];
    }
  }

  /// 获取非消耗型内购商品的购买历史
  Future<StoreTransaction?> getNonConsumablePurchaseHistory(String productId) async {
    try {
      final Map<Object?, Object?>? result = await _channel.invokeMethod(
        'getNonConsumablePurchaseHistory',
        {'productId': productId},
      );
      
      if (result != null) {
        return StoreTransaction.fromMap(Map<String, dynamic>.from(result));
      }
      return null;
    } catch (e) {
      print('Error checking non-consumable purchase history: $e');
      return null;
    }
  }

}