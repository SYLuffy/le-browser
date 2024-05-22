//
//  FirebaseManager.swift
//  TranslateNow
//
//  Created by yangjian on 2022/6/27.
//

import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    
    static func logEvent(name: FirebaseEvent, params: [String: Any]? = nil) {
        
        if name.first {
            if UserDefaults.standard.bool(forKey: name.rawValue) == true {
                return
            } else {
                UserDefaults.standard.set(true, forKey: name.rawValue)
            }
        }
        
        #if DEBUG
        #else
        Analytics.logEvent(name.rawValue, parameters: params)
        #endif
        
        NSLog("[ANA] [Event] \(name.rawValue) \(params ?? [:])")
    }
    
    static func logProperty(name: FirebaseProperty, value: String? = nil) {
        
        var value = value
        
        if name.first {
            if UserDefaults.standard.string(forKey: name.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: name.rawValue)!
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: name.rawValue)
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: name.rawValue)
#endif
        NSLog("[ANA] [Property] \(name.rawValue) \(value ?? "")")
    }
}

enum FirebaseProperty: String {
    /// 設備
    case local = "region"
    
    var first: Bool {
        switch self {
        case .local:
            return true
        }
    }
}

enum FirebaseEvent: String {
    /// 便于OC调用
    init?(from nsString: NSString) {
        self.init(rawValue: nsString as String)
    }
    
    var first: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }
    
    ///任意界面出现打点
    case sessionStart = "session_start"
    
    /// 首次打開
    ///  打点时机：第一次获取到真正设备国家属性后打点
    case open = "pro_lun"
    /// 冷啟動
    ///  冷启动的 loading 界面出现立即打点冷启动
    case openCold = "pro_clod"
    /// 熱起動
    ///  热启动的 loading 界面出现立即打点热启动
    case openHot = "pro_hot"
    
    /// 主頁展示
    /// 热启动时只计一次（首页 - loading - 首页，只计一次首页）
    case homeShow = "pro_impress"
    
    /// 点击导航页中的 8 个网站
    /// bro（点击的网站）：facebook / google / youtube / twitter / instagram / amazon / tiktok / yahoo
    case homeNav = "pro_nav"
    
    /// 在导航页上方输入栏中输入内容，并点击键盘上的 search
    ///- 输入空白内容不打
    ///- 仅在导航页中输入并搜索才打
    case homeSearch = "pro_search"
    
    /// 点击操作栏中的清理按钮
    case homeClean = "pro_clean"
    
    ///  清理动画展示完成
    case cleanAnimationed = "pro_cleanDone"
    
    /// 展示清理成功的toast
    /// bro（点击清理按钮～展示 toast 的时间）：秒，时间向上取整，不足 1 计 1
    case cleanToast = "pro_cleanToast"
    
    ///  展示 tab 管理页
    case homeShowTab = "pro_showTab"
    
    ///点击开启新 tab 按钮时，立马打点
    ///- 包括：tab 管理页点击底部加号、设置弹窗点击加号
    ///bro（点击开启新 tab 按钮的位置）：tab（tab 管理页）/ setting（设置弹窗）
    case homeClickTab = "pro_clickTab"
    
    /// 分享按钮
    case homeClickShare = "pro_share"
    
    /// copy 按钮
    case homeClickCopy = "pro_copy"
    
    ///  浏览器中开始请求新网址
    ///  无论是手动输入进行搜索 / 点击网页中内容，都打
    case homeRequist = "pro_requist"
    
    /// 浏览器中新网址加载成功
    ///  bro（开始请求～加载成功的时间）：秒，时间向上取整，不足 1 计 1
    case homeUrlLoaded = "pro_load"
    
// MARK: VPN event
    // Vpn 首页展示次数，每次首页展示都打
    // - 热启动时只计一次（首页 - loading - 首页，只计一次首页）
    // - 在首页关闭弹窗（eg. 升级弹窗、权限弹窗），不计
    case vpnHomeShow = "pro_1"
    
    // 从 vpn 主页点击返回退出到浏览器主页
    // - 只统计主动触发的，自动触发退出操作不计
    case vpnHomeBack = "pro_homeback"
    
    // 触发连接操作（进入连接的方法）
    // - 首页点击连接（按钮 / 图标）
    // - 在服务器列表点击任一国家服务器（包括：未连接时选择国家 / 已连接时选择国家）
    // - 在获取 vpn 权限后才会计
    // - 手机没有打开网络，不计
    case vpnConnect = "pro_link"
    
    // 本次触发连接操作中，连接 vpn 失败（拉起通道失败）
    // rot （服务器的 ip）：ip 地址
    case vpnConnectError = "pro_link1"
    
    // 本次触发连接操作中，连接 vpn 成功（拉起通道）
    // - app 在后台时，vpn 库挂掉然后自动连接，不计
    // rot （服务器的 ip）：ip 地址
    case vpnConnectSuccess = "pro_link2"
    
    
    // 本次触发连接操作中，调用拉起通道
    // rot （服务器的 ip）：ip 地址
    case vpnConnectStart = "pro_link0"
    
    // 弹出 VPN 的系统权限
    case vpnPermiss = "pro_pm"
    // 在弹窗中同意 VPN 的系统权限
    case vpnPermiss0 = "pro_pm2"
    case vpnPermiss1 = "pro_pm1"
    
    // 连接成功弹出结果页
    case vpnConnectResult = "pro_re1"
    case vpnDisconnectResult = "pro_re2"
    

    /// 主动触发断开连接操作
    /// - 首页点击断开连接（按钮 / 图标）
    /// - 不包括：已连接状态下，在服务器列表选择新国家回到首页，自动触发断开操作
    /// duration：从连接vpn成功到主动触发断开成功的使用时长
    case vpnDisconnectManual = "pro_disLink"
    
    /// 连接成功结果页，点击返回
    case vpnConnectResultBack = "pro_re1_back"
    /// 断开成功结果页，点击返回
    case vpnDisconnectResultBack = "pro_re2_back"

    
    // 弹出 vpn 引导页面
    case vpnGuideShow = "pro_pop"
    // Vpn 引导界面点击 skip 按钮
    case vpnGuideSkip = "pro_pop0"
    case vpnGuideOK = "pro_pop1"

}
