/*
 * @Author: zhc
 * @Date: 2025-01-09 10:14:45
 * @LastEditTime: 2025-03-07 09:40:22
 * @Description: 
 * @LastEditors: Please set LastEditors
 */
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_storekit2_method_channel.dart';

/// 产品信息模型
class ProductDetails {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? priceLocale;
  final String subscriptionPeriod;

  ProductDetails({
     this.id,
     this.title,
     this.description,
     this.price,
     this.priceLocale,
    this.subscriptionPeriod = '',
  });
}

/// StoreKit2 平台接口
abstract class FlutterStorekit2Platform extends PlatformInterface {
  FlutterStorekit2Platform() : super(token: _token);

  static final Object _token = Object();

  static FlutterStorekit2Platform _instance = MethodChannelFlutterStorekit2();

  static FlutterStorekit2Platform get instance => _instance;

  static set instance(FlutterStorekit2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List> getProducts(List<String> productIds) {
    throw UnimplementedError('getProducts() has not been implemented.');
  }

  Future<List<Map<String, String>>> getAllSubscriptionTransactions() {
    throw UnimplementedError('getAllSubscriptionTransactions() has not been implemented.');
  }
}
