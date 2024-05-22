//
//  CacheUtil.swift
//  TraslateNow
//
//  Created by Super on 2024/3/15.
//

import Foundation
import WebKit
import FirebaseRemoteConfig

struct FBPrice: Codable {
    var price: Double
    var currency: String
}

struct RequestCache: Codable, Identifiable {
    var id: String // 用于请求缓存ID, 唯一
    var key: APIKey
    var eventKey: String // 用于业务区别
    
    var parameter: Data
    var query: String
    var header: [String: String]
    var date = Date()
    
    init(_ id: String, key: APIKey, eventKey: String, req: URLRequest?) {
        self.id = id
        self.eventKey = eventKey
        self.key = key
        parameter = req?.httpBody ?? Data()
        if #available(iOS 16.0, *) {
            query =  req?.url?.query() ?? ""
        } else {
            // Fallback on earlier versions
            if let url = req?.url, let ulrComponenets = URLComponents(url: url , resolvingAgainstBaseURL: false) {
                if let items = ulrComponenets.queryItems {
                    query = items.map({"\($0.name)=\($0.value ??  "")"}).joined(separator: "&")
                } else {
                    query = ""
                }
            } else {
                query = ""
            }
        }
        header = req?.allHTTPHeaderFields ?? [:]
    }
}


@objc public class CacheUtil: NSObject {
    static let shared = CacheUtil()
    
    var timer: Timer? = nil
    
    // 是否进入过后台 用于冷热启动判定
    var enterBackgrounded = false
    
    @UserDefault(key: "apis")
    private var caches: [RequestCache]?
    
    @UserDefault(key: "first.install")
    private var install: Bool?
    
    @UserDefault(key: "user.agent")
    private var userAgent: String?
    
    @UserDefault(key: "first.open.count")
    private var firstOpenSuccessCnt: Int?
    
    @UserDefault(key: "first.open.fail.count")
    private var firstOpenFailCnt: Int?
    
    @UserDefault(key: "first.notification")
    private var firstNoti: Bool?
    
    // fb广告价值回传
    @UserDefault(key: "facebook.price")
    var fbPrice: FBPrice?
    
    @UserDefault(key: "user.go")
    var go: Bool?
    /// 默认 激进模式
    func getUserGo() -> Bool {
        go ?? true
    }
    
    @UserDefault(key: "uuid")
    private var uuid: String?
    func getUUID() -> String {
        if let uuid = uuid {
            return uuid
        } else {
            let uuid = UUID().uuidString
            self.uuid = uuid
            return uuid
        }
    }
    @UserDefault(key: "ip")
    private var ip: String?
    func setIP(_ ip: String) { self.ip = ip }
    func getIP() -> String { ip ?? "" }
    
    override init() {
        super.init()
        self.timer =  Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] timer in
            self?.uploadRequests()
        }
        ReachabilityUtil.shared.networkUpdated = {ret in
            if ret {
                // 网络变化 直接上传
                self.uploadRequests()
            }
        }
    }
    
    
    // MARK - 网络请求失败参数缓存
    func uploadRequests() {
        // 实时清除两天内的缓存 2024 05/09 缓存永久保留，直到请求成功
//        self.caches = self.caches?.filter({
//            $0.date.timeIntervalSinceNow > -2 * 24 * 3600
//        })
        // 批量上传
        self.caches?.prefix(50).forEach({
            Request.tbaRequest($0.id, key: $0.key, eventKey: $0.eventKey, retry: false)
        })
    }
    func appendCache(_ cache: RequestCache) {
        if var caches = caches {
            let isContain = caches.contains {
                $0.id == cache.id
            }
            if isContain {
                return
            }
            caches.append(cache)
            self.caches = caches
        } else {
            self.caches = [cache]
        }
    }
    func removeCache(_ id: String) {
        self.caches = self.caches?.filter({
            $0.id != id
        })
    }
    func cache(_ id: String) -> RequestCache? {
        self.caches?.filter({
            $0.id == id
        }).first
    }
    
    func cacheOfFirstOpenCount() -> Int {
        firstOpenSuccessCnt ?? 0
    }
    
    func cacheOfFirstOpenFailCount()-> Int {
        firstOpenFailCnt ?? 0
    }
    
    func cacheFirstOpenCount() {
        firstOpenSuccessCnt = cacheOfFirstOpenCount() + 1
    }
    
    func cacheFirstOpenFailStrctCount() {
        firstOpenFailCnt = cacheOfFirstOpenFailCount() - 1
    }
    
    func cacheFirstOpenFailCount() {
        firstOpenFailCnt = cacheOfFirstOpenFailCount() + 1
    }
    
    
    
    // 首次判定 关于install first open enterbackground
    func getInstall() -> Bool {
        let ret = install ?? true
        install = false
        return ret
    }
    func getFirstNoti() -> Bool {
        let ret = firstNoti ?? true
        return ret
    }
    func updateFirstNoti() {
        firstNoti = false
    }
    
    
    func enterBackground() {
        enterBackgrounded = true
    }
    
    
    // userAgent
    func getUserAgent() -> String {
        if Thread.isMainThread, self.userAgent == nil {
            self.userAgent = UserAgentFetcher().fetch()
        } else if let userAgent = self.userAgent {
            return userAgent
        }
        return ""
    }

    func uploadFirstOpenSuccess() {
        firstOpenSuccessCnt =  (firstOpenSuccessCnt ?? 0) + 1
    }
    
    func getFirstOpenCnt() -> Int {
        firstOpenSuccessCnt ?? 0
    }
    
    @objc static public func objecGetUserGo () -> (Bool) {
        return self.shared.getUserGo()
    }
    
    @objc static public func ocneedUploadFBPrice () -> (Double) {
        let ret = self.shared.needUploadFBPrice()
        if ret.0 {
            return ret.1.price
        }
        return 0.0
    }
    
    func needUploadFBPrice() -> (Bool, FBPrice) {
        NSLog("[FB+Adjust] 当前正在积累广告价值 总价值： \(fbPrice?.price ?? 0) 单位：\(fbPrice?.currency ?? "")")
        let ret = (fbPrice?.price ?? 0.0) > 0.01
        if ret {
            // 清空
            NSLog("[FB+Adjust] 当前广告价值达到要求进行上传 并清空本地 总价值： \(fbPrice?.price ?? 0) 单位：\(fbPrice?.currency ?? "")")
            let b = fbPrice ?? .init(price: 0, currency: "USD")
            fbPrice = nil
            return (true, b)
        }
        return (false, fbPrice ?? .init(price: 0, currency: "USD"))
    }
    
    @objc static public func ocAddFBPrice(price: Double, currency: String) {
        self.shared.addFBPrice(price: price, currency: currency)
    }
    
 @objc public func addFBPrice(price: Double, currency: String) {
        if let fbPrice = fbPrice, fbPrice.currency == currency {
            self.fbPrice = FBPrice(price: fbPrice.price + price, currency: currency)
        } else {
            fbPrice = FBPrice(price: price, currency: currency)
        }
    }
}

public final class UserAgentFetcher: NSObject {
    
    private let webView: WKWebView = WKWebView(frame: .zero)
    
    @objc
    public func fetch() -> String {
        dispatchPrecondition(condition: .onQueue(.main))

        var result: String?
        
        webView.evaluateJavaScript("navigator.userAgent") { response, error in
            if error != nil {
                result = ""
                return
            }
            
            result = response as? String ?? ""
        }

        while (result == nil) {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
        }

        return result ?? ""
    }
    
}
