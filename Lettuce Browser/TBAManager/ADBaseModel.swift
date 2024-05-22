//
//  ADBaseModel.swift
//  Lettuce Browser
//
//  Created by shen on 2024/5/22.
//

import Foundation

/// 用于TBA 广告价值打点
@objc public class ADBaseModel: NSObject, Identifiable {
    ///广告位置
    var position: String = ""
    
    var price: Double = 0.0
    var currency: String = ""
    var network: String = ""
    var loadIP: String = ""
    var impressIP: String = ""
    var theAdID: String = ""
    
    @objc public func objcInit(_ price:Double, _ currency:String, _ network:String, _ loadIP:String, _ impressIP:String, _ theAdID:String) {
        self.price = price;
        self.currency = currency;
        self.network = network;
        self.loadIP = loadIP;
        self.impressIP = impressIP;
        self.theAdID = theAdID
    }
}
