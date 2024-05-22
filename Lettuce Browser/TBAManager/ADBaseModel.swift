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
}
