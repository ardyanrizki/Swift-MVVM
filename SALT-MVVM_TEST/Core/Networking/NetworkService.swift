//
//  NetworkService.swift
//  SALT-MVVM_TEST
//
//  Created by Ardyan on 01/11/22.
//

import Foundation
import Alamofire
import PulseCore

enum NetworkError: Error {
    case noNetwork
}

final class NetworkService {
    
    static let shared = NetworkService()
    let logger: NetworkLogger
    
    private let afSession: Alamofire.Session
    private let session: URLSession
    
    init() {
        URLSessionProxyDelegate.enableAutomaticRegistration()
        logger = NetworkLogger()
        afSession = Alamofire.Session(eventMonitors: [NetworkLoggerEventMonitor(logger: logger)])
        session = URLSession(configuration: .default)
    }
    
    
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
        let headers: HTTPHeaders = ["Content-Type":"application/json"]
        let body: [String: String] = ["email": credential.email, "password": credential.password]
        afSession.request(Endpoints.login, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { response in
            if let error = response.error {
                completion(.failure(error))
            } else if let data = response.data {
                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(decoded))
                }
                catch {
                    completion(.failure(error))
                }
            }
        })
    }
    
    func getQuote(completion: @escaping (Result<Quote, Error>) -> Void) {
        afSession.request(Endpoints.randomQuote).responseJSON(completionHandler: { response in
            if let error = response.error {
                completion(.failure(error))
            } else if let data = response.data {
                do {
                    let decoded = try JSONDecoder().decode(Quote.self, from: data)
                    completion(.success(decoded))
                }
                catch {
                    completion(.failure(error))
                }
            }
        })
    }

    struct NetworkLoggerEventMonitor: EventMonitor {
        let logger: NetworkLogger

        func request(_ request: Request, didCreateTask task: URLSessionTask) {
            logger.logTaskCreated(task)
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            logger.logDataTask(dataTask, didReceive: data)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
            logger.logTask(task, didFinishCollecting: metrics)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            logger.logTask(task, didCompleteWithError: error)
        }
    }
}
