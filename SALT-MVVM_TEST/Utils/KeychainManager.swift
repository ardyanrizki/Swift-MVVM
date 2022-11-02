//
//  KeychainManager.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 02/11/22.
//

import Foundation

final class KeychainManager {
    
    enum KeychainStatus: Error {
        case duplicated
        case unknown(OSStatus)
    }
    
    static let shared = KeychainManager()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String) throws {
        
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        guard status != errSecDuplicateItem  else {
            throw KeychainStatus.duplicated
        }
        
        guard status == errSecSuccess else {
            throw KeychainStatus.unknown(status)
        }
        
    }
    
    func get(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
        
    }
    
    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        SecItemDelete(query)
        
    }
    
    func saveToken(_ token: String) throws {
        guard let email = UserDefaultsManager.shared.userEmail else {
            return
        }
        do {
            let data = Data(token.utf8)
            try KeychainManager.shared.save(data, service: Constants.tokenKey, account: email)
        }
        catch {
            throw error
        }
        
    }
    
    func getToken() -> Data? {
        guard let email = UserDefaultsManager.shared.userEmail else {
            return nil
        }
        return KeychainManager.shared.get(service: Constants.tokenKey, account: email)
    }
    
    func deleteToken() {
        guard let email = UserDefaultsManager.shared.userEmail else {
            return
        }
        KeychainManager.shared.delete(service: Constants.tokenKey, account: email)
    }
    
}
