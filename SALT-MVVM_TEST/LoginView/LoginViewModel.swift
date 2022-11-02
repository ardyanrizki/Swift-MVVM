//
//  LoginViewModel.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import Foundation

final class LoginViewModel {
    
    var email: ObservableObject<String?> = ObservableObject(nil)
    
    var error: ObservableObject<String?> = ObservableObject(nil)
    
    func isUserTokenStored() -> Bool {
        guard KeychainManager.shared.getToken() != nil else { return false}
        return true
    }
    
    func login(credential: UserCredential) {
        NetworkService.shared.login(credential: credential) { [weak self] result in
            switch result {
            case .success(let success):
                guard success.error == nil else {
                    self?.error.value = success.error
                    return
                }
                
                guard let token = success.token else {
                    self?.error.value = "No token available"
                    return
                }
                
                self?.email.value = credential.email
                UserDefaultsManager.shared.setUserEmail(credential.email)
                
                do {
                    try KeychainManager.shared.saveToken(token)
                }
                catch {
                    self?.error.value = error.localizedDescription
                }
                
            case .failure(let failure):
                if let failure = failure as? NetworkError,
                    failure == NetworkError.noNetwork {
                    self?.error.value = "No internet connection."
                } else {
                    self?.error.value = failure.localizedDescription
                }
            }
        }
    }
    
}
