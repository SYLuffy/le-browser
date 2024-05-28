//
//  LBCloakRequest.swift
//  Lettuce Browser
//
//  Created by shen on 2024/5/19.
//

import Foundation
import UIKit
import Combine
import AdSupport

class SubscriptionToken {
    var cancelable: AnyCancellable?
    func unseal() { cancelable = nil }
}

extension AnyCancellable {
    /// 需要 出现 unseal 方法释放 cancelable
    func seal(in token: SubscriptionToken) {
        token.cancelable = self
    }
}

// 请求 cloak
public struct LBCloakRequest {
    
    
   public static func requestCloak(retry: Int = 3) {
        if retry == 0 {
            NSLog("[cloak] 重试超过三次了")
            return
        }
        
        if let go = CacheUtil.shared.go {
            NSLog("[cloak] 当前已有cloak 是否是激进模式: \(go)")
            return
        }
        
//        if AppUtil.isDebug {
//            NSLog("[cloak] is debug")
//            return
//        }
        
        let token = SubscriptionToken()
        var url = "https://leash.lettucebrowserios.com/priory/lumber/mescal"
        var params: [String: String] = [:]
        let ts = Date().timeIntervalSince1970 * 1000.0
        params["carol"] = CacheUtil.shared.getUUID()
        params["befog"] = "\(Int(ts))"
        params["katmandu"] = UIDevice.current.model
        params["placenta"] = Bundle.main.bundleIdentifier
        params["emigrant"] = UIDevice.current.systemVersion
        params["quart"] = UIDevice.current.identifierForVendor?.uuidString
        params["aircraft"] = ""
        params["bout"] = ""
        params["pinscher"] = "proto"
        params["sincere"] =  ASIdentifierManager.shared().advertisingIdentifier.uuidString
        params["gizzard"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        url.append("?")
        let ret = params.keys.map { key in
            "\(key)=\(params[key] ?? "")"
        }.joined(separator: "&")
        url.append(ret)
        if let query = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            url = query
        }
        NSLog("[cloak] start request: \(url)")
        URLSession.shared.dataTaskPublisher(for: URL(string: url)!).map({
            String(data: $0.data, encoding: .utf8)
        }).eraseToAnyPublisher().sink { complete in
            if case .failure(let error) = complete {
                NSLog("[cloak] err:\(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.requestCloak(retry: retry - 1)
                }
            }
            token.unseal()
        } receiveValue: { data in
            NSLog("[cloak] \(data ?? "")")
            if data == "heron" {
                CacheUtil.shared.go = true;
            }else {
                CacheUtil.shared.go = false;
            }
        }.seal(in: token)
    }
}

struct IPResponse: Codable {
    var ip: String?
    var city: String?
    var country: String?
}

// 请求当前本地IP
struct RequestIP{
    
    func requestIP(retry: Int = 3) {
        if retry == 0 {
            NSLog("[IP] 重试超过3次了")
        }
        let token = SubscriptionToken()
        NSLog("[IP] 开始请求")
        URLSession.shared.dataTaskPublisher(for: URL(string: "https://ipinfo.io/json")!).map({
            $0.data
        }).eraseToAnyPublisher().decode(type: IPResponse.self, decoder: JSONDecoder()).sink { complete in
            if case .failure(let error) = complete {
                NSLog("[IP] err:\(error)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.requestIP(retry:  retry - 1)
                }
            }
            token.unseal()
        } receiveValue: { response in
            NSLog("[IP] 当前国家:\(response.country ?? "")")
//            store.dispatch(.rootUpdateIP(response.ip))
            if response.country == "CN" {
            }
        }.seal(in: token)
    }

}

struct DecodeMode: Codable {
    var ts: String
    var lt: String
}

extension String {
    var base64DecodeString: String? {
        if let decodeData = Data(base64Encoded: self) {
            if let decodeString = String(data: decodeData, encoding: .utf8) {
                return decodeString
            }
            return nil
        }
        return nil
    }
}
