/*
 * @Author: zhc
 * @Date: 2025-01-08 18:10:25
 * @LastEditTime: 2025-03-07 09:41:55
 * @Description: 
 * @LastEditors: Please set LastEditors
 */
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_storekit2/models/transaction.dart';
import 'flutter_storekit2_platform_interface.dart';

/// An implementation of [FlutterStorekit2Platform] that uses method channels.
class MethodChannelFlutterStorekit2 extends FlutterStorekit2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_storekit2');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version??'';
  }

  @override
  Future<List> getProducts(
      List<String> productIds) async {
    final List<Object?> products = await methodChannel
        .invokeMethod('getProducts', {'productIds': productIds});
    return products;
  }

  @override
  Future<List<Map<String, String>>> getAllSubscriptionTransactions() async {
    try {
      final List<dynamic> result = await methodChannel.invokeMethod('getAllSubscriptionTransactions');
      return result.map((item) => Map<String, String>.from(item as Map)).toList();
    } catch (e) {
      print('Error getting all subscription transactions: $e');
      rethrow;
    }
  }
}
