import Flutter
import UIKit
import StoreKit

public class FlutterStorekit2Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_storekit2", binaryMessenger: registrar.messenger())
    let instance = FlutterStorekit2Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(FlutterError(code: "unavailable",
                        message: "StoreKit 2 requires iOS 15.0 or later",
                        details: nil))
      return
    }
    
    switch call.method {
    case "getProducts":
      handleGetProducts(call, result)
    case "getLatestTransaction":
      handleGetLatestTransaction(call, result)
    case "checkActiveSubscription":
      handleCheckActiveSubscription(call, result)
    case "purchase":
      handlePurchase(call, result)
    case "checkIfPurchased":
      handleCheckIfPurchased(call, result)
    case "checkConsumablePurchaseHistory":
      handleCheckConsumablePurchaseHistory(call, result)
    case "getAllSubscriptionTransactions":
      handleGetAllSubscriptionTransactions(call, result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  @available(iOS 15.0, *)
  private func handleGetProducts(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let productIds = args["productIds"] as? [String] else {
      result(FlutterError(code: "invalid_arguments",
                        message: "Product IDs are required",
                        details: nil))
      return
    }
    
    Task {
      do {
        let products = try await StoreKitManager.shared.getProducts(productIds: productIds)
        let productsDict = products.map { StoreKitManager.shared.productToDict($0) }
        result(productsDict as [[String: String]])
      } catch {
        result(FlutterError(code: "products_request_failed",
                          message: error.localizedDescription,
                          details: nil))
      }
    }
  }
  
  @available(iOS 15.0, *)
  private func handleGetLatestTransaction(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let productId = args["productId"] as? String else {
      result(FlutterError(code: "invalid_arguments",
                        message: "Product ID is required",
                        details: nil))
      return
    }
    
    Task {
      do {
        let transaction = try await StoreKitManager.shared.getLatestTransaction(productId: productId)
        result(transaction)
      } catch {
        result(FlutterError(code: "transaction_not_found",
                          message: error.localizedDescription,
                          details: nil))
      }
    }
  }
  
  @available(iOS 15.0, *)
  private func handleCheckActiveSubscription(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    Task {
      do {
        let subscription = try await StoreKitManager.shared.checkActiveSubscription()
        result(subscription)
      } catch {
        result(FlutterError(code: "no_active_subscription",
                          message: error.localizedDescription,
                          details: nil))
      }
    }
  }
  
  @available(iOS 15.0, *)
  private func handlePurchase(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let productId = args["productId"] as? String else {
        result(FlutterError(code: "invalid_arguments",
                          message: "Product ID is required",
                          details: nil))
        return
    }
    
    Task {
        do {
            let transaction = try await StoreKitManager.shared.purchase(productId: productId)
            result(transaction)
        } catch StoreError.userCancelled {
            result(FlutterError(code: "purchase_cancelled",
                              message: "User cancelled the purchase",
                              details: nil))
        } catch {
            result(FlutterError(code: "purchase_failed",
                              message: error.localizedDescription,
                              details: nil))
        }
    }
  }
  
  @available(iOS 15.0, *)
  private func handleCheckIfPurchased(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let productId = args["productId"] as? String else {
      result(FlutterError(code: "invalid_arguments",
                        message: "Product ID is required",
                        details: nil))
      return
    }
    
    Task {
      do {
        let isPurchased = try await StoreKitManager.shared.checkIfPurchased(productId: productId)
        result(isPurchased)
      } catch {
        result(FlutterError(code: "check_purchase_failed",
                          message: error.localizedDescription,
                          details: nil))
      }
    }
  }

  @available(iOS 15.0, *)
  private func handleCheckConsumablePurchaseHistory(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let productId = args["productId"] as? String else {
      result(FlutterError(code: "invalid_arguments",
                        message: "Product ID is required",
                        details: nil))
      return
    }
    
    Task {
      do {
        let transaction = try await StoreKitManager.shared.getConsumablePurchaseHistory(productId: productId)
        result(transaction)
      } catch {
        result(FlutterError(code: "transaction_not_found",
                          message: error.localizedDescription,
                          details: nil))
      }
    }
  }

  @available(iOS 15.0, *)
  private func handleGetAllSubscriptionTransactions(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    Task {
        do {
            let transactions = try await StoreKitManager.shared.getAllSubscriptionTransactions()
            // 将 StoreTransaction 对象数组转换为字典数组
            let transactionDicts = transactions.map { $0.toDictionary() }
            result(transactionDicts)
        } catch {
            result(FlutterError(code: "transactions_not_found",
                              message: error.localizedDescription,
                              details: nil))
        }
    }
  }
}
