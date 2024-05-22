//
//  Request+Ext.swift
//  TraslateNow
//
//  Created by Super on 2024/3/25.
//

import Foundation

public extension Request {
    static func preloadPool() {
        ReachabilityUtil.shared.startMonitoring()
        /// 测试地址  https://test-navajo.lettucebrowserios.com/qs/cavemen/artifice
        /// 正式地址 https://navajo.lettucebrowserios.com/portage/bent
        Request.url =  "https://navajo.lettucebrowserios.com/portage/bent"
        Request.osString = "proto"
        Request.att = [true: "anita", false: "laurie"]
        Request.logKeyName = "rototill"
        Request.dateKeyNames = ["befog", "corvette", "mambo", "parabola", "bluebush", "jig", "guiana"]
        
        // 公共参数
        var parameters: [String: Any] = [:]
        var  siegel: [String: Any] = [:]
        siegel["pliable"] = Request.parametersPool()["manufacturer"]
        siegel["rototill"] = Request.parametersPool()["log_id"]
        siegel["mckenzie"] = Request.parametersPool()["brand"]
        siegel["quart"] = Request.parametersPool()["idfv"]

        siegel["lability"] = Request.parametersPool()["operator"]
        siegel["fluoride"] = Request.parametersPool()["channel"]
        siegel["gizzard"] = Request.parametersPool()["app_version"]
        siegel["pinscher"] = Request.parametersPool()["os"]
        siegel["parade"] = Request.parametersPool()["ip"]
        siegel["katmandu"] = Request.parametersPool()["device_model"]
        siegel["placenta"] = Request.parametersPool()["bundle_id"]
        siegel["houghton"] = Request.parametersPool()["os_country"]
        siegel["thigh"] = Request.parametersPool()["system_language"]

        siegel["scylla"] = Request.parametersPool()["zone_offset"]
        siegel["emigrant"] = Request.parametersPool()["os_version"]
        siegel["befog"] = Request.parametersPool()["client_ts"]
        siegel["aircraft"] = Request.parametersPool()["gaid"]
        siegel["sincere"] = Request.parametersPool()["idfa"]
        siegel["purloin"] = Request.parametersPool()["network_type"]
        siegel["carol"] = Request.parametersPool()["distinct_id"]

        parameters["siegel"] = siegel
        parameters["neath"] = ["pro_borth": Locale.current.regionCode ?? ""]
        Request.commonParam = parameters
        
        var commonHeader: [String: String] = [:]
        commonHeader["purloin"] = "\(Request.parametersPool()["network_type"] ?? "")"
        commonHeader["rototill"] = "\(Request.parametersPool()["log_id"] ?? "")"
        commonHeader["lability"] = "\(Request.parametersPool()["operator"] ?? "")"
        Request.commonHeader = commonHeader
        
        var commonQuery: [String: String] = [:]
        commonQuery["pinscher"] = "\(Request.parametersPool()["os"] ?? "")"
        commonQuery["rototill"] = "\(Request.parametersPool()["log_id"] ?? "")"
        Request.commonQuery = commonQuery
        
        var installParam: [String: Any] = [:]
        installParam["nosy"] = Request.parametersPool()["build"]
        installParam["hedonism"] = Request.parametersPool()["user_agent"]
        installParam["pushpin"] = Request.parametersPool()["lat"]
        installParam["corvette"] = Request.parametersPool()["referrer_click_timestamp_seconds"]
        installParam["mambo"] = Request.parametersPool()["install_begin_timestamp_seconds"]
        installParam["parabola"] = Request.parametersPool()["referrer_click_timestamp_server_seconds"]
        installParam["bluebush"] = Request.parametersPool()["install_begin_timestamp_server_seconds"]
        installParam["jig"] = Request.parametersPool()["install_first_seconds"]
        installParam["guiana"] = Request.parametersPool()["last_update_seconds"]
        Request.installParam = ["octavia": installParam]
        
        let sessionParam: [String: Any] = [:]
        Request.sessionParam = ["slump": sessionParam]
        
        // first open
        Request.firstOpenParam = ["jockey": "first_open"]
    }
    
    static func tbaADRequest(ad: ADBaseModel?) {
        var adParam: [String: Any] = [:]
        adParam["shinbone"] = (ad?.price ?? 0) * 1000000
        adParam["embalm"] = ad?.currency ?? "USD"
        adParam["instar"] = ad?.network ?? ""
        adParam["hiawatha"] = "admob"
        adParam["lingual"] = ad?.theAdID
        adParam["turk"] = ad?.position ?? ""
        adParam["vile"] = ""
        adParam["dam"] = ad?.position ?? ""
        adParam["detente"] = ad?.loadIP ?? ""
        adParam["mob"] = ad?.impressIP ?? ""
        Request.adParam = ["berne":adParam];
        Request.tbaRequest(key: .ad, ad: ad)
    }
    
     static func tbaEventRequest(_ key: APIKey = .normalEvent, eventKey: String = "", value: [String: Any]? = nil) {
        var eventParam: [String: Any] = [:]
        eventParam["jockey"] = eventKey
        if let realValue = value {
            eventParam["censure"] = realValue
        }
        Request.eventParam = eventParam
        Request.tbaRequest(key: .normalEvent, eventKey: eventKey, value:  value)
    }
}
