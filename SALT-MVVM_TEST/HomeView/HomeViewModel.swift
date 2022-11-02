//
//  HomeViewModel.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import Foundation

final class HomeViewModel {
    
    var email: ObservableObject<String?> = ObservableObject(nil)
    
    var isSignedOut: ObservableObject<Bool> = ObservableObject(false)
    
    var quote: ObservableObject<Quote?> = ObservableObject(nil)
    
    func isUserTokenStored() -> Bool {
        guard KeychainManager.shared.getToken() != nil else { return false}
        return true
    }
    
    func checkStoredEmail() {
        email.value = UserDefaultsManager.shared.userEmail
    }
    
    func signingOut() {
        UserDefaultsManager.shared.deleteStoredUserEmail()
        KeychainManager.shared.deleteToken()
        
        email.value = nil
        isSignedOut.value = true
    }
    
    func getQuote() {
        NetworkService.shared.getQuote { [weak self] result in
            switch result {
            case .success(let success):
                guard success.author != nil, success.content != nil else {
                    self?.quote.value = nil
                    return
                }
                self?.quote.value = success
            case .failure(_):
                self?.quote.value = nil
            }
        }
    }
    
}
