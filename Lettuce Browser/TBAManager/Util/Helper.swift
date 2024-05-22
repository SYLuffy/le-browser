//
//  Helper.swift
//  TranslateNow
//
//  Created by yangjian on 2022/6/27.
//

import Foundation
import Combine
import SwiftUI

let AppLink = "https://itunes.apple.com/cn/app/id"

extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(.sRGB, red: components.R, green: components.G, blue: components.B, opacity: alpha)
    }
    
    static var randomColor: Color {
        let r = Double.random(in: 40..<150)
        let g = Double.random(in: 40..<200)
        let b = Double.random(in: 40..<200)
        if #available(iOS 15.0, *) {
            return Color(uiColor: UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0))
        } else {
            return Color(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
        }
    }
    
    static var themeColor: Color {
        return .init(hex: 0x2A6CFF)
    }
}

extension Font {
    public static func custom(size: Double, weight: UIFont.Weight) -> Font {
        switch weight {
        case .bold:
            return .custom("Roboto-Bold", size: size)
        case .medium:
            return .custom("Roboto-Medium", size: size)
        case .regular:
            return .custom("Roboto-Regular", size: size)
        default:
            return .custom("Roboto", size: size)
        }
    }
}

extension Double {
    public func timeString() -> String {
        if self < 60 {
            return String(format: "00:00:%02d", Int(self))
        } else if self < 60 * 60 {
            let min = Int(self) / 60
            let sec = Int(self) % 60
            return String(format: "00:%02d:%02d", min, sec)
        } else {
            let hour = Int(self) / 60 / 60
            let min = (Int(self) - hour * 3600) / 60
            let sec = Int(self) % 60
            if self < 99 * 60 * 60 {
                return String(format: "%02d:%02d:%02d", hour, min, sec)
            } else {
                return String(format: "%d:%02d:%02d", hour, min, sec)
            }
        }
    }
}


struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
 
    var body: some View {
        GeometryReader { geometry in
            Path { path in
 
                let w = geometry.size.width
                let h = geometry.size.height
 
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
 
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isVisible = false
    @Published var isShow = false

    var keyboardCancellable: Cancellable?
    var keyboardHidenCancellable: Cancellable?

    init() {
        keyboardCancellable = NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                self.isShow = true
                self.isVisible = keyboardFrame.minY < UIScreen.main.bounds.height
                self.keyboardHeight = self.isVisible ? (keyboardFrame.height / 2.0 + 10) : 0
            }
        keyboardHidenCancellable = NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillHideNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                self.isShow = false
                self.keyboardHeight = 0
            }
    }
    
}
