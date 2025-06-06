import StoreKit

@available(iOS 15.0, *)
class StoreKitManager {
    static let shared = StoreKitManager()
    
    private init() {}
    
    /// 获取商品信息
    func getProducts(productIds: [String]) async throws -> [Product] {
        let products = try await Product.products(for: Set(productIds))
        return products.sorted(by: { $0.id < $1.id })
    }
    
    /// 转换商品信息为字典
    func productToDict(_ product: Product) -> [String: String] {
        return [
            "productId": product.id,
            "title": product.displayName,
            "description": product.description,
            "price": product.price.description,
            "priceString": product.displayPrice,
            "currencyCode": product.priceFormatStyle.currencyCode
        ]
    }
    
    /// 转换日期为当前时区的格式化字符串
    private func dateToLocalString(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    /// 获取最新的交易记录
    func getLatestTransaction(productId: String) async throws -> [String: String] {
        // 获取所有验证过的交易
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // 检查是否是指定产品的交易
            if transaction.productID == productId {
                return [
                    "productId": transaction.productID,
                    "transactionId": transaction.id.description,
                    "originalTransactionId": transaction.originalID.description,
                    "purchaseDate": dateToLocalString(transaction.purchaseDate),
                    "expirationDate": dateToLocalString(transaction.expirationDate),
                    "status": transaction.revocationDate == nil ? "active" : "revoked",
                    "isUpgraded": transaction.isUpgraded.description
                ]
            }
        }
        throw StoreError.transactionNotFound
    }
    
    /// 检查是否有活跃的订阅
    func checkActiveSubscription() async throws -> [String: String] {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // 检查是否是活跃的订阅
            if transaction.revocationDate == nil && 
               transaction.expirationDate?.compare(Date()) == .orderedDescending {
                return [
                    "productId": transaction.productID,
                    "transactionId": transaction.id.description,
                    "originalTransactionId": transaction.originalID.description,
                    "purchaseDate": dateToLocalString(transaction.purchaseDate),
                    "expirationDate": dateToLocalString(transaction.expirationDate),
                    "status": "active",
                    "isUpgraded": transaction.isUpgraded.description
                ]
            }
        }
        throw StoreError.noActiveSubscription
    }
    
    /// 购买商品
    func purchase(productId: String) async throws -> [String: String] {
        // 获取商品
        let products = try await Product.products(for: [productId])
        guard let product = products.first else {
            throw StoreError.productNotFound
        }
        
        // 发起购买
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw StoreError.verificationFailed
            }
            
            // 完成交易
            await transaction.finish()
            
            return [
                "productId": transaction.productID,
                "transactionId": transaction.id.description,
                "originalTransactionId": transaction.originalID.description,
                "purchaseDate": dateToLocalString(transaction.purchaseDate),
                "expirationDate": dateToLocalString(transaction.expirationDate),
                "status": "active",
                "isUpgraded": transaction.isUpgraded.description
            ]
            
        case .pending:
            throw StoreError.paymentPending
        case .userCancelled:
            throw StoreError.userCancelled
        @unknown default:
            throw StoreError.unknown
        }
    }
    
    /// 获取消耗品的购买历史
    func getConsumablePurchaseHistory(productId: String) async throws -> [String: String] {
        print("开始查询商品[\(productId)]的购买历史")
        
        for await transaction in Transaction.all {
            print("发现交易记录: \(transaction)")
            
            if case .verified(let verifiedTransaction) = transaction {
                print("已验证的交易: productID=[\(verifiedTransaction.productID)], id=[\(verifiedTransaction.id)]")
                
                if verifiedTransaction.productID == productId {
                    let result = [
                        "productId": verifiedTransaction.productID,
                        "transactionId": verifiedTransaction.id.description,
                        "originalTransactionId": verifiedTransaction.originalID.description,
                        "purchaseDate": dateToLocalString(verifiedTransaction.purchaseDate),
                        "transactionState": verifiedTransaction.revocationDate == nil ? "purchased" : "revoked"
                    ]
                    
                    print("找到匹配的交易记录: \(result)")
                    return result
                }
            } else {
                print("交易验证失败")
            }
        }
        
        print("未找到商品[\(productId)]的购买记录")
        throw StoreError.transactionNotFound
    }
    
    /// 检查商品是否已购买
    func checkIfPurchased(productId: String) async throws -> Bool {
        for await transaction in Transaction.all {
            if case .verified(let verifiedTransaction) = transaction {
                if verifiedTransaction.productID == productId {
                    return true
                }
            }
        }
        return false
    }
    
    /// 交易记录数据结构
    struct StoreTransaction: Codable {
        let productId: String
        let transactionId: String
        let originalTransactionId: String
        let purchaseDate: String
        let expirationDate: String
        let status: String
        let isUpgraded: String
        
        func toDictionary() -> [String: String] {
            return [
                "productId": productId,
                "transactionId": transactionId,
                "originalTransactionId": originalTransactionId,
                "purchaseDate": purchaseDate,
                "expirationDate": expirationDate,
                "status": status,
                "isUpgraded": isUpgraded
            ]
        }
    }
    
    /// 获取所有商品的交易记录
    func getAllSubscriptionTransactions() async throws -> [StoreTransaction] {
        var transactions: [StoreTransaction] = []
        
        //获取账号所有交易记录
        let allTransactions = try await Transaction.all
        
        for await result in allTransactions {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            let storeTransaction = StoreTransaction(
                productId: transaction.productID,
                transactionId: transaction.id.description,
                originalTransactionId: transaction.originalID.description,
                purchaseDate: dateToLocalString(transaction.purchaseDate),
                expirationDate: dateToLocalString(transaction.expirationDate),
                status: transaction.revocationDate == nil ? "active" : "revoked",
                isUpgraded: transaction.isUpgraded.description
            )
                transactions.append(storeTransaction)
        }
        
        if transactions.isEmpty {
            throw StoreError.transactionNotFound
        }
        
        return transactions
    }
}

/// 自定义错误
enum StoreError: LocalizedError {
    case productNotFound
    case transactionNotFound
    case noActiveSubscription
    case verificationFailed
    case paymentPending
    case userCancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "商品未找到"
        case .transactionNotFound:
            return "未找到交易记录"
        case .noActiveSubscription:
            return "没有活跃的订阅"
        case .verificationFailed:
            return "交易验证失败"
        case .paymentPending:
            return "支付处理中"
        case .userCancelled:
            return "用户取消"
        case .unknown:
            return "未知错误"
        }
    }
} 
