//
//  Endpoints.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import Foundation

struct Endpoints {
    
    static let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
    
    static var login: URL {
        return URL(string: "\(baseURL ?? "")/login")!
    }
    
    static var randomQuote: URL {
        return URL(string: "https://api.quotable.io/random")!
    }
    
}
