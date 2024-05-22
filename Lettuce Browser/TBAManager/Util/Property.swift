//
//  Property.swift
//  TranslateNow
//
//  Created by yangjian on 2022/6/27.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    var value: T?
    let key: String
    init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.getObject(T.self, forKey: key)
    }
    
    var wrappedValue: T? {
        set  {
            value = newValue
            UserDefaults.standard.setObject(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        get { value }
    }
}


extension UserDefaults {
    func setObject<T: Codable>(_ object: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let object = object else {
            NSLog("[US] object is nil.")
            if self.object(forKey: key) != nil {
                self.removeObject(forKey: key)
            }
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            NSLog("[US] encoding error.")
            return
        }
        self.setValue(encoded, forKey: key)
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            NSLog("[US] data is nil for \(key).")
            return nil
        }
        guard let object = try? JSONDecoder().decode(type, from: data) else {
            NSLog("[US] decoding error.")
            return nil
        }
        return object
    }
}
