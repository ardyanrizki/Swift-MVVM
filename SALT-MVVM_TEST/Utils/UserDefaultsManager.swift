//
//  UserDefaultsManager.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 02/11/22.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    var userEmail: String? = UserDefaults.standard.string(forKey: Constants.userEmailKey)
    
    func setUserEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: Constants.userEmailKey)
    }
    
    func deleteStoredUserEmail() {
        UserDefaults.standard.removeObject(forKey: Constants.userEmailKey)
    }
    
}
