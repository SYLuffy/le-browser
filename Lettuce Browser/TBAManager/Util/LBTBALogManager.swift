//
//  LBTBALogManager.swift
//  Lettuce Browser
//
//  Created by shen on 2024/5/17.
//

import Foundation

@objc public class LBTBALogManager:NSObject {
    static func logEvent(name: FirebaseEvent, params: [String: Any]? = nil) {
        FirebaseManager.logEvent(name: name, params: params)
        Request.tbaEventRequest(eventKey: name.rawValue, value: params)
    }
    
    @objc static func objcLogEvent(name: NSString, params: [String: Any]? = nil) {
        if let firebaseEvent = FirebaseEvent(from: name) {
            if name != "session_start" {
                FirebaseManager.logEvent(name: firebaseEvent, params: params)
            }
                Request.tbaEventRequest(eventKey: firebaseEvent.rawValue, value: params)
            } else {
                NSLog("[API] 暂无此上报事件 \(name)")
            }
    }
}
