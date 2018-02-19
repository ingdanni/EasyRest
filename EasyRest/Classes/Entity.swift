//
//  Entity.swift
//  Upboard
//
//  Created by Danny Narvaez on 1/25/18.
//  Copyright © 2018 ingdanni. All rights reserved.
//

import Foundation
import Alamofire

public class Entity: Restful {

    let url: String
    
    public init(name: String) {
        self.url = APIManager.shared.baseUrl!.appending("/\(name)")
    }
    
    // MARK: - Alamofire Manager setup
    
    var alamofireManager: Alamofire.SessionManager! = nil
    
    var alamofire: Alamofire.SessionManager {
        if alamofireManager == nil {
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = APIManager.shared.timeOutInterval
            configuration.httpAdditionalHeaders = APIManager.shared.httpAdditionalHeaders
            
            alamofireManager = Alamofire.SessionManager(configuration: configuration,serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        }
        
        return alamofireManager
    }
    
    /// Server trust policies setup
    var serverTrustPolicies: [String : ServerTrustPolicy] {
        get {
            return [APIManager.shared.baseUrl!: .disableEvaluation]
        }
    }
    
    // MARK: - GET methods
    
    /// Executes an HTTP GET request
    /// - parameter completion: Closure that takes response's data and error string
    public func get(completion: @escaping (Data?, String?) -> Void) {
        fetch(url: url, method: HTTPMethod.get) { completion($0, $1) }
    }
    
    /// Executes an HTTP GET request
    /// - parameter type:       Codable object type for parsing response
    /// - parameter completion: Closure that takes response's data and error string
    public func get<D>(as type: D.Type, completion: @escaping (D?, String?) -> Void) where D : Decodable {
        fetchAndParse(url: url, method: HTTPMethod.get, as: type) { completion($0, $1) }
    }
    
    /// Executes an HTTP GET request
    /// - parameter id:         Entity id
    /// - parameter completion: Closure that takes response's data and error string
    public func get<T>(_ id: T, completion: @escaping (Data?, String?) -> Void) {
        let _url = "\(url)/\(id)"
        fetch(url: _url, method: HTTPMethod.get, body: nil) { completion($0, $1) }
    }
    
    /// Executes an HTTP GET request
    /// - parameter id:         Entity id
    /// - parameter type:       Codable object type for parsing response
    /// - parameter completion: Closure that takes response's data and error string
    public func get<T, D>(_ id: T, as type: D.Type, completion: @escaping (D?, String?) -> Void) where D : Decodable {
        let _url = "\(url)/\(id)"
        fetchAndParse(url: _url, method: HTTPMethod.get, as: type) { completion($0, $1) }
    }
    
    // MARK: - POST methods
    
    /// Executes HTTP POST request
    public func post<E: Codable>(_ body: E, completion: @escaping (Data?, String?) -> Void) {
        fetch(url: url, method: .post, body: body.dictionary) { completion($0, $1) }
    }
    
    /// Executes HTTP POST request
    public func post<E: Codable, D: Decodable>(_ body: E, as type: D.Type, completion: @escaping (D?, String?)-> Void) {
        fetchAndParse(url: url, method: .post, body: body.dictionary, as: type) { completion($0, $1) }
    }
    
    // MARK: - PUT methods
    
    /// Executes HTTP PUT request
    public func put<T, E>(_ id: T, body: E, completion: @escaping (Data?, String?) -> Void) where E : Decodable, E : Encodable {
        let _url = "\(url)/\(id)"
        fetch(url: _url, method: .put, body: body.dictionary) { completion($0, $1) }
    }
    
    /// Executes HTTP PUT request
    public func put<T, E, D>(_ id: T, body: E, as type: D.Type, completion: @escaping (D?, String?) -> Void) where E : Decodable, E : Encodable, D : Decodable {
        let _url = "\(url)/\(id)"
        fetchAndParse(url: _url, method: .put, body: body.dictionary, as: type) { completion($0, $1) }
    }
    
    // MARK: DELETE methods
    
    /// Executes HTTP DELETE request
    public func delete<T>(_ id: T, completion: @escaping (Data?, String?) -> Void) {
        let _url = "\(url)/\(id)"
        fetch(url: _url, method: .delete) { completion($0, $1) }
    }
    
    /// Executes HTTP DELETE request
    public func delete<T, D>(_ id: T, as type: D.Type, completion: @escaping (D?, String?) -> Void) where D : Decodable {
        let _url = "\(url)/\(id)"
        fetchAndParse(url: _url, method: .delete, as: type) { completion($0, $1) }
    }
    
}

// MARK: - Entity Extension

extension Entity {
    
    /// Executes HTTP request
    /// - parameter url:        Absolute url of request
    /// - parameter method:     HTTP method
    /// - parameter body:       A dictionary containing request's body
    /// - parameter completion: Escaping closure containing data and errors
    public func fetch(url: String, method: HTTPMethod, body: Parameters? = nil, completion: @escaping (Data?, String?) -> Void) {
        alamofire.request(url, method: method, parameters: body, encoding: JSONEncoding.default)
            .validate()
            .responseJSON {
                response in
                switch response.result {
                case .success(_):
                    completion(response.data, nil)
                case .failure(_):
                    let err = self.APIError(response.response!.statusCode)
                    completion(nil, err)
                }
        }
    }
    
    /// Executes HTTP request and parses response to Codable object type
    /// - parameter url:        Absolute url of request
    /// - parameter method:     HTTP method
    /// - parameter body:       A dictionary containing request's body
    /// - parameter as:         Codable type for response
    /// - parameter completion: Escaping closure containing data and errors
    public func fetchAndParse<D>(url: String, method: HTTPMethod, body: Parameters? = nil, as type: D.Type, completion: @escaping (D?, String?) -> Void) where D : Decodable {
        alamofire.request(url, method: method, parameters: body, encoding: JSONEncoding.default)
            .validate()
            .responseJSON {
                response in
                switch response.result {
                case .success(_):
                    let decoder = JSONDecoder()
                    do {
                        let row = try decoder.decode(type, from: response.data!)
                        completion(row, nil)
                    } catch {
                        let err = self.APIError(777)
                        completion(nil, err)
                    }
                case .failure(_):
                    let err = self.APIError(response.response!.statusCode)
                    completion(nil, err)
                }
        }
    }
    
    // TODO: - Process API errors
    
    /// Process errors code into a custom description
    /// - parameter code: HTTP request status code
    /// - returns: Flat string containing error description
    public func APIError(_ code: Int) -> String {
        switch code {
        case 200, 201, 202:
            return "Request was processed succesfully"
        case 400, 401, 403, 404:
            return "Could not find any data"
        case 500, 501, 502, 505:
            return "There was an unexpected error"
        case 777:
            return "Parsing error"
        default:
            return "An error ocurred"
        }
    }
    
    /// Transform query parameters in flat string
    public func transform<T>(_ parameters: [String: T]) -> String {
        var params = "?"
        for (key, value) in parameters { params.append("\(key)=\(value)&") }
        params = String(params.dropLast(1))
        return params
    }
    
    // MARK: - Query methods
    
    /// Executes HTTP GET request with customized route and query parameters
    /// - parameter routeParams:        An array of generic types
    /// - parameter queryParams:        An array of generic types (could be nil)
    /// - parameter completion:         A closure containing request response and errors
    public func query<T>(_ routeParams: [T], queryParams: [String: T]? = nil, completion: @escaping (Data?, String?) -> Void) {
        var params = routeParams.flatMap({"\($0)"}).joined(separator: "/")
        if let queryParams = queryParams { params.append(transform(queryParams)) }
        let customUrl = "\(url)/\(params)"
        fetch(url: customUrl, method: .get) { completion($0, $1) }
    }
    
    /// Executes HTTP GET request with customized route and query parameters
    /// - parameter routeParams:        An array of generic types
    /// - parameter queryParams:        An array of generic types (could be nil)
    /// - parameter type:               Codable object type for parsing response
    /// - parameter completion:         A closure containing request response and errors
    public func query<T, D: Decodable>(_ routeParams: [T], queryParams: [String: T]? = nil, as type: D.Type, completion: @escaping (D?, Any?)-> Void) {
        var params = routeParams.flatMap({"\($0)"}).joined(separator: "/")
        if let queryParams = queryParams { params.append(transform(queryParams)) }
        let customUrl = "\(url)/\(params)"
        fetchAndParse(url: customUrl, method: .get, as: type) { completion($0,$1) }
    }
    
}
