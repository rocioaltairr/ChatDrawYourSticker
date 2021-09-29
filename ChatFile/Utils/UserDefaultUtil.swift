//
//  UserDefualtUtil.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/10.
//

import UIKit
extension UserDefaults {
    func imageArray(forKey key: String) -> [UIImage]? {
        guard let array = self.array(forKey: key) as? [Data] else {
            return nil
        }
        return array.compactMap() { UIImage(data: $0) }
    }

    func set(_ imageArray: [UIImage], forKey key: String) {
        self.set(imageArray.compactMap({ $0.jpegData(compressionQuality: 0.5) }), forKey: key)
    }
}

public final class UserDefaultUtil {
    
    public static var standard: UserDefaults = UserDefaults.standard
    
    public static func setupStandard(groupName: String) {
        if let ud = UserDefaults(suiteName: groupName) {
            standard = ud
        }
    }
    func imageArray(forKey key: String) -> [UIImage]? {
        guard let array = UserDefaultUtil.standard.array(forKey: key) as? [Data] else {
            return nil
        }
        return array.compactMap() { UIImage(data: $0) }
    }
    
    func set(_ imageArray: [UIImage], forKey key: String) {
        UserDefaultUtil.standard.set(imageArray.compactMap({ $0.jpegData(compressionQuality: 0.5) }), forKey: key)
    }
    // save
    public static func save(key: String, saveObj: Any) {
        standard.set(saveObj, forKey: key)
        standard.synchronize()
    }

    // load
    public static func getAllKeysAndValues() -> [String : Any] {
        return standard.dictionaryRepresentation()
    }
    
    public static func loadFromSearchKeySubString(searchStr: String) -> [String: Any] {
        let arr = UserDefaultUtil.getAllKeysAndValues()
        var dic: [String: Any] = [:]
        for item in arr {
            if item.key.contains(searchStr) {
                dic[item.key] = item.value
            }
        }
        return dic
    }

    public static func load(key: String) -> String {
        if let str = standard.string(forKey: key){
            return str
        }
        return ""
    }
    

    public static func loadData(key: String) -> Data {
        if let data = standard.data(forKey: key){
            return data
        }
        return "".data(using: .utf8)!
    }

    public static func loadArray(key: String) -> [Any] {
        if let arr = standard.array(forKey: key){
            return arr
        }
        return []
    }

    public static func loadDictionary(key: String) -> [String : Any] {
        if let dic = standard.dictionary(forKey: key) {
            return dic
        }
        return [:]
    }

    // remove
    public static func remove(key: String) {
        standard.removeObject(forKey: key)
        standard.synchronize()
    }
    
    public static func removeAll() {
        let arr = UserDefaultUtil.getAllKeysAndValues()
        for item in arr {
            UserDefaultUtil.remove(key: item.key)
        }
        standard.synchronize()
    }
}

