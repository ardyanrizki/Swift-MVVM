//
//  NetworkService.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import Foundation

enum NetworkError: Error {
    case noNetwork
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    private let session = URLSession(configuration: .default)
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func login(credential: UserCredential, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        
        guard NetworkMonitor.shared.isNetworkReachable() else {
            completion(.failure(NetworkError.noNetwork))
            return
        }
        
        let body: [String: String] = ["email": credential.email, "password": credential.password]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) else { return }
        
        let url = Endpoints.login
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        session.dataTask(with: request) { (data, _, error) in
            if let error {
                completion(.failure(error))
            } else if let data {
                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(decoded))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
    func getQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        
        guard NetworkMonitor.shared.isNetworkReachable() else {
            completion(.failure(NetworkError.noNetwork))
            return
        }
        
        let url = Endpoints.randomQuote
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: request) { (data, _, error) in
            if let error {
                completion(.failure(error))
            } else if let data {
                do {
                    let decoded = try JSONDecoder().decode(Quote.self, from: data)
                    completion(.success(decoded))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
}
