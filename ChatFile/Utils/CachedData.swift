//
//  CachedData.swift
//  ChatGame
//
//  Created by 2008007NB01 on 2021/2/16.
//

import Foundation

// To be able to use strings as caching keys, we have to use
// NSString here, since NSCache is only compatible with keys
// that are subclasses of NSObject:
//let cache = NSCache<NSString, MyClass>()
//final class Cache<Key: Hashable, Value> {
//    private let wrapped = NSCache<WrappedKey, Entry>()
//}
