//
//  KeyManager.swift
//  Runner
//
//  Created by Joseph Rice on 1/24/23.
//

import Foundation

struct KeyManager {
   private let keyFilePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist")
   func getKeys() -> NSDictionary? {
     guard let keyFilePath = keyFilePath else {
       return nil
     }
     return NSDictionary(contentsOfFile: keyFilePath)
   }
   
   func getValue(key: String) -> AnyObject? {
       guard let keys = getKeys() else {
         return nil
       }
     return keys[key]! as AnyObject
   }
}
