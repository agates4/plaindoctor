//
//  KeychainHelper.swift
//  Diagnosix
//
//  Created by Aron Gates on 2/7/17.
//  Copyright © 2017 Aron Gates. All rights reserved.
//

import KeychainSwift

class keychainHelper
{
    public func getUserID() -> String
    {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        if(keychain.get("user_id") != nil)
        {
            return keychain.get("user_id")!
        }
        return "error"
    }
    
    public func getUsername() -> String
    {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        if(keychain.get("username") != nil)
        {
            return keychain.get("username")!
        }
        return "error"
    }
    
    public func clearChain()
    {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        keychain.clear()
    }
}
