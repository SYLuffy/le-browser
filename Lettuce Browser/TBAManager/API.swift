//
//  API.swift
//  TraslateNow
//
//  Created by Super on 2024/3/22.
//

import Foundation
import WebKit
import AdSupport

extension Request {
    
   public class func tbaRequest(_ id: String = UUID().uuidString, key: APIKey, eventKey: String = APIKey.normalEvent.rawValue, value: [String: Any]? = [:], ad: ADBaseModel? = nil,retry: Bool = true) {
        if key.isInstall {
            if !CacheUtil.shared.getInstall(), retry {
                return
            }
            Request.installRequest(id: id) { ret in
                if !ret, retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if CacheUtil.shared.cache(id) != nil {
                            NSLog("[tba] 开始重试上报 install 事件")
                            self.tbaRequest(id, key: key, retry: false)
                        }
                    }
                }
            }
        }
        if key.isSession {
            Request.sessionRequest(id: id) { ret in
                if !ret, retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if CacheUtil.shared.cache(id) != nil {
                            NSLog("[tba] 开始重试上报 session 事件")
                            self.tbaRequest(id, key: key, retry: false)
                        }
                    }
                }
            }
        }
        if key.isFirstOpen {
            if retry, (CacheUtil.shared.cacheOfFirstOpenCount() >= 6) {
                return
            }
            Request.firstOpenRequest(id: id) { ret in
                if !ret, retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if CacheUtil.shared.cache(id) != nil {
                            NSLog("[tba] 开始重试上报 firstOpen 事件")
                            self.tbaRequest(id, key: .firstOpen, retry: false)
                        }
                    }
                } else if ret {
                    CacheUtil.shared.cacheFirstOpenCount()
                }
            }
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
                if CacheUtil.shared.cacheOfFirstOpenCount() >= 6 {
                    timer.invalidate()
                    return
                }
                let nid = UUID().uuidString
                Request.firstOpenRequest(id: nid) { ret in
                    if !ret, retry {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            if CacheUtil.shared.cache(id) != nil {
                                NSLog("[tba] 开始重试上报 firstOpen 事件")
                                self.tbaRequest(nid, key: .firstOpen, retry: false)
                            }
                        }
                    } else if ret {
                        CacheUtil.shared.cacheFirstOpenCount()
                    }
                }
            }
        }
        if let ad = ad, key.isAD {
            Request.adRequest(id: id, ad: ad) { ret in
                if !ret, retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if CacheUtil.shared.cache(id) != nil {
                            NSLog("[tba] 开始重试上报 ad 事件")
                            self.tbaRequest(id, key: key, ad: ad, retry: false)
                        }
                    }
                }
            }
        }
        if key.isEvent {
            Request.eventRequest(id: id, eventKey: eventKey, value: value) { ret in
                if !ret, retry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if CacheUtil.shared.cache(id) != nil {
                            NSLog("[tba] 开始重试上报 \(eventKey) 事件")
                            self.tbaRequest(id, key: .normalEvent, eventKey: eventKey, value: value, retry: false)
                        }
                    }
                }
            }
        }
    }

    private class func installRequest(id: String, completion: ((Bool)->Void)? = nil) {
        NSLog("[tba] 开始上报 install ")
        Request(id: id, parameters: Request.installParam).netWorkConfig { req in
            req.method = .post
            req.key = .install
        }.startRequestSuccess { _ in
            NSLog("[tba] 上报 install 成功 ✅✅✅")
            completion?(true)
        }.error { obj, code in
            NSLog("[tba] 上报 install 失败 ❌❌❌")
            completion?(false)
        }
    }
    
    private class func firstOpenRequest(id: String, completion: ((Bool)->Void)? = nil) {
        NSLog("[tba] 开始上报 first_open ")
        Request(id: id, parameters: Request.firstOpenParam).netWorkConfig { req in
            req.method = .post
            req.key = .firstOpen
        }.startRequestSuccess { _ in
            NSLog("[tba] 上报 first_open 成功 ✅✅✅")
            completion?(true)
        }.error { obj, code in
            NSLog("[tba] 上报 first_open 失败 ❌❌❌")
            completion?(false)
        }
    }
    
    private class func sessionRequest(id: String, completion: ((Bool)->Void)? = nil) {
        NSLog("[tba] 开始上报 session ")
        Request(id: id, parameters: Request.sessionParam).netWorkConfig { req in
            req.method = .post
            req.key = .session
        }.startRequestSuccess { _ in
            NSLog("[tba] 上报 session 成功 ✅✅✅")
            completion?(true)
        }.error { obj, code in
            NSLog("[tba] 上报 session 失败 ❌❌❌")
            completion?(false)
        }
    }
    
    private class func adRequest(id: String, ad: ADBaseModel, completion: ((Bool)->Void)? = nil) {
        NSLog("[tba] 开始上报 ad ")
        Request(id: id, parameters: Request.adParam).netWorkConfig { req in
            req.method = .post
            req.key = .ad
        }.startRequestSuccess { _ in
            NSLog("[tba] 上报 ad 成功 ✅✅✅")
            completion?(true)
        }.error { obj, code in
            NSLog("[tba] 上报 ad 失败 ❌❌❌")
            completion?(false)
        }
    }
    
    private class func eventRequest(id: String, key: APIKey = .normalEvent, eventKey: String = APIKey.normalEvent.rawValue, value: [String: Any]? = nil, completion: ((Bool)->Void)? = nil) {
        if value?.isEmpty != false {
            NSLog("[tba] 开始上报 \(eventKey) param:\(value ?? [:])")
        } else {
            NSLog("[tba] 开始上报 \(eventKey)")
        }
        if eventKey.isEmpty || (eventKey == APIKey.normalEvent.rawValue && key != .firstOpen) {
            debugPrint("")
        }
        Request(id: id, parameters: Request.eventParam).netWorkConfig { req in
            req.method = .post
            req.key = key
            req.eventKey = eventKey
        }.startRequestSuccess { _ in
            NSLog("[tba] 上报 \(eventKey) 成功 ✅✅✅")
            completion?(true)
        }.error { obj, code in
            NSLog("[tba] 上报 \(eventKey) 失败 ❌❌❌")
            completion?(false)
        }
    }
}

public enum APIKey: String, Codable, Equatable {
    // 安装事件
    case install
    case session
    case ad
    case firstOpen = "first_open"
    case normalEvent
    var isInstall: Bool {
        return self == .install
    }
    var isSession: Bool {
        return self == .session
    }
    var isAD: Bool {
        return self == .ad
    }
    var isFirstOpen: Bool {
        return self == .firstOpen
    }
    var isEvent: Bool {
        return self == .normalEvent
    }
}

